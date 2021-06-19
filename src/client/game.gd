extends Spatial

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		$Menu.visible = not $Menu.visible
		if $Menu.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

puppet func playerlist(list: Array):
	for entry in list:
		create_player(entry[0], entry[1], entry[2])

puppet func create_player(id: int, name: String, teamid: int):
	if not visible or has_node(str(id)):
		return
	var player = preload("res://client/player.tscn").instance()
	player.name = str(id)
	player.player_name = name
	player.teamid = teamid
	add_child_below_node($Flag1, player)

puppet func delete_player(id: int):
	var node = get_node_or_null(str(id))
	if node:
		remove_child(node)
		node.queue_free()

puppet func create_projectile(name: String, position: Vector3, pitch: float, yaw: float, _teamid: int):
	var projectile = preload("res://client/projectile.tscn").instance()
	projectile.name = name
	projectile.rotation.x = pitch
	projectile.rotation.y = yaw
	projectile.translation = position + projectile.transform.basis.get_rotation_quat() * Vector3.FORWARD * 2
	add_child(projectile)

puppet func set_points(team: int, points: int):
	get_node("Sidebar/Team%d/Points" % (team + 1)).text = str(points)


func _on_Return_pressed():
	$Menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_Exit_pressed():
	get_tree().quit(0)
