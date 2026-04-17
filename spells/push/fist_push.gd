extends Node3D


@export var PLAYER: CharacterBody3D

var PUSH_FORCE: float = 220.0
var SELF_PUSH_FORCE: float = 4.3
var IS_ACTIVE: bool = false
var POWER_LEVEL: int = 0
var PUSH_MULTIPLIER: Array[float] = [0.0, 1.0, 1.3, 1.6]
var SELF_PUSH_MULTIPLIER: Array[float] = [0.0, 1.0, 1.3, 1.6]


func activate() -> void:
	if IS_ACTIVE:
		return
	if not $Cooldown.is_stopped():
		return
	
	IS_ACTIVE = true
	POWER_LEVEL = 1
	$Fist/Fist.scale = Vector3(1, 1, 1)
	$PowerUpTimer1.start()
	
	$PowerUpTimer2.stop()


func release() -> void:
	if not $Cooldown.is_stopped():
		return
	
	$PowerUpTimer1.stop()
	$PowerUpTimer2.stop()
	
	$Fist.scale = Vector3(-0.6, -0.6, -0.6)
	area_push()
	$Cooldown.start()
	$AnimationPlayer.play("release")
	await $AnimationPlayer.animation_finished
	$Fist.hide()
	$Fist/Fist.scale = Vector3(1, 1, 1)


func area_push() -> void:
	var bodies: Array[Node3D] = $Area3D.get_overlapping_bodies()
	for body in bodies:
		if body != get_parent() and body.has_method("apply_impulse"):
			push_away(body)
			
			if body.has_method("clear_all_grabbers"):
				body.clear_all_grabbers()
	
	var floors: Array[Node3D] = $AreaFloorPush.get_overlapping_bodies()
	if len(floors) > 0:
		push_player()


func _get_push_direction() -> Vector3:
	return -global_transform.basis.z.normalized()


func push_away(object: Node3D) -> void:
	var direction: Vector3 = _get_push_direction()
	if "linear_velocity" in object:
		object.linear_velocity = Vector3(0, 10, 0)
	var power_multiplier: float = PUSH_MULTIPLIER[POWER_LEVEL]
	object.apply_impulse(direction * PUSH_FORCE * power_multiplier)


func push_player() -> void:
	# Forward vector of the camera (where it is looking)
	var cam_forward: Vector3 = -global_transform.basis.z.normalized()
	
	# Opposite direction (push AWAY from where camera is looking)
	var push_dir: Vector3 = -cam_forward
	var power_multiplier: float = SELF_PUSH_MULTIPLIER[POWER_LEVEL]
	PLAYER.apply_knockback(push_dir * SELF_PUSH_FORCE * power_multiplier)


func _on_cooldown_timeout() -> void:
	POWER_LEVEL = 0
	IS_ACTIVE = false
	$Fist.show()
	$AnimationPlayer.play("idle")


func _on_power_up_timer_1_timeout() -> void:
	POWER_LEVEL = 2
	$Fist/Fist.scale = Vector3(1.2, 1.2, 1.2)
	$PowerUpTimer2.start()


func _on_power_up_timer_2_timeout() -> void:
	POWER_LEVEL = 3
	$Fist/Fist.scale = Vector3(1.5, 1.5, 1.5)
