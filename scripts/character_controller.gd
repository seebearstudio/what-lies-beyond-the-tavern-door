class_name CharacterController extends Object

	# <TODO>
	# [ x ] Handle player getting stuck on too steep of terrain <- I think the creature collider naturally does this now that the slope ray is positioned lower down the creature collider
	# [ / ] Add slope traversing - currently working as intended while moving forward - either need to add additional ray for backward slope walking, or shift position of current one when moving backward
	# [ / ] Add stair climbing - same note as slope traversing, however there is a jitter while moving on steps that would be nice to eliminate
	# [ x ] Fix launching of character when rotating on stairs
	# [   ] Fix creature collision shape from hovering after stepping off of elevation. Likely need to revist state machine.
	# [   ] Add obstacle hurdling
	# [   ] Add wall climbing

const DECELERATION_SPEED : float = 3.5
const ROTATE_SPEED : float = 2.0
const BACKWARD_MOVEMENT_MODIFIER : float = 0.5
const SLOPE_MAX_ANGLE : float = 45.0
const SLOPE_RAY_OFFSET : float = 0.5 # this needs to be the distance the ray is from the origin of the Creature. Could be set programatically... but just don't move it without updating this value.

static var on_slope : bool = false

# Called in game.gd
static func handle_physics_loop(_creature : Creature,_delta : float) -> void:
	handle_slopes(_creature)
	handle_gravity(_creature)
	prevent_endless_slide(_creature)
	if not _creature.locomotive_state == Creature.LOCOMOTIVE_STATE.FALLING:
		handle_rotation(_creature,_delta)
		handle_movement(_creature)
		handle_stairs(_creature)
	if not _creature.locomotive_state == Creature.LOCOMOTIVE_STATE.IDLE:
		_creature.move_and_slide()
	ground_rig(_creature)

static func handle_slopes(_creature : Creature) -> void:
	if _creature.slope_ray.is_colliding():
		if abs(get_angle(_creature)) <= SLOPE_MAX_ANGLE / 100:
			if not on_slope:
				on_slope = true
		else:
			if on_slope:
				on_slope = false

static func get_angle(_creature : Creature) -> float:
	var tangent : float = SLOPE_RAY_OFFSET / _creature.slope_ray.get_collision_point().y
	return tangent

static func handle_gravity(_creature : Creature) -> void:
	if _creature.down_ray.is_colliding():
		var collision := _creature.down_ray.get_collider()
		if collision is StaticBody3D:
			if _creature.locomotive_state == Creature.LOCOMOTIVE_STATE.FALLING:
				_creature.fall_timer.stop()
				set_locomotive_state(_creature,Creature.LOCOMOTIVE_STATE.IDLE)
	else:
		if not _creature.slope_ray.is_colliding():
			# Falling
			if not _creature.locomotive_state == Creature.LOCOMOTIVE_STATE.FALLING:
				_creature.fall_timer.start()
				set_locomotive_state(_creature,Creature.LOCOMOTIVE_STATE.FALLING)
			_creature.velocity.y = Vector3.DOWN.y * _creature.FALL_SPEED
		else:
			# Slope movement - if creature.slope_ray is colliding and the angle is traversable
			if on_slope:
				_creature.velocity += (Vector3.FORWARD * _creature.move_speed) + (Vector3.UP * _creature.slope_ray.get_collision_point())

static func set_locomotive_state(_creature : Creature,_state : Creature.LOCOMOTIVE_STATE) -> void:
	if not _creature.locomotive_state == _state:
		_creature.locomotive_state = _state
		#print_debug(str(_creature.name) + " locomotive state set to " + str(Creature.LOCOMOTIVE_STATE.keys()[_state]))

static func handle_rotation(_creature : Creature, _delta : float) -> void:
	var input_dir = Input.get_axis("ROTATE_LEFT", "ROTATE_RIGHT")
	# Rounds up to a whole value to ensure same behaivor across differnt input devices (keyboard, controller, etc)
	if input_dir < 0.0:
		input_dir = -1.0
	elif input_dir > 0.0:
		input_dir = 1.0
	if input_dir != 0:
		if _creature.locomotive_state == Creature.LOCOMOTIVE_STATE.WALKING_BACKWARDS:
			_creature.rotate_y(input_dir * ROTATE_SPEED * _delta)
		else:
			_creature.rotate_y(-input_dir * ROTATE_SPEED * _delta)

static func handle_movement(_creature : Creature) -> void:
	var input_dir : float = Input.get_axis("MOVE_FORWARD","MOVE_BACK")
	# Rounds up to a whole value to ensure same behaivor across differnt input devices (keyboard, controller, etc)
	if input_dir < 0.0:
		input_dir = -1.0
	elif input_dir > 0.0:
		input_dir = 1.0
	var direction : Vector3 = _creature.global_transform.basis.z * input_dir
	if direction:
		if input_dir == -1.0:
			set_locomotive_state(_creature,Creature.LOCOMOTIVE_STATE.WALKING)
			_creature.velocity = direction * _creature.move_speed
		elif input_dir == 1.0:
			set_locomotive_state(_creature,Creature.LOCOMOTIVE_STATE.WALKING_BACKWARDS)
			_creature.velocity = direction * _creature.move_speed * BACKWARD_MOVEMENT_MODIFIER
	else:
		_creature.velocity = Vector3.ZERO
		set_locomotive_state(_creature,Creature.LOCOMOTIVE_STATE.IDLE)

static func prevent_endless_slide(_creature : Creature) -> void:
	if _creature.locomotive_state == Creature.LOCOMOTIVE_STATE.FALLING:
		if _creature.down_ray.is_colliding() or _creature.slope_ray.is_colliding():
			_creature.velocity = Vector3.ZERO
			set_locomotive_state(_creature,Creature.LOCOMOTIVE_STATE.IDLE)

static func handle_stairs(_creature : Creature) -> void:
	if _creature.slope_ray.is_colliding():
		# Collision layer 3 = "Stairs"
		if _creature.slope_ray.get_collider().get_collision_layer_value(3):
			_creature.velocity += (Vector3.FORWARD * SLOPE_RAY_OFFSET) + (Vector3.UP * _creature.slope_ray.get_collision_point())

static func ground_rig(_creature : Creature) -> void:
	if _creature.grounding_ray.is_colliding():
		_creature.rig.global_position.y = lerpf(_creature.rig.global_position.y, _creature.grounding_ray.get_collision_point().y, 1.0)
