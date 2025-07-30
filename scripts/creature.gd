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
@export var fall_anim_string : String = "TPose"

@export_group("Components")
@export var animation_player : AnimationPlayer
@export var fall_timer : Timer
@export var down_ray : RayCast3D
@export var slope_ray : RayCast3D

func _process(_delta: float) -> void:
	manage_locomotion_animations()

func manage_locomotion_animations() -> void:
	if locomotive_state == LOCOMOTIVE_STATE.FALLING:
		if fall_timer.is_stopped():
			if animation_player.current_animation != fall_anim_string:
				animation_player.play(fall_anim_string)
	elif locomotive_state == LOCOMOTIVE_STATE.IDLE:
		if animation_player.current_animation != idle_anim_string:
			animation_player.play(idle_anim_string)
	elif locomotive_state == LOCOMOTIVE_STATE.WALKING:
		if animation_player.current_animation != walk_anim_string:
			animation_player.play(walk_anim_string)
	elif locomotive_state == LOCOMOTIVE_STATE.WALKING_BACKWARDS:
		if animation_player.current_animation != walk_anim_string:
			animation_player.play_backwards(walk_anim_string)
