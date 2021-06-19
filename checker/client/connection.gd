extends Node

signal registered
signal login

signal friendlist

puppet func register_callback(success: bool, error: String):
	emit_signal("registered", "" if success else error)

puppet func login_callback(success: bool):
	emit_signal("login", success)

puppet func friendlist_callback(friends: Dictionary):
	emit_signal("friendlist", friends)
