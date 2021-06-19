extends Node

var visible := false

puppet func playerlist(list: Array):
	for entry in list:
		create_player(entry[0], entry[1], entry[2])

puppet func create_player(id: int, name: String, teamid: int):
	if not visible or has_node(str(id)):
		return
	var player = preload("res://player.tscn").instance()
	player.name = str(id)
	player.player_name = name
	player.teamid = teamid
	add_child(player)
	
	get_parent().logging(get_parent().INFO, "Player joined: " + name)
	if name == OS.get_environment("USER2"):
		get_parent().logging(get_parent().INFO, "Found other user. *Happy Checker noises*")
		get_tree().quit(get_parent().SERVICE_OK)

puppet func delete_player(id: int):
	var node = get_node_or_null(str(id))
	if node:
		remove_child(node)
		node.queue_free()

puppet func create_projectile(_name: String, _position: Vector3, _pitch: float, _yaw: float, _teamid: int):
	pass

puppet func set_points(_team: int, _points: int):
	pass
