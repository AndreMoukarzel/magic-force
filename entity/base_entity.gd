extends CharacterBody3D


@export var SPEED: float = 5.0
@export var ACC: float = 15.0
@export var ACC_AIR: float = 2.0
@export var RISE_ACC: float = 10.0
@export var FALL_ACC: float = 18.5
@export var KNOCKBACK_DECAY: float = 15.0
var KNOCKBACK: Vector3 = Vector3.ZERO


func _physics_process(delta: float) -> void:
	var direction: Vector3 = Vector3()

	if is_on_floor():
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACC * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACC * delta)
	else:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACC_AIR * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACC_AIR * delta)
		_apply_gravity(delta)
	
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


func apply_knockback(force: Vector3) -> void:
	KNOCKBACK = force
