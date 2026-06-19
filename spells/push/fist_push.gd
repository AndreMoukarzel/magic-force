extends Node3D


@export var PLAYER: CharacterBody3D
@export var COOLDOWN: float = 2.5

var PUSH_FORCE: float = 220.0
var SELF_PUSH_FORCE: float = 4.3
var PUSH_MULTIPLIER: Array[float] = [0.0, 1.0, 1.3, 1.6]
var SELF_PUSH_MULTIPLIER: Array[float] = [0.0, 1.0, 1.3, 1.6]
var IS_ACTIVE: bool = false
var IS_RELEASED: bool = false
var POWER_LEVEL: int = 0

var SHAKE_SPEED: float = 20.0
var SHAKE_OFFSET: Vector3 = Vector3.ZERO
@onready var BASE_POSITION: Vector3 = $Fist/Fist.position


func _ready():
	$Cooldown.wait_time = COOLDOWN
	$CooldownEffect.set_cooldown_duration(COOLDOWN)


func _process(delta: float) -> void:
	update_shake(delta)


func update_shake(_delta: float) -> void:
	if not IS_ACTIVE:
		return
	if IS_RELEASED:
		return
	
	# Increase intensity based on POWER_LEVEL
	var shake_intensity: float = 0.0
	match POWER_LEVEL:
		1:
			shake_intensity = 0.02
		2:
			shake_intensity = 0.05
		3:
			shake_intensity = 0.1
	
	# Generate random offset
	SHAKE_OFFSET.x = randf_range(-1.0, 1.0)
	SHAKE_OFFSET.y = randf_range(-1.0, 1.0)
	SHAKE_OFFSET.z = randf_range(-1.0, 1.0)
	
	SHAKE_OFFSET *= shake_intensity
	
	# Apply to position
	$Fist/Fist.position = BASE_POSITION + SHAKE_OFFSET


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
	
	IS_RELEASED = true
	area_push()
	$Cooldown.start()
	$CooldownEffect.play_full_cooldown_effect()
	$AnimationPlayer.play("release")
	$Woosh.play()
	
	await $AnimationPlayer.animation_finished
	$Fist.hide()
	$AnimationPlayer.play("idle")
	$Fist/Fist.scale = Vector3(1, 1, 1)
	$Fist/Fist.material_override.albedo_color = Color(0.54, 0.4, 1.0)
	$Fist/Fist.material_override.emission = Color(0.05, 0.29, 1.0)


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
	$Impact.play()


func _on_cooldown_timeout() -> void:
	POWER_LEVEL = 0
	IS_ACTIVE = false
	IS_RELEASED = false
	$Fist.show()
	$AnimationPlayer.play("idle")


func _on_power_up_timer_1_timeout() -> void:
	POWER_LEVEL = 2
	$Fist/Fist.scale = Vector3(1.2, 1.2, 1.2)
	$Fist/Fist.material_override.albedo_color = Color(0.9, 0.4, 1.0)
	$Fist/Fist.material_override.emission = Color(0.7, 0.2, 0.5)
	$PowerUpTimer2.start()
	$PowerUp.play()


func _on_power_up_timer_2_timeout() -> void:
	POWER_LEVEL = 3
	$Fist/Fist.scale = Vector3(1.5, 1.5, 1.5)
	$Fist/Fist.material_override.albedo_color = Color(1.0, 0.2, 0.2)
	$Fist/Fist.material_override.emission = Color(1.0, 0.2, 0.2)
	$PowerUp.play()
