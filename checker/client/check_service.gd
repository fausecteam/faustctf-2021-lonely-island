extends "res://remote.gd"


func _on_Remote_connected():
	var user1 = OS.get_environment("USER1")
	var pw1 = OS.get_environment("PASSWORD1")
	var err = yield(register(user1, pw1, OS.get_environment("BIO")), "completed")
	if err:
		service_faulty()
		return
	if not yield(login(user1, pw1), "completed"):
		service_faulty()
		return
	if not join():
		service_faulty()
		return
	# Wait for other client to arrive
	yield(get_tree().create_timer(5), "timeout")
	# Well, they aren't here. I guess the service is faulty
	logging(WARN, "Other client didn't join game session")
	service_faulty()
