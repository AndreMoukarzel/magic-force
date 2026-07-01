extends Control


func _ready() -> void:
	$BaseMenuError.text = ""
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_test_scene_pressed() -> void:
	change_to_scn("res://arenas/test_scene.tscn")


func _on_host_pressed() -> void:
	$MultiplayerLocal.become_host()
	change_to_lobby_scn()


func _on_join_multiplayer_pressed() -> void:
	var ip_to_join: String = $JoinIP.text
	if ip_to_join == "":
		ip_to_join = $JoinIP.placeholder_text
	
	if not ip_to_join.is_valid_ip_address():
		%BaseMenuError.text = "Invalid IP to join!"
		return
	
	%BaseMenuError.text = "Looking for host..."
	$MultiplayerLocal.join_as_client(ip_to_join)
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


func change_to_scn(scn_path: String) -> void:
	var blackout_tween = create_tween()
	blackout_tween.tween_property($"../../Blackout", "modulate", Color(0.0, 0.0, 0.0, 1.0), 1.0)
	
	var tween: Tween = fade_out($"../../AudioStreamPlayer")
	await tween.finished
	get_tree().change_scene_to_file(scn_path)


func change_to_lobby_scn() -> void:
	get_tree().change_scene_to_file("res://lobby/lobby.tscn")


func fade_out(AudioPlayer: AudioStreamPlayer, duration: float = 1.0) -> Tween:
	var tween = create_tween()
	# Transitioning from current volume to -80 dB (which is inaudible)
	tween.tween_property(AudioPlayer, "volume_db", -80.0, duration)
	return tween
