extends Node

func answer_rpc(method: String, args: Array):
	self.callv("rpc_id", [int(self.name), method] + args)

master func register(name: String, pw: String, bio: String):
	answer_rpc("register_callback", get_parent().register(name, pw, bio))

master func login(name: String, pw: String):
	answer_rpc("login_callback", [get_parent().login(int(self.name), name, pw)])

master func join_game():
	get_parent().join_game(int(self.name))

master func add_friend(name: String):
	get_parent().add_friend(int(self.name), name)

master func get_friends():
	answer_rpc("friendlist_callback", [get_parent().get_friends(int(self.name))])
