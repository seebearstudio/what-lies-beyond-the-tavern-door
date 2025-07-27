class_name CameraRig extends Node3D

@export var tmp_target : Creature
@export var camera : Camera3D
@export var spring_arm : SpringArm3D
@export var movement_ray : RayCast3D
@export var camera_tracker_area : Area3D

const MOVE_SPEED : float = 3.5
const ROTATE_SPEED : float = 25.0
const ZOOM_SPEED : float = 150.0
const MIN_ZOOM : float = 2.0
const MAX_ZOOM : float = 10.0

var target : Node3D
var wheel_pressed : bool = false
var below_water : bool = false

func _ready() -> void:
	set_target(tmp_target)

func _physics_process(delta: float) -> void:
	monitor_if_above_water()
	follow_target(target,delta)

func _input(event: InputEvent) -> void:
	var delta : float = get_physics_process_delta_time()
	if not Game.using_controller:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				spring_arm.spring_length -= 0.1 * ZOOM_SPEED * delta
				if spring_arm.spring_length <= MIN_ZOOM:
					spring_arm.spring_length = MIN_ZOOM
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				spring_arm.spring_length += 0.1 * ZOOM_SPEED * delta
				if spring_arm.spring_length >= MAX_ZOOM:
					spring_arm.spring_length = MAX_ZOOM
			elif event.button_index == 3:
				if not wheel_pressed:
					if event.is_pressed():
						wheel_pressed = true
				else:
					if event.is_released():
						wheel_pressed = false
		if event is InputEventMouseMotion:
			if wheel_pressed:
				rotate_camera(event.velocity,delta)

func set_target(_target : Node3D) -> void:
	target = _target

func monitor_if_above_water() -> void:
	if camera_tracker_area.get_overlapping_areas():
		for area in camera_tracker_area.get_overlapping_areas():
			if area.get_parent_node_3d() is TerrainWater:
				if not below_water:
					below_water = true
					print_debug("camera is below water")
			else:
				if below_water:
					below_water = false
					print_debug("camera is above water")
	else:
		if below_water:
			below_water = false
			print_debug("camera is above water")

func follow_target(_target : Node3D,_delta : float) -> void:
	global_position = global_position.lerp(_target.global_position, MOVE_SPEED * _delta)

func rotate_camera(_velocity : Vector2,_delta : float) -> void:
	if abs(_velocity.x) > abs(_velocity.y):
		if _velocity.x < 0:
			global_rotation.y = lerpf(global_rotation.y, global_rotation.y + 0.1, ROTATE_SPEED * _delta)
		elif _velocity.x > 0:
			global_rotation.y = lerpf(global_rotation.y, global_rotation.y - 0.1, ROTATE_SPEED * _delta)
	else:
		if _velocity.y < 0:
			spring_arm.global_rotation.x = lerpf(spring_arm.global_rotation.x, spring_arm.global_rotation.x + 0.1, ROTATE_SPEED * _delta)
		elif _velocity.y > 0:
			spring_arm.global_rotation.x = lerpf(spring_arm.global_rotation.x, spring_arm.global_rotation.x - 0.1, ROTATE_SPEED * _delta)
