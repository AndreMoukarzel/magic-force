extends Node


const SERVER_PORT: int = 8080

var ENET_PEER: ENetMultiplayerPeer = ENetMultiplayerPeer.new()


func become_host() -> void:
	print("Starting host!")
	
	ENET_PEER.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = ENET_PEER


func join_as_client(server_ip: String="127.0.0.1") -> void:
	print("Client joining")
	
	ENET_PEER.create_client(server_ip, SERVER_PORT)
	multiplayer.multiplayer_peer = ENET_PEER
