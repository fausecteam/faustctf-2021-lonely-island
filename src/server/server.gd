extends Node

class PlayerInfo:
	var name: String
	var salt: PoolByteArray
	var pw: PoolByteArray
	var bio: String

var playerfile := File.new()
var friendlistfile := File.new()

var playerinfo := {}
var registered_players := {}
var friendship := {}
var logged_in := {}

func create_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(4321, 512)
	peer.connect("peer_connected", self, "_on_peer_connected")
	peer.connect("peer_disconnected", self, "_on_peer_disconnected")
	get_tree().network_peer = peer

func _ready():
	create_server()
	
	if playerfile.open("data/players", File.READ_WRITE) != OK:
		print("Failed to open player database")
		get_tree().quit(1)
		return
	playerfile.seek_end()
	var end = playerfile.get_position()
	playerfile.seek(0)
	while playerfile.get_position() < end:
		var entry = playerfile.get_var(true)
		registered_players[entry[0]] = dict2inst(entry[1])
		friendship[entry[0]] = {}
	playerfile.seek_end()
	
	if friendlistfile.open("data/friendlist", File.READ_WRITE) != OK:
		print("Failed to open friendlist database")
		get_tree().quit(1)
		return
	friendlistfile.seek_end()
	end = friendlistfile.get_position()
	friendlistfile.seek(0)
	while friendlistfile.get_position() < end:
		var entry = friendlistfile.get_var(true)
		friendship[entry[0]][entry[1]] = true
	friendlistfile.seek_end()

func _on_peer_connected(id: int):
	var connection = Node.new()
	connection.set_script(preload("res://server/connection.gd"))
	connection.name = str(id)
	add_child(connection)

func _on_peer_disconnected(id: int):
	logout(id)
	var connection = get_node(str(id))
	remove_child(connection)
	connection.queue_free()

func flush(f: File):
	var path := f.get_path()
	f.close()
	if f.open(path, File.READ_WRITE) != OK:
		print("Failed to reopen database")
		get_tree().quit(1)
	f.seek_end()

func register(name: String, pw: String, bio: String):
	if name in registered_players:
		return [false, "Name already taken"]
	if len(name) > 100:
		return [false, "Name too long"]
	var player: PlayerInfo = PlayerInfo.new()
	player.name = name
	player.salt = Crypto.new().generate_random_bytes(64)
	player.pw = (player.salt.hex_encode() + pw).sha256_buffer()
	player.bio = bio
	registered_players[name] = player
	friendship[name] = {}
	playerfile.store_var([name, inst2dict(player)], true)
	flush(playerfile)
	return [true, ""]

func login(id: int, name: String, pw: String):
	if not name in registered_players:
		return false
	if id in playerinfo:
		return false
	if name in logged_in:
		return false
	if (registered_players[name].salt.hex_encode() + pw).sha256_buffer() != registered_players[name].pw:
		return false
	playerinfo[id] = registered_players[name]
	logged_in[name] = id
	return true

func logout(id: int):
	if not id in playerinfo:
		return
	$Game.leave(id)
	logged_in.erase(playerinfo[id].name)
	playerinfo.erase(id)

func is_logged_in(id: int):
	return id in playerinfo

func join_game(id: int):
	if id in playerinfo and $Game.join(id, playerinfo[id]):
		$Game.sendplayerlist(id)

func add_friend(id: int, name: String):
	if not id in playerinfo:
		return
	if not name in registered_players:
		return
	friendship[playerinfo[id].name][name] = true
	friendlistfile.store_var([playerinfo[id].name, name])
	flush(friendlistfile)

func get_friends(id: int):
	if not id in playerinfo:
		return
	var friends := {}
	for friend in friendship[playerinfo[id].name]:
		friends[friend] = get_profile(id, friend)
	return friends

func get_profile(from_id: int, target: String):
	if not from_id in playerinfo:
		return null
	if not target in registered_players:
		return null
	if not playerinfo[from_id].name in friendship[target]:
		return null
	var data = registered_players[target]
	return {"name": data.name, "bio": data.bio, "online": data.name in logged_in}
