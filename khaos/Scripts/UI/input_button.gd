extends Button  

@onready var action_label = $MarginContainer/HBoxContainer/ActionLabel
@onready var input_label = $InputLabel

var action_name: String = ""
var is_waiting_for_input: bool = false

func set_action_name(action: String):
	action_name = action
	action_label.text = action_name.capitalize()
	update_key_display()

func update_key_display():
	if not InputMap.has_action(action_name):
		return
	
	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		var key_text = events[0].as_text()
		key_text = key_text.replace(" (Physical)", "")
		input_label.text = key_text
	else:
		input_label.text = "Não definido"

func _on_pressed():
	if is_waiting_for_input:
		return
	
	input_label.text = "Press a key"
	is_waiting_for_input = true
	set_process_unhandled_key_input(true)
	modulate = Color(0.8, 0.8, 0.8)

func _unhandled_key_input(event):
	if not is_waiting_for_input:
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode != KEY_ESCAPE:
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, event)
		
		is_waiting_for_input = false
		set_process_unhandled_key_input(false)
		update_key_display()
		modulate = Color(1, 1, 1)
