extends Node


const SERVER_PORT: int = 8080
const SERVER_IP: String = "127.0.0.1"

var ENET_PEER: ENetMultiplayerPeer = ENetMultiplayerPeer.new()


func become_host() -> void:
	print("Starting host!")
	
	ENET_PEER.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = ENET_PEER


func join_as_client(_lobby_id: int = 0) -> void:
	print("Client joining")
	
	ENET_PEER.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = ENET_PEER
