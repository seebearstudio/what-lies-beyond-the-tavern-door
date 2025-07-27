class_name Creature extends CharacterBody3D

enum FACTION {ALLY,NEUTRAL,ENEMY}
@export var faction : FACTION = FACTION.NEUTRAL

enum LOCOMOTIVE_STATE {IDLE,WALKING,WALKING_BACKWARDS,RUNNING,FALLING}
var locomotive_state : LOCOMOTIVE_STATE = LOCOMOTIVE_STATE.IDLE

const FALL_SPEED : float = 9.8
var move_speed : float = 2.0

@export_group("Animation Settings")
@export var idle_anim_string : String = "Idle_1"
@export var walk_anim_string : String = "Walk_1"

@export_group("Components")
@export var animation_player : AnimationPlayer
@export var down_ray : RayCast3D

func _ready() -> void:
	global_position = Vector3(roundi(global_position.x),global_position.y,roundi(global_position.z))

func _process(_delta: float) -> void:
	manage_locomotion_animations()

func manage_locomotion_animations() -> void:
	if locomotive_state == LOCOMOTIVE_STATE.IDLE:
		if animation_player.current_animation != idle_anim_string:
			animation_player.play(idle_anim_string)
	elif locomotive_state == LOCOMOTIVE_STATE.WALKING:
		if animation_player.current_animation != walk_anim_string:
			animation_player.play(walk_anim_string)
	elif locomotive_state == LOCOMOTIVE_STATE.WALKING_BACKWARDS:
		if animation_player.current_animation != walk_anim_string:
			animation_player.play_backwards(walk_anim_string)
