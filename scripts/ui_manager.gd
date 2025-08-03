class_name UiManager extends Control

@export var debug_active : bool = false
@export var locomotive_state_label : Label
@export var game : Game
@export var ui_debug : Control

func _process(_delta: float) -> void:
	if debug_active:
		if not ui_debug.visible:
			ui_debug.visible = true
		update_locomotive_state_label(game.player_creature.locomotive_state)
	else:
		if ui_debug.visible:
			ui_debug.visible = false

func update_locomotive_state_label(_state : Creature.LOCOMOTIVE_STATE) -> void:
	if not locomotive_state_label.text == str(Creature.LOCOMOTIVE_STATE.keys()[_state]):
		locomotive_state_label.text = "Locomotive State " + "[" + str(Creature.LOCOMOTIVE_STATE.keys()[_state]) + "]"
