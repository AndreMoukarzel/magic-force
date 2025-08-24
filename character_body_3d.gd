extends CharacterBody3D

@export var SPEED: float = 5.0
@export var fall_acceleration = 9.8

@onready var CAM: Camera3D = $CameraSpring/Camera3D
@onready var CHAR: Node3D = $Mage
@onready var HAND_SPRING: SpringArm3D = $HandSpring
var knockback: Vector3 = Vector3.ZERO

func apply_knockback(force: Vector3) -> void:
	knockback = force


func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var cam_rot: Vector3 = CAM.global_rotation
	var inv_rot: Vector3 = inverted_rotation(cam_rot)
	
	direction = direction.rotated(Vector3.UP, cam_rot.y)
	CHAR.global_rotation.y = cam_rot.y + PI/2
	HAND_SPRING.rotation = inv_rot
	$ForcePush.rotation = inv_rot

	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.y -= fall_acceleration * delta
	
	# Apply knockback (decays over time if desired)
	if knockback.length() > 0.1:
		velocity += knockback
		knockback = knockback.lerp(Vector3.ZERO, delta * 5.0) # smooth decay

	move_and_slide()


func inverted_rotation(base_rotation: Vector3) -> Vector3:
	# Get a rotation (like the camera's) and gets basically the
	# rotation that it is pointing to
	return Vector3(-base_rotation.x, base_rotation.y + PI, 0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_action"):
		$ForceGrab.grab()
	elif event.is_action_released("primary_action"):
		$ForceGrab.release()
	
	if event.is_action_pressed("secondary_action"):
		$ForcePush.area_push()
