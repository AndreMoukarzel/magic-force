extends CharacterBody3D

@export var speed = 5.0
@export var fall_acceleration = 9.8


func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		velocity.y -= fall_acceleration * delta

	move_and_slide()
