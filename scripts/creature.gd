class_name Creature extends CharacterBody3D

enum FACTION {ALLY,NEUTRAL,ENEMY}
@export var faction : FACTION = FACTION.NEUTRAL

enum LOCOMOTIVE_STATE {IDLE,WALKING,RUNNING,FALLING}
var locomotive_state : LOCOMOTIVE_STATE = LOCOMOTIVE_STATE.IDLE

const FALL_SPEED : float = 9.8
var on_ground : bool = true
var move_speed : float = 2.0

@export_group("Animation Settings")
@export var idle_anim_string : String = "Idle_1"
@export var walk_anim_string : String = "Walk_1"

@export_group("Components")
@export var animation_player : AnimationPlayer
@export var down_ray : RayCast3D

func _ready() -> void:
	global_position = Vector3(roundi(global_position.x),global_position.y,roundi(global_position.z))
	animation_player.play(idle_anim_string)
