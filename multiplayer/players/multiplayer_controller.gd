extends "res://player/player_controller.gd"


# Properties must be exported to be synced
@export var PLAYER_ID: int = 1


func set_player_id(id: int) -> void:
	PLAYER_ID = id
	$Label3D.text = str(id)


func _ready():
	if multiplayer.get_unique_id() == PLAYER_ID:
		CAM.make_current()
	else:
		CAM.current = false


func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	super(delta)


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("primary_action"):
			force_grab_multiplayer.rpc()
		
		if event.is_action_pressed("secondary_action"):
			activate_fist_multiplayer.rpc()
		elif event.is_action_released("secondary_action"):
			release_fist_multiplayer.rpc()
		
		if event.is_action_pressed("movement_action"):
			if is_on_floor():
				jump_multiplayer.rpc()
			else:
				float_activate_multiplayer.rpc()
		elif event.is_action_released("movement_action"):
			if not is_on_floor():
				float_deactivate_multiplayer.rpc()


@rpc("call_local")
func force_grab_multiplayer() -> void:
	$ProjectileGrab.grab()


@rpc("call_local")
func activate_fist_multiplayer() -> void:
	$FistPush.activate()


@rpc("call_local")
func release_fist_multiplayer() -> void:
	$FistPush.release()


@rpc("call_local")
func float_activate_multiplayer() -> void:
	$Float.activate()


@rpc("call_local")
func float_deactivate_multiplayer() -> void:
	$Float.deactivate()


@rpc("call_local")
func jump_multiplayer() -> void:
	$Jump.jump(MOVE_DIR)
