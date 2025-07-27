class_name CharacterController extends Object

const DECELERATION_SPEED : float = 3.5
const ROTATE_SPEED : float = 2.0
const BACKWARD_MOVEMENT_MODIFIER : float = 0.5

static func handle_physics_loop(_creature : Creature, _delta : float) -> void:
	handle_gravity(_creature,_delta)
	if not _creature.locomotive_state == Creature.LOCOMOTIVE_STATE.FALLING:
		handle_rotation(_creature,_delta)
		handle_movement(_creature,_delta)
	if not _creature.locomotive_state == Creature.LOCOMOTIVE_STATE.IDLE:
		_creature.move_and_slide()

static func handle_gravity(_creature : Creature, _delta : float) -> void:
	if _creature.down_ray.is_colliding():
		var collision := _creature.down_ray.get_collider()
		if collision is StaticBody3D:
			if _creature.locomotive_state == Creature.LOCOMOTIVE_STATE.FALLING:
				set_locomotive_state(_creature,Creature.LOCOMOTIVE_STATE.IDLE)
	else:
		set_locomotive_state(_creature,Creature.LOCOMOTIVE_STATE.FALLING)
		_creature.velocity.y = Vector3.DOWN.y * _creature.FALL_SPEED

static func set_locomotive_state(_creature : Creature,_state : Creature.LOCOMOTIVE_STATE) -> void:
	if not _creature.locomotive_state == _state:
		_creature.locomotive_state = _state
		print_debug(str(_creature.name) + " locomotive state set to " + str(Creature.LOCOMOTIVE_STATE.keys()[_state]))

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

static func handle_movement(_creature : Creature,_delta : float) -> void:
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
		set_locomotive_state(_creature,Creature.LOCOMOTIVE_STATE.IDLE)
