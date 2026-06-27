extends Control


const LOBBY_BTN_SCN := preload("res://lobby/steam_lobby_button.tscn")

var IS_JOINING: bool = false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var init_response: Dictionary = Steam.steamInitEx()
	if init_response["status"] != Steam.STEAM_API_INIT_RESULT_OK:
		self.visible = false
		return
	Steam.initRelayNetworkAccess()
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	Steam.lobby_joined.connect(_on_connected_to_server)


func _on_host_pressed() -> void:
	if Network.LOBBY_ID == 0:
		Network.IS_HOST = true
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, Network.LOBBY_MEMBERS_MAX)


func _on_list_lobbies_pressed() -> void:
	Network.list_lobbies()


func _on_lobby_match_list(lobbies: Array) -> void:
	for lobby_child in %LoadedLobbies.get_children():
		lobby_child.queue_free()
	
	for lobby in lobbies:
		var lobby_name: String = Steam.getLobbyData(lobby, "name")
		
		if lobby_name == Global.STEAM_LOBBY_NAME:
			#var lobby_mode: String = Steam.getLobbyData(lobby, "mode")
			var lobby_button: TextureButton = LOBBY_BTN_SCN.instantiate()
			
			lobby_button.set_name("lobby_%s" % lobby)
			lobby_button.get_node("Label").set_text(str(lobby))
			lobby_button.pressed.connect(join_lobby.bind(lobby))
			
			%LoadedLobbies.add_child(lobby_button)


func _on_lobby_created(connect_value: int, lobby_id: int) -> void:
	if connect_value == Steam.Result.RESULT_OK:
		Network.LOBBY_ID = lobby_id
		
		Steam.setLobbyJoinable(lobby_id, true)
		Steam.setLobbyData(lobby_id, "name", Global.STEAM_LOBBY_NAME)
		Steam.setLobbyData(lobby_id, "mode", "Test")
		
		var peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
		peer.create_host(Network.LOBBY_MEMBERS_MAX)
		multiplayer.multiplayer_peer = peer
		
		Network.get_lobby_members()
		
		get_tree().change_scene_to_file("res://lobby/lobby.tscn")


func _on_connected_to_server(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if !IS_JOINING:
		return
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("Connected to Steam server %d!" % lobby_id)
		Network.LOBBY_ID = lobby_id
		
		var peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
		peer.create_client(Steam.getLobbyOwner(lobby_id), Network.LOBBY_MEMBERS_MAX)
		multiplayer.multiplayer_peer = peer
		
		IS_JOINING = false
		
		Network.get_lobby_members()
		
		change_to_lobby_scn()


func join_lobby(lobby_id: int):
	print("Joining lobby %d" % lobby_id)
	IS_JOINING = true
	Steam.joinLobby(lobby_id)


func change_to_lobby_scn() -> void:
	get_tree().change_scene_to_file("res://lobby/lobby.tscn")
