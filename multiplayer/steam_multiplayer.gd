extends Node


var STEAM_PEER: SteamMultiplayerPeer = SteamMultiplayerPeer.new()


func  _ready():
	STEAM_PEER.network_connection_status_changed.connect(Network._on_lobby_created)


func become_host():
	print("Starting host!")
	
	STEAM_PEER.create_host(Network.LOBBY_MEMBERS_MAX)
	multiplayer.multiplayer_peer = STEAM_PEER


func join_as_client(lobby_id: int=1):
	print("Joining lobby %s" % lobby_id)
	
	STEAM_PEER.create_client(0)
	multiplayer.multiplayer_peer = STEAM_PEER
