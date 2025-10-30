extends Control


func _on_host_pressed() -> void:
	Network.create_lobby()


func _on_join_pressed() -> void: 
	var lobby_id: int = int($LobbyId.text)
	Network.join_lobby(lobby_id)
 
