extends MeshInstance

const SPEED := 100.0

func _physics_process(delta):
	translation += transform.basis.get_rotation_quat() * Vector3.FORWARD * SPEED * delta

puppet func despawn():
	queue_free()
