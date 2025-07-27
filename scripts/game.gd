class_name Game extends Node

enum GAME_STATE {INIT,RUN,PAUSE}
static var game_state : GAME_STATE = GAME_STATE.RUN
static var using_controller : bool = false

@export var player_creature : Creature = null
@export var camera_rig : CameraRig = null

# GAME LOOP

func _physics_process(delta: float) -> void:
	if game_state == GAME_STATE.RUN:
		if player_creature is Creature and player_creature != null:
			CharacterController.handle_physics_loop(player_creature,delta)

static func set_game_state(_game_state : GAME_STATE) -> void:
	game_state = _game_state

static func set_using_controller(_using_controller : bool) -> void:
	using_controller = _using_controller
