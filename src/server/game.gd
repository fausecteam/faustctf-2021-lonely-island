extends Node

var projectile_count := 0

var players := {}

var teams := [{}, {}]
var points := [0, 0]
var flag_owner := [null, null]
var spawns = [Vector3(5, 0, 50), Vector3(-5, 0, -20)]

func join(id: int, playerinfo) -> bool:
	if id in players:
		return false
	players[id] = true
	var min_team = teams[0]
	var teamid = 0
	for i in range(1, len(teams)):
		if len(teams[i]) < len(min_team):
			min_team = teams[i]
			teamid = i
	min_team[id] = true
	create_player(id, playerinfo.name, teamid)
	for target_id in players:
		if target_id != id:
			self.rpc_id(target_id, "create_player", id, playerinfo.name, teamid)
	return true

func sendplayerlist(id: int):
	var list := []
	for player in players:
		var node = get_node(str(player))
		list.append([player, node.player_name, node.teamid])
	self.rpc_id(id, "playerlist", list)
	for team in range(len(teams)):
		self.rpc_id(id, "set_points", team, points[team])
	for owner in flag_owner:
		if owner:
			var player = get_node(str(owner))
			player.rpc_id(id, "pickup_flag", player.flag)

func create_player(id: int, name: String, teamid: int):
	var player = preload("res://server/player.tscn").instance()
	player.name = str(id)
	player.player_name = name
	player.teamid = teamid
	add_child(player)

func leave(id: int) -> bool:
	if not id in players:
		return false
	players.erase(id)
	for team in teams:
		team.erase(id)
	get_node(str(id)).flag = -1
	for target_id in players:
		self.rpc_id(target_id, "delete_player", id)
	delete_player(id)
	return true

func delete_player(id: int):
	var node = get_node(str(id))
	remove_child(node)
	node.queue_free()

func create_projectile(name: String, position: Vector3, pitch: float, yaw: float, teamid: int):
	var projectile = preload("res://server/projectile.tscn").instance()
	projectile.name = name
	projectile.rotation.x = pitch
	projectile.rotation.y = yaw
	projectile.translation = position + projectile.transform.basis.get_rotation_quat() * Vector3.FORWARD * 2
	projectile.team = teamid
	add_child(projectile)
	projectile_count += 1

func recheck_flags():
	for body in $Team0.get_overlapping_bodies():
		_on_flag_body_entered(body, 0)
	for body in $Team1.get_overlapping_bodies():
		_on_flag_body_entered(body, 1)

func _on_flag_body_entered(body, teamid):
	if body.teamid != teamid:
		if flag_owner[teamid] == null and body.flag == -1:
			body.flag = teamid
	elif body.flag != -1 and flag_owner[teamid] == null:
		body.flag = -1
		points[body.teamid] += 1
		for id in players:
			rpc_id(id, "set_points", body.teamid, points[body.teamid])
