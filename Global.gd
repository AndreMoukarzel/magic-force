extends Node

const STEAM_APP_ID: int = 480
const STEAM_LOBBY_NAME: String = "MagicForce"

var STEAM_ID: int = 0
var STEAM_USERNAME: String = ""
var STEAM_CONNECTED: bool = false


func _init() -> void:
	Steam.steamInit(STEAM_APP_ID, true)
	var init_response: Dictionary = Steam.steamInitEx()
	if init_response["status"] != Steam.STEAM_API_INIT_RESULT_OK:
		return
	Steam.initRelayNetworkAccess()
	OS.set_environment("SteamAppID", str(STEAM_APP_ID))
	OS.set_environment("SteamGameID", str(STEAM_APP_ID))


func _ready() -> void:
	var init_response: Dictionary = Steam.steamInitEx()
	
	if init_response["status"] == Steam.STEAM_API_INIT_RESULT_OK:
		STEAM_ID = Steam.getSteamID()
		STEAM_USERNAME = Steam.getPersonaName()
		STEAM_CONNECTED = true
		
		var owns_game: bool = Steam.isSubscribed()
		if not owns_game:
			print("User does not own game!")
			get_tree().quit()
