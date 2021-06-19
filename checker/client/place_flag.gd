extends "res://remote.gd"

func _on_Remote_connected():
	disconnect("connected", self, "_on_Remote_connected")
	var flag_user = OS.get_environment("USER")
	var flag_pw = OS.get_environment("PASSWORD")
	var read_user = OS.get_environment("READ_USER")
	var read_pw = OS.get_environment("READ_PASSWORD")
	var err = yield(register(flag_user, flag_pw, OS.get_environment("FLAG")), "completed")
	if err:
		service_faulty()
		return
	err = yield(register(read_user, read_pw, OS.get_environment("READ_BIO")), "completed")
	if err:
		service_faulty()
		return
	if not yield(login(flag_user, flag_pw), "completed"):
		service_faulty()
		return
	if not add_friend(read_user):
		service_faulty()
		return
	if not join():
		service_faulty()
		return
	yield(get_tree().create_timer(2 + randf() * 3), "timeout") # Give exploits some time to trigger
	connect("connected", self, "_on_Remote_connected2")
	return reconnect()

func _on_Remote_connected2():
	var flag_user = OS.get_environment("USER")
	var read_user = OS.get_environment("READ_USER")
	var read_pw = OS.get_environment("READ_PASSWORD")
	if not yield(login(read_user, read_pw), "completed"):
		service_faulty()
		return
	if not add_friend(flag_user):
		service_faulty()
		return
	# Use an API endpoint with a response from the server. Maybe it disconnects too early and the rpc isn't sent yet?
	# Dirty fix?
	var friends = yield(get_friends(), "completed")
	logging(INFO, "Friends: " + str(friends))
	get_tree().quit(SERVICE_OK)
