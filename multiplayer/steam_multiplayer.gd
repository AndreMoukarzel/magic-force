extends Node

var STEAM_PEER: SteamMultiplayerPeer = SteamMultiplayerPeer.new()

func  _ready():
	STEAM_PEER.lobby_created.connect(Network._on_lobby_created)

func become_host():
	print("Starting host!")
	
	STEAM_PEER.create_lobby(Steam.LOBBY_TYPE_PUBLIC, Network.LOBBY_MEMBERS_MAX)
	multiplayer.multiplayer_peer = STEAM_PEER


func join_as_client(lobby_id: int):
	print("Joining lobby %s" % lobby_id)
	
	STEAM_PEER.connect_lobby(lobby_id)
	multiplayer.multiplayer_peer = STEAM_PEER
