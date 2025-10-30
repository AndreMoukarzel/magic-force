extends Node

var STEAM_ID: int = 0
var STEAM_USERNAME: String = ""

func _init() -> void:
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))


func _ready() -> void:
	Steam.steamInit()
	
	STEAM_ID = Steam.getSteamID()
	STEAM_USERNAME = Steam.getPersonaName()


func _process(_delta: float) -> void:
	Steam.run_callbacks()
