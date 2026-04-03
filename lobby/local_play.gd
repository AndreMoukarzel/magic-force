extends VBoxContainer


func _ready() -> void:
	$BaseMenuError.text = ""
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_test_scene_pressed() -> void:
	get_tree().change_scene_to_file("res://arenas/test_scene.tscn")


func _on_host_pressed() -> void:
	$MultiplayerLocal.become_host()
	change_to_lobby_scn()


func _on_join_multiplayer_pressed() -> void:
	%BaseMenuError.text = "Looking for host..."
	$MultiplayerLocal.join_as_client()
	%ConnectionTimeout.start()


func _on_connected_to_server() -> void:
	print("Connected to local server!")
	%ConnectionTimeout.stop()
	%BaseMenuError.text = ""
	change_to_lobby_scn()


func _on_connection_timeout_timeout() -> void:
	print("Connection timed out")
	
	# Clean up the failed peer
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	%BaseMenuError.text = "Failed to connect. No host found."


func change_to_lobby_scn() -> void:
	get_tree().change_scene_to_file("res://lobby/lobby.tscn")
