extends CharacterBody3D

@export var speed: float = 6.0
@export var jump_force: float = 4.5
@export var gravity: float = 12.0

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Jump
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_force

	# Movement input
	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

	var direction = Vector3.ZERO
	if input_dir.length() > 0:
		# Convert 2D input to 3D based on the player's orientation
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Horizontal movement
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
