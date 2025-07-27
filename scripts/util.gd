extends Node

func show_node(_node : Node) -> void:
	_node.visible = true

func hide_node(_node : Node) -> void:
	_node.visible = false

func play_animation(_animation_name : String, _animation_player : AnimationPlayer) -> void:
	if not _animation_player.current_animation == _animation_name:
		_animation_player.play(_animation_name, 0.5, 1.0)

func clear_children(_node : Node) -> void:
	for child in _node.get_children():
		child.queue_free()

func tween(_node3D : Node3D, _property : String, _destination : Vector3, _tween_time : float, _tween_easing : Tween.EaseType = Tween.EASE_IN_OUT) -> void:
	var _tween : Tween = create_tween()
	_tween.set_ease(_tween_easing)
	_tween.tween_property(_node3D,_property,_destination,_tween_time)
