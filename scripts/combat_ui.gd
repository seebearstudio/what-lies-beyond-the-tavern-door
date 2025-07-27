class_name CombatUI extends Control

enum BUTTONS {MOVE,ATTACK,END,ACCEPT,CANCEL}

@export var combat_manager : CombatManager
@export var click_to_move : ClickToMove
@export var range_indicator_manager : RangeIndicatorManager
@export var click_timer : Timer

@export_group("Buttons")
@export var buttons : Dictionary[BUTTONS,Button]

var completed_turn_actions : Array[CombatManager.TURN_ACTIONS] = []

func _ready() -> void:
	Util.hide_node(self)
	buttons[BUTTONS.MOVE].pressed.connect(move_button_pressed)
	buttons[BUTTONS.ATTACK].pressed.connect(attack_button_pressed)
	buttons[BUTTONS.END].pressed.connect(end_buton_pressed)
	buttons[BUTTONS.ACCEPT].pressed.connect(accept_button_pressed)
	buttons[BUTTONS.CANCEL].pressed.connect(cancel_button_pressed)

func _process(_delta: float) -> void:
	handle_button_states()

func handle_button_states() -> void:

	match combat_manager.combat_state:

		combat_manager.COMBAT_STATE.NONE:
			Util.hide_node(self)

		combat_manager.COMBAT_STATE.TURN_MENU_ROOT:
			display_buttons([buttons[BUTTONS.MOVE],buttons[BUTTONS.ATTACK],buttons[BUTTONS.END]])
			if completed_turn_actions.has(CombatManager.TURN_ACTIONS.MOVE):
				Util.hide_node(buttons[BUTTONS.MOVE])
			if completed_turn_actions.has(CombatManager.TURN_ACTIONS.ATTACK):
				Util.hide_node(buttons[BUTTONS.ATTACK])

		combat_manager.COMBAT_STATE.MOVE:
			if click_to_move.moving:
				display_buttons([])
			else:
				if combat_manager.participants[combat_manager.active_participant].global_position == combat_manager.turn_position_origin:
					display_buttons([buttons[BUTTONS.CANCEL]])
				else:
					display_buttons([buttons[BUTTONS.ACCEPT],buttons[BUTTONS.CANCEL]])

		combat_manager.COMBAT_STATE.ATTACK:
			display_buttons([buttons[BUTTONS.CANCEL]])

func display_buttons(_visible_buttons : Array[Button]) -> void:
	for _button in buttons:
		if _visible_buttons.has(buttons[_button]):
			Util.show_node(buttons[_button])
		else:
			Util.hide_node(buttons[_button])

func move_button_pressed() -> void:
	if click_timer.is_stopped():
		click_timer.start()
		combat_manager.set_combat_state(combat_manager.COMBAT_STATE.MOVE)

func attack_button_pressed() -> void:
	if click_timer.is_stopped():
		click_timer.start()
		combat_manager.set_combat_state(combat_manager.COMBAT_STATE.ATTACK)

func end_buton_pressed() -> void:
	if click_timer.is_stopped():
		click_timer.start()
		combat_manager.end_turn()

func accept_button_pressed() -> void:
	if click_timer.is_stopped():
		click_timer.start()
		match combat_manager.combat_state:
			combat_manager.COMBAT_STATE.MOVE:
				range_indicator_manager.clear()
				completed_turn_actions.append(CombatManager.TURN_ACTIONS.MOVE)
				combat_manager.set_combat_state(combat_manager.COMBAT_STATE.TURN_MENU_ROOT)

func cancel_button_pressed() -> void:
	if click_timer.is_stopped():
		click_timer.start()
		match combat_manager.combat_state:
			combat_manager.COMBAT_STATE.MOVE:
				if combat_manager.participants[combat_manager.active_participant].global_position == combat_manager.turn_position_origin:
					range_indicator_manager.clear()
					combat_manager.set_combat_state(combat_manager.COMBAT_STATE.TURN_MENU_ROOT)
				else:
					combat_manager.set_combat_state(combat_manager.COMBAT_STATE.MOVE)
					click_to_move.return_to_origin(combat_manager.turn_position_origin)
			combat_manager.COMBAT_STATE.ATTACK:
				range_indicator_manager.clear()
				combat_manager.set_combat_state(combat_manager.COMBAT_STATE.TURN_MENU_ROOT)
