extends Node

const SERVICE_OK := 0
const SERVICE_DOWN := 1
const SERVICE_FAULTY := 2
const SERVICE_FLAG_NOT_FOUND := 3

const CHECKER_FAILURE := 66

const INFO := "[INFO]"
const WARN := "[WARN]"
const ERROR := "[ERROR]"

signal connected

var connection: Node

func service_faulty():
	if OS.exit_code == 0:
		get_tree().quit(SERVICE_FAULTY)

func logging(level: String, msg: String):
	print("\t[", OS.get_process_id(), "]", level, " ", msg)

func fail(msg: String):
	logging(ERROR, msg)
	get_tree().quit(CHECKER_FAILURE)

func connection_failed():
	logging(INFO, "Could not connect to service")
	connection = null
	get_tree().quit(SERVICE_DOWN)

func connection_aborted():
	logging(INFO, "Lost connection to server")
	connection = null
	get_tree().quit(SERVICE_DOWN)

func connect_to_server():
	var peer := NetworkedMultiplayerENet.new()
	peer.connect("connection_failed", self, "connection_failed")
	peer.connect("server_disconnected", self, "connection_aborted")
	var port := OS.get_environment("PORT")
	if not port.is_valid_integer():
		logging(ERROR, "`" + port + "` is not a valid Port number")
		get_tree().quit(CHECKER_FAILURE)
		return
	var err := peer.create_client(OS.get_environment("HOST"), int(port))
	if err != OK:
		logging(ERROR, "Failed to create client: " + str(err))
		get_tree().quit(CHECKER_FAILURE)
		return
	get_tree().network_peer = peer
	
	yield(peer, "connection_succeeded")
	logging(INFO, "Connection established")
	connection = Node.new()
	connection.set_script(load("res://connection.gd"))
	connection.name = str(get_tree().get_network_unique_id())
	add_child(connection)
	emit_signal("connected")
	
func _ready():
	return connect_to_server()

func reconnect():
	logging(INFO, "Establishing a new connection")
	get_tree().network_peer.close_connection()
	remove_child(connection)
	get_tree().network_peer = null
	connection.free()
	connection = null
	return connect_to_server()

func register(name: String, passwd: String, bio: String):
	if not connection:
		fail("Register: Connection is null")
		return "Register: Connection is null"
	logging(INFO, "Register(Name: '" + name + "', Password: '" + passwd + "', Bio: '" + bio + "')")
	connection.rpc_id(1, "register", name, passwd, bio)
	var error = yield(connection, "registered")
	if error:
		logging(WARN, "Register: Failed to create user: " + error)
	return error

func login(name: String, passwd: String):
	if not connection:
		fail("Login: Connection is null")
		return false
	logging(INFO, "Login(Name: '" + name + "', Password: '" + passwd + "')")
	connection.rpc_id(1, "login", name, passwd)
	var success = yield(connection, "login")
	if not success:
		logging(WARN, "Login: Failed to log in")
	return success

func get_friends() -> Dictionary:
	if not connection:
		fail("get_friends: Connection is null")
		return null
	logging(INFO, "get_friends()")
	connection.rpc_id(1, "get_friends")
	return yield(connection, "friendlist")

func add_friend(name: String):
	if not connection:
		fail("add_friend: Connection is null")
		return false
	logging(INFO, "add_friend(" + name + ")")
	connection.rpc_id(1, "add_friend", name)
	return true

func join():
	if not connection:
		fail("join: Connection is null")
		return false
	logging(INFO, "join()")
	connection.rpc_id(1, "join_game")
	$Game.visible = true
	return true
