class_name Creature extends CharacterBody3D

enum FACTION {ALLY,NEUTRAL,ENEMY}
@export var faction : FACTION = FACTION.NEUTRAL

enum LOCOMOTIVE_STATE {IDLE,WALKING,WALKING_BACKWARDS,RUNNING,SNEAKING,SNEAK_RUN,JUMPING,FALLING}
var locomotive_state : LOCOMOTIVE_STATE = LOCOMOTIVE_STATE.IDLE

const FALL_SPEED : float = 9.8

var move_speed : float = 2.0
var jump_velocity : float = 80.0

@export_group("Animation Settings")
@export var idle_anim_string : String = "Idle_1"
@export var walk_anim_string : String = "Walk_1"
@export var jump_anim_string : String = "TPose"
@export var fall_anim_string : String = "TPose"
@export var run_anim_string : String = "Walk_Old"
@export var sneak_anim_string : String = "Walk_Old"

@export_group("Components")
@export var rig : Node3D
@export var collision_shape : CollisionShape3D
@export var animation_player : AnimationPlayer
@export var fall_timer : Timer
@export var down_ray : RayCast3D
@export var grounding_ray : RayCast3D
@export var slope_ray : RayCast3D

func _process(_delta: float) -> void:
	manage_locomotion_animations()

func manage_locomotion_animations() -> void:
	if locomotive_state == LOCOMOTIVE_STATE.FALLING:
		if fall_timer.is_stopped():
			if animation_player.current_animation != fall_anim_string:
				animation_player.play(fall_anim_string)
	elif locomotive_state == LOCOMOTIVE_STATE.JUMPING:
		if animation_player.current_animation != jump_anim_string:
			animation_player.play(jump_anim_string)
	elif locomotive_state == LOCOMOTIVE_STATE.IDLE:
		if animation_player.current_animation != idle_anim_string:
			animation_player.play(idle_anim_string)
	elif locomotive_state == LOCOMOTIVE_STATE.WALKING:
		if animation_player.current_animation != walk_anim_string:
			animation_player.play(walk_anim_string)
	elif locomotive_state == LOCOMOTIVE_STATE.WALKING_BACKWARDS:
		if animation_player.current_animation != walk_anim_string:
			animation_player.play(walk_anim_string,-1,-CharacterController.BACKWARD_MOVEMENT_MODIFIER,true)
	elif locomotive_state == LOCOMOTIVE_STATE.SNEAK_RUN:
		if animation_player.current_animation != sneak_anim_string:
			animation_player.play(sneak_anim_string,-1,CharacterController.SNEAK_RUN_MODIFIER)
	elif locomotive_state == LOCOMOTIVE_STATE.SNEAKING:
		if animation_player.current_animation != sneak_anim_string:
			animation_player.play(sneak_anim_string,-1,CharacterController.SNEAKING_SPEED_MODIFIER)
	elif locomotive_state == LOCOMOTIVE_STATE.RUNNING:
		if animation_player.current_animation != run_anim_string:
			animation_player.play(run_anim_string,-1,CharacterController.RUNNING_SPEED_MODIFIER)
