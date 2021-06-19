extends KinematicBody

const SENSITIVITY := 1.0
const SPEED := 10.0

const UPDATE_INTERVAL := 0.1

const UNIFORM_COLORS := [preload("res://client/assets/textileBlue.material"), preload("res://client/assets/textileRed.material")]

var player_name: String
var teamid: int

puppet var position: Vector3 setget set_position
puppet var velocity: Vector3
puppet var lookdir: Vector2 setget set_lookdir

var gravity := 0.0

var dead := false
var time_since_last_update := 0.0
var shoot_cooldown := 0.0
puppet var health := 100.0 setget set_health

var flag := -1

func replace_material(node: Node, name: String, material: Material):
	if node is MeshInstance:
		var mesh = node.mesh
		for i in range(mesh.get_surface_count()):
			var mat = mesh.surface_get_material(i)
			if not mat:
				continue
			if mat.resource_name == name:
				node.set_surface_material(i, material)
	
	for child in node.get_children():
		replace_material(child, name, material)

func _ready():
	replace_material($pirate, "teamcolor", UNIFORM_COLORS[teamid])
	if not is_self():
		$Camera.queue_free()
		$RespawnScreen.queue_free()
	else:
		dead = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func is_self():
	return str(get_tree().get_network_unique_id()) == self.name

func set_position(pos: Vector3):
	if not dead and is_self():
		return
	self.translation = pos

func set_lookdir(dir: Vector2):
	if not is_self():
		self.rotation.y = dir.y
		var skeleton = $pirate/Armature/Skeleton
		var bone_id = skeleton.find_bone("right_arm")
		skeleton.set_bone_pose(bone_id, Transform.IDENTITY.rotated(Vector3(1, 0, 0), -dir.x))
		bone_id = skeleton.find_bone("head")
		skeleton.set_bone_pose(bone_id, Transform.IDENTITY.rotated(Vector3(1, 0, 0), -dir.x))

func set_health(h: float):
	if h < health and h > 0 and is_self():
		$AnimationPlayer.play("hit")
	health = h
	if dead and h > 0:
		shoot_cooldown = 0.0
		gravity = 0.0
	dead = h <= 0
	if is_self():
		if dead:
			$RespawnScreen.show()
		else:
			$RespawnScreen.hide()
	else:
		if dead:
			hide()
		else:
			show()

func _input(event):
	if dead or not is_self() or get_node("../Menu").visible:
		return
	if event is InputEventMouseMotion:
		var delta = event.relative / OS.window_size
		$Camera.rotation.x = clamp($Camera.rotation.x - delta.y * SENSITIVITY, -PI/2, PI/2)
		var skeleton = $pirate/Armature/Skeleton
		var bone_id = skeleton.find_bone("right_arm")
		skeleton.set_bone_pose(bone_id, Transform.IDENTITY.rotated(Vector3(1, 0, 0), -$Camera.rotation.x))
		self.rotation.y -= delta.x * SENSITIVITY
		get_tree().set_input_as_handled()
	if event.is_action_pressed("shoot") and shoot_cooldown <= 0:
		rpc_id(1, "shoot", self.translation + Vector3(0, 1.8, 0), $Camera.rotation.x, self.rotation.y)
		$pirate/Armature/Skeleton/BoneAttachment/FlintlockPistol/AnimationPlayer.play("ArmatureAction")
		$Shot.play()
		shoot_cooldown = 2.0
		get_tree().set_input_as_handled()

func _physics_process(delta):
	if dead:
		return
	gravity += 9.81 * delta
	if is_self():
		shoot_cooldown = max(shoot_cooldown - delta, 0.0)
		var last_translation = self.translation
		
		var dir := Vector3()
		if not get_node("../Menu").visible:
			dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
			dir.z = Input.get_action_strength("backward") - Input.get_action_strength("forward")
		move_and_slide(self.transform.basis.get_rotation_quat() * dir.normalized() * SPEED + gravity * Vector3.DOWN, Vector3.UP)
		if dir.length_squared() >= 0.01 and not $pirate/AnimationPlayer.is_playing():
			$pirate/AnimationPlayer.play("run")
		
		time_since_last_update += delta
		if time_since_last_update >= UPDATE_INTERVAL:
			rpc_unreliable_id(1, "update", self.translation, self.translation - last_translation, $Camera.rotation.x, self.rotation.y)
			time_since_last_update -= UPDATE_INTERVAL
	else:
		move_and_slide(velocity + gravity * Vector3.DOWN, Vector3.UP)
		if velocity.length_squared() >= 0.01 and not $pirate/AnimationPlayer.is_playing():
			$pirate/AnimationPlayer.play("run")

	if is_on_floor():
		gravity = 0.0

puppet func pickup_flag(team: int):
	if flag != -1:
		get_parent().get_node("Sidebar/Team%dFlagStatus" % (flag + 1)).text = ""
		get_parent().get_node("Flag%d/Flag" % flag).show()
		$pirate/Armature/Skeleton/BoneAttachment2/Flag.hide()
	if team != -1:
		get_parent().get_node("Sidebar/Team%dFlagStatus" % (team + 1)).text = "Flag stolen by {name}".format({"name": player_name})
		get_parent().get_node("Flag%d/Flag" % team).hide()
		$pirate/Armature/Skeleton/BoneAttachment2/Flag.set_surface_material(0, UNIFORM_COLORS[team])
		$pirate/Armature/Skeleton/BoneAttachment2/Flag.show()
	flag = team
