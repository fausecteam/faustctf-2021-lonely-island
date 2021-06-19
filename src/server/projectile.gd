extends KinematicBody

const SPEED := 100.0

var time_to_despawn := 10.0
var team: int

func _ready():
	set_collision_mask_bit(team + 10, false)

func _physics_process(delta):
	time_to_despawn -= delta
	if time_to_despawn <= 0:
		for id in get_parent().connected:
			rpc_id(id, "despawn")
		despawn()
		return
	var collision = move_and_collide(transform.basis.get_rotation_quat() * Vector3.FORWARD * SPEED * delta)
	if collision:
		if collision.collider.is_in_group("player"):
			collision.collider.hit(25.0)
		for id in get_parent().connected:
			rpc_id(id, "despawn")
		despawn()

func despawn():
	queue_free()
