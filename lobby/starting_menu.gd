extends Control

func _ready() -> void:
	%BaseMenuError.text = ""
	Steam.lobby_created.connect(_on_steam_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	Network.steam_lobby_joined.connect(_on_steam_lobby_created.bind(1, Network.LOBBY_ID))


func _on_test_scene_pressed() -> void:
	get_tree().change_scene_to_file("res://arenas/test_scene.tscn")


func _on_host_pressed() -> void:
	$Multiplayer.become_host()
	_on_steam_lobby_created(1, 1)


func _on_steam_lobby_created(connect_value: int, _this_lobby_id: int) -> void:
	if connect_value == 1:
		get_tree().change_scene_to_file("res://lobby/lobby.tscn")


func _on_host_retry_timer_timeout() -> void:
	%Host.disabled = false


func _on_list_lobbies_pressed() -> void:
	Network.list_lobbies()


func _on_lobby_match_list(lobbies: Array) -> void:
	for lobby_child in %LoadedLobbies.get_children():
		lobby_child.queue_free()

	for lobby in lobbies:
		var lobby_name: String = Steam.getLobbyData(lobby, "name")
		
		if lobby_name == Global.STEAM_LOBBY_NAME:
			var lobby_mode: String = Steam.getLobbyData(lobby, "mode")
			var lobby_button: Button = Button.new()
			#lobby_button.toggle_mode = true
			lobby_button.set_text(lobby_name + " | " + lobby_mode)
			lobby_button.set_size(Vector2(100, 30))
			lobby_button.add_theme_font_size_override("font_size", 8)
			lobby_button.set_name("lobby_%s" % lobby)
			lobby_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			lobby_button.pressed.connect(join_lobby.bind(lobby))
			
			%LoadedLobbies.add_child(lobby_button)


func join_lobby(lobby_id: int):
	print("Joining lobby %d" % lobby_id)
	Network.join_lobby(lobby_id)
	%BaseMenuError.text = ""


func _on_join_test_pressed() -> void:
	%BaseMenuError.text = "Looking for host..."
	$Multiplayer.join_as_client()
	%ConnectionTimeout.start()


func _on_connected_to_server() -> void:
	print("Connected successfully!")
	%ConnectionTimeout.stop()
	_on_steam_lobby_created(1, 1)


func _on_connection_timeout_timeout() -> void:
	print("Connection timed out")
	
	# Clean up the failed peer
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	%BaseMenuError.text = "Failed to connect. No host found."


func _on_host_steam_pressed() -> void:
	Network.create_lobby()
