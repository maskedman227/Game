# CameraRig follow script
extends Node3D

@export var target: Node3D
@export var follow_speed := 10.0
@export var distance := 10.0
@export var height := 2.0

@onready var cam: Camera3D = $Camera3D

func _process(delta: float) -> void:
	if target == null:
		return
		
	var forward: Vector3 = -target.global_transform.basis.z.normalized()
	
	var desired_pos: Vector3 = target.global_transform.origin \
		- forward * distance \
		+ Vector3.UP * height

	global_transform.origin = global_transform.origin.lerp(
		target.global_transform.origin,
		delta * follow_speed
	)
	
	var look_target: Vector3 = target.global_transform.origin + forward * 1.5
	cam.look_at(look_target, Vector3.UP)	
