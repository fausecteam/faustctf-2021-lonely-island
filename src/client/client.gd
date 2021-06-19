extends Control

# warning-ignore:unused_signal
signal connection_changed

var connection: Node

func _on_Connect_pressed():
	var peer := NetworkedMultiplayerENet.new()
	peer.connect("connection_failed", self, "emit_signal", ["connection_changed", false])
	peer.connect("connection_succeeded", self, "emit_signal", ["connection_changed", true])
	peer.connect("server_disconnected", self, "server_disconnected")
	if peer.create_client($Connect/IP.text, 4321) != OK:
		$Connect/Status.text = "Cannot connect to server"
		return
	get_tree().network_peer = peer
	$Connect.hide()
	if yield(self, "connection_changed"):
		connection = Node.new()
		connection.set_script(load("res://client/connection.gd"))
		connection.name = str(get_tree().get_network_unique_id())
		add_child(connection)
		$Connected.show()
	else:
		$Connect/Status.text = "Cannot connect to server"
		$Connect.show()

func _on_Register_pressed():
	$Connected.hide()
	$Register.show()
	$Register/Status.text = ""

func _on_Login_pressed():
	$Connected.hide()
	$Login.show()
	$Login/Status.text = ""

func register():
	if $Register/Password.text != $Register/Password2.text:
		$Register/Status.text = "Passwords do not match"
		return
	
	connection.rpc_id(1, "register", $Register/Name.text, $Register/Password.text, $Register/Bio.text)
	var error = yield(connection, "registered")
	if not error:
		$Register.hide()
		$Connected.show()
	else:
		$Register/Status.text = error

func _on_Register_Back_pressed():
	$Register.hide()
	$Connected.show()

func login():
	connection.rpc_id(1, "login", $Login/Name.text, $Login/Password.text)
	if yield(connection, "login"):
		$Login.hide()
		$LoggedIn.show()
	else:
		$Login/Status.text = "Cannot log in"

func _on_Login_Back_pressed():
	$Login.hide()
	$Connected.show()

func _on_Join_pressed():
	connection.rpc_id(1, "join_game")
	$LoggedIn.hide()
	$UI.hide()
	$Game.show()
	$Game/Crosshair.show()
	$Game/Sidebar.show()

func _on_Friends_pressed():
	$LoggedIn.hide()
	$Friends.show()
	update_friendlist()

func _on_Exit_pressed():
	get_tree().quit(0)

func _on_Friends_Back_pressed():
	$Friends.hide()
	$LoggedIn.show()

func update_friendlist():
	for child in $Friends/HBoxContainer/ScrollContainer/VBoxContainer.get_children():
		$Friends/HBoxContainer/ScrollContainer/VBoxContainer.remove_child(child)
		child.queue_free()
	connection.rpc_id(1, "get_friends")
	var friends = yield(connection, "friendlist")
	for item in friends:
		var entry = preload("res://client/friendlist_entry.tscn").instance()
		entry.get_node("Name").text = item
		var data = friends[item]
		if data:
			entry.get_node("SecondRow").text = "{online} - {bio}".format({"online": "Online" if data["online"] else "Offline", "bio": data["bio"]})
		else:
			entry.get_node("SecondRow").text = "No mutual friendship"
		$Friends/HBoxContainer/ScrollContainer/VBoxContainer.add_child(entry)

func _on_Add_pressed():
	$AddFriendDialog.popup_centered()

func _on_AddFriendDialog_confirmed():
	if $AddFriendDialog/Name.text:
		connection.rpc_id(1, "add_friend", $AddFriendDialog/Name.text)
	update_friendlist()

func server_disconnected():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$AcceptDialog.window_title = "Connection lost"
	$AcceptDialog.dialog_text = "The connection to the server was lost"
	$AcceptDialog.popup_centered()
	yield($AcceptDialog, "popup_hide")
	get_tree().quit(1)
