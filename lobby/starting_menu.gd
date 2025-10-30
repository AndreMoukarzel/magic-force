extends Control


func _ready() -> void:
	%BaseMenuError.text = ""
	Steam.lobby_created.connect(_on_steam_lobby_created)


func _on_test_scene_pressed() -> void:
	get_tree().change_scene_to_file("res://arenas/test_scene.tscn")


func _on_host_pressed() -> void:
	Network.create_lobby()
	%HostRetryTimer.start()
	%Host.disabled = true


func _on_join_pressed() -> void:
	var LobbyId: LineEdit = %LobbyId
	if LobbyId.text.is_valid_int():
		var lobby_id: int = int(LobbyId.text)
		Network.join_lobby(lobby_id)
		%BaseMenuError.text = ""
	else:
		%BaseMenuError.text = "Not Valid ID"


func _on_steam_lobby_created(connect_value: int, _this_lobby_id: int) -> void:
	if connect_value == 1:
		get_tree().change_scene_to_file("res://lobby/lobby.tscn")


func _on_host_retry_timer_timeout() -> void:
	%Host.disabled = false
