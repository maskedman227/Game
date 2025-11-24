extends CharacterBody3D

@export var max_speed: float = 7.0
@export var acceleration: float = 20.0
@export var deceleration: float = 16.0
@export var air_acceleration: float = 6.0
@export var air_deceleration: float = 4.0
@export var jump_velocity: float = 4.5

@export var camera_rig: Node3D  # <-- drag your CameraRig here

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	# ---------------------------- Gravity ----------------------------
	if not is_on_floor():
		velocity.y -= gravity * delta

	# ---------------------------- Input ----------------------------
	var input_vec := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var move_dir := Vector3.ZERO

	if input_vec != Vector2.ZERO:
		var cam_forward := -camera_rig.global_transform.basis.z
		cam_forward.y = 0
		cam_forward = cam_forward.normalized()

		var cam_right := camera_rig.global_transform.basis.x
		cam_right.y = 0
		cam_right = cam_right.normalized()

		move_dir = (cam_forward * input_vec.y + cam_right * input_vec.x).normalized()

	# ---------------------- Smooth Zelda Rotation ----------------------
	if move_dir != Vector3.ZERO:
		var dot := move_dir.dot(-camera_rig.global_transform.basis.z)
		if dot > -0.2:
			var clean_current := global_transform.basis.orthonormalized()
			var current_quat := Quaternion(clean_current)

			var target_basis := Basis().looking_at(move_dir, Vector3.UP).orthonormalized()
			var target_quat := Quaternion(target_basis)

			var smooth := current_quat.slerp(target_quat, delta * 8.0)
			var s = global_transform.basis.get_scale()
			global_transform.basis = Basis(smooth).orthonormalized().scaled(s)
	# ---------------------- Accel & Decel ----------------------
	var horizontal := velocity
	horizontal.y = 0

	if move_dir != Vector3.ZERO:
		var accel := acceleration if is_on_floor() else air_acceleration
		horizontal = horizontal.move_toward(move_dir * max_speed, accel * delta)
	else:
		var decel := deceleration if is_on_floor() else air_deceleration
		horizontal = horizontal.move_toward(Vector3.ZERO, decel * delta)

	velocity.x = horizontal.x
	velocity.z = horizontal.z

	# ---------------------- Jump ----------------------
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
