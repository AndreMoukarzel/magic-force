extends CharacterBody3D

@export_enum("A", "B") var TEAM: String = "A"

@export var SPEED: float = 5.0
@export var ACC: float = 15.0
@export var ACC_AIR: float = 2.0
@export var RISE_ACC: float = 10.0
@export var FALL_ACC: float = 18.5
@export var KNOCKBACK_DECAY: float = 15.0
@export var ROT_ACC: float = 3.5
@export var ROT_ACC_AIR: float = 1.2
@export var MASS: float = 45.0

@onready var CAM: Camera3D = $CameraSpring/Camera3D
@onready var CHAR: Node3D = $Mage
@onready var HAND_SPRING: SpringArm3D = $HandSpring

const BASE_FOV := 75.0
const MAX_EXTRA_FOV := 20.0
const SPEED_FOR_MAX_FOV := 25.0
const FOV_SMOOTHNESS := 8.0

var KNOCKBACK: Vector3 = Vector3.ZERO
var MOVE_DIR: Vector2 = Vector2.ZERO


func _ready() -> void:
	$FistPush.connect("pushed_self", $Mage/ChubbyMage.push_cape_up)


func apply_impulse(force: Vector3) -> void:
	apply_knockback(force/MASS)


func apply_knockback(force: Vector3) -> void:
	KNOCKBACK = force


func _physics_process(delta: float) -> void:
	MOVE_DIR = Input.get_vector("left", "right", "forward", "back")
	var direction: Vector3 = (transform.basis * Vector3(MOVE_DIR.x, 0, MOVE_DIR.y)).normalized()
	var cam_rot: Vector3 = CAM.global_rotation
	var inv_rot: Vector3 = inverted_rotation(cam_rot)
	
	direction = direction.rotated(Vector3.UP, cam_rot.y)
	#CHAR.global_rotation.y = cam_rot.y
	HAND_SPRING.rotation = inv_rot
	$ProjectileGrab.rotation = cam_rot
	$FistPush.rotation = cam_rot
	$Mage/ChubbyMage.direct_head($HandSpring/Hand, delta)
	$Mage/ChubbyMage.update_animation_parameters(velocity, is_on_floor(), is_on_floor() and velocity.y > 0)
	
	if is_on_floor():
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACC * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACC * delta)
		
		# Keep character upright
		CHAR.global_rotation.x = move_toward(CHAR.global_rotation.x, 0.0, ROT_ACC * delta)
		CHAR.global_rotation.z = move_toward(CHAR.global_rotation.z, 0.0, ROT_ACC * delta)

		# Rotate toward movement direction
		if direction.length() > 0.01:
			var target_yaw := atan2(-direction.x, -direction.z)

			CHAR.global_rotation.y = rotate_toward(
				CHAR.global_rotation.y,
				target_yaw,
				ROT_ACC * delta
		)
		
		# Resets camera's FOV
		CAM.fov = lerp(CAM.fov, 75.0, FOV_SMOOTHNESS * delta)
		# Resets air audio
		$AirSpeedSFX.volume_db = lerp($AirSpeedSFX.volume_db, -80.0, FOV_SMOOTHNESS * delta)
	else:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACC_AIR * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACC_AIR * delta)
		CHAR.global_rotation.x = move_toward(CHAR.global_rotation.x, cam_rot.x, ROT_ACC_AIR * delta)
		CHAR.global_rotation.y = move_toward(CHAR.global_rotation.y, cam_rot.y, ROT_ACC_AIR * delta)
		CHAR.global_rotation.z = move_toward(CHAR.global_rotation.z, cam_rot.z, ROT_ACC_AIR * delta)
		_apply_gravity(delta)
		_update_fov(CAM, delta)
	
	# Apply knockback
	if KNOCKBACK.length() > 0.1:
		if direction:
			var horizontal_knockback = KNOCKBACK.project(Vector3(1, 0, 1)).normalized()
			var dot = direction.dot(horizontal_knockback)
			var angle = acos(clamp(dot, -1.0, 1.0)) # angle in radians between 0 and pi
			var angle_factor = sin(angle) # 0 when parallel, 1 when perpendicular
			var boost = lerp(1.0, 2.5, angle_factor) # more boost when orthogonal
			velocity.x = move_toward(velocity.x, direction.x * SPEED, boost * ACC_AIR * delta)
			velocity.z = move_toward(velocity.z, direction.z * SPEED, boost * ACC_AIR * delta)
		
		velocity += KNOCKBACK
		KNOCKBACK = KNOCKBACK.lerp(Vector3.ZERO, delta * KNOCKBACK_DECAY) # smooth decay
	
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if velocity.y > 0:
		# Ascending: lower gravity for slower upward deceleration
		velocity.y -= RISE_ACC * delta
	else:
		# Descending: higher gravity for faster, snappier fall
		velocity.y -= FALL_ACC * delta
		if $Float.is_active and velocity.y <= -$Float.FLOAT_SPEED:
				velocity.y = -$Float.FLOAT_SPEED


func _update_fov(Cam: Camera3D, delta: float) -> void:
	## Changes the Camera's FOV based on the user's speed in the air
	var speed := velocity.length()
	
	# Convert speed into a 0-1 range
	var speed_ratio: float = clamp(speed / SPEED_FOR_MAX_FOV, 0.0, 1.0)
	
	# Calculate desired FOV
	var target_fov: float = BASE_FOV + (MAX_EXTRA_FOV * speed_ratio)
	
	# Smoothly interpolate to target
	Cam.fov = lerp(Cam.fov, target_fov, FOV_SMOOTHNESS * delta)
	
	_adjust_air_speed_sfx(speed_ratio, delta)


func _adjust_air_speed_sfx(speed_ratio: float, delta: float) -> void:
	if !$AirSpeedSFX.playing:
		$AirSpeedSFX.play()
	
	var target_volume_db := -80.0

	var volume_ratio: float = clampf(
		inverse_lerp(0.0, .8, speed_ratio),
		0.0, 1.0
	)
	target_volume_db = lerp(-80.0, -20.0, volume_ratio)

	$AirSpeedSFX.volume_db = lerp(
		$AirSpeedSFX.volume_db,
		target_volume_db,
		FOV_SMOOTHNESS * delta
	)


func inverted_rotation(base_rotation: Vector3) -> Vector3:
	# Get a rotation (like the camera's) and gets basically the
	# rotation that it is pointing to
	return Vector3(-base_rotation.x, base_rotation.y + PI, 0)


@rpc("call_local")
func force_release_grab():
	$ProjectileGrab.forced_release()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_action"):
		$ProjectileGrab.grab()
	
	if event.is_action_pressed("secondary_action"):
		$FistPush.activate()
	elif event.is_action_released("secondary_action"):
		$FistPush.release()
	
	if event.is_action_pressed("movement_action"):
		if is_on_floor():
			$Jump.jump(MOVE_DIR)
			$Mage/ChubbyMage.push_cape_up()
		else:
			$Float.activate()
	elif event.is_action_released("movement_action"):
		if not is_on_floor():
			$Float.deactivate()
