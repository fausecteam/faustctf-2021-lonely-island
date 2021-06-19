extends "res://remote.gd"


func _on_Remote_connected():
	var target_user = OS.get_environment("USER")
	var expected_flag = OS.get_environment("FLAG")
	var read_user = OS.get_environment("READ_USER")
	var read_pw = OS.get_environment("READ_PASSWORD")
	if not yield(login(read_user, read_pw), "completed"):
		if OS.exit_code == 0:
			get_tree().quit(SERVICE_FLAG_NOT_FOUND)
		return
	var friends = yield(get_friends(), "completed")
	logging(INFO, "Friends: " + str(friends))
	if not friends is Dictionary:
		get_tree().quit(SERVICE_FAULTY)
		return
	if target_user in friends and "bio" in friends[target_user] and friends[target_user]["bio"] == expected_flag:
		logging(INFO, "Flag found")
		get_tree().quit(SERVICE_OK)
	else:
		if target_user in friends and "bio" in friends[target_user]:
			logging(WARN, "Found flag user, got flag `" + friends[target_user]["bio"] + "`, but expected `" + expected_flag + "`")
		get_tree().quit(SERVICE_FLAG_NOT_FOUND)
