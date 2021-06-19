extends KinematicBody

var player_name: String
var teamid: int

puppetsync var health := 0.0
var dead := true
var respawn_timer := 0.0
var reload := 0.0
var invincibility := 0.0

var flag := -1 setget set_flag

func _ready():
	set_collision_layer_bit(teamid + 10, true)

func _process(delta: float):
	if dead:
		respawn_timer -= delta
		if respawn_timer <= 0:
			dead = false
			self.set_collision_layer_bit(0, true)
			self.set_collision_mask_bit(0, true)
			reload = 0.0
			invincibility = 2.0
			for id in get_parent().players:
				rset_id(id, "position", get_parent().spawns[teamid])
				rset_id(id, "velocity", Vector3())
				rset_id(id, "health", 100.0)
	else:
		reload = max(0.0, reload - delta)
		invincibility = max(0.0, invincibility - delta)

func set_flag(team: int):
	if flag != -1:
		get_parent().flag_owner[flag] = null
	if team != -1:
		get_parent().flag_owner[team] = int(self.name)
	flag = team
	get_parent().recheck_flags()
	for id in get_parent().players:
		rpc_id(id, "pickup_flag", team)

master func update(position: Vector3, velocity: Vector3, pitch: float, yaw: float):
	if dead:
		return
	for id in get_parent().players:
		rset_id(id, "position", position)
		rset_id(id, "velocity", velocity)
		rset_id(id, "lookdir", Vector2(pitch, yaw))
	self.translation = position
	
	self.rotation.y = yaw
	
	if position.y < 0.01:
		hit(health)

master func shoot(position: Vector3, pitch: float, yaw: float):
	if reload > 0.0:
		return
	for id in get_parent().players:
		get_parent().rpc_id(id, "create_projectile", "p" + str(get_parent().projectile_count), position, pitch, yaw, teamid)
	get_parent().create_projectile("p" + str(get_parent().projectile_count), position, pitch, yaw, teamid)
	reload = 2.0

func hit(damage: float):
	if invincibility > 0:
		return
	for id in get_parent().players:
		rset_id(id, "health", health - damage)
	
	if health <= 0:
		dead = true
		self.set_collision_layer_bit(0, false)
		self.set_collision_mask_bit(0, false)
		self.flag = -1
		respawn_timer = 10.0
