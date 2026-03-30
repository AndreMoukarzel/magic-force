extends "res://player/player_controller.gd"


# Properties must be exported to be synced
@export var PLAYER_ID: int = 1
@export var TEAM: String = "A"


func set_player_id(id: int) -> void:
	PLAYER_ID = id
	$Label3D.text = str(id)


func _ready():
	if multiplayer.get_unique_id() == PLAYER_ID:
		set_multiplayer_authority(PLAYER_ID)
		CAM.make_current()
	else:
		CAM.current = false


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	super(delta)


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		super(event)
