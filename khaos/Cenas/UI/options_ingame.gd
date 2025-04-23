extends CanvasLayer

var COLLECTION_ID = "khaos_stats"

@onready var input_buton_scene = preload("res://Cenas/UI/input_button.tscn")
@onready var p1 = $"Butões/Player"
@onready var p2 = $"Butões/Player2"
@onready var sounds = $"Butões/Sounds2"
@onready var account = $"Butões/account"

@onready var lp1 = $ScrollContainer/MarginContainer/VBoxContainer/P1
@onready var ct1 = $ScrollContainer/MarginContainer/VBoxContainer/P1Container

@onready var lp2 = $ScrollContainer/MarginContainer/VBoxContainer/P2
@onready var ct2 = $ScrollContainer/MarginContainer/VBoxContainer/P2Container

@onready var lsd = $ScrollContainer/MarginContainer/VBoxContainer/Sounds
@onready var ctsd = $ScrollContainer/MarginContainer/VBoxContainer/SDsContainer

@onready var lauth = $ScrollContainer/MarginContainer/VBoxContainer/Auth
@onready var ctauth = $ScrollContainer/MarginContainer/VBoxContainer/AuthContainer

func _ready():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		load_player_data()
	else:
		load_local_settings()
	setup_input_buttons()
	
func load_player_data():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:  
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.get_doc(auth.localid)
		
		var finished_task: FirestoreTask = await task.task_finished
		var document = finished_task.document
		
		if document and document.doc_fields:
			if document.doc_fields.has("username"): 
				$ScrollContainer/MarginContainer/VBoxContainer/AuthContainer/VBoxContainer/UserName/Name.text = document.doc_fields.username 
			if document.doc_fields.has("email"): 
				$ScrollContainer/MarginContainer/VBoxContainer/AuthContainer/VBoxContainer/ID/MyEmail.text = document.doc_fields.email
			
			# Load controls if they exist
			if document.doc_fields.has("controls"):
				apply_control_settings(document.doc_fields.controls)
				update_all_input_labels()
			else:
				# If no controls are saved yet, use defaults
				reset_to_default_controls()
				update_all_input_labels()
		else:
			# New user with no document yet
			reset_to_default_controls()
			update_all_input_labels()

func save_local_settings():
	var settings = get_current_control_settings()
	var config = ConfigFile.new()
	config.set_value("controls", "settings", settings)
	config.save("user://local_settings.cfg")

func load_local_settings():
	var config = ConfigFile.new()
	var err = config.load("user://local_settings.cfg")
	if err == OK:
		var settings = config.get_value("controls", "settings", {})
		if not settings.is_empty():
			apply_control_settings(settings)
			update_all_input_labels()
		else:
			reset_to_default_controls()
			update_all_input_labels()
	else:
		reset_to_default_controls()
		update_all_input_labels()

func apply_control_settings(settings: Dictionary):
	for action in settings:
		if InputMap.has_action(action):
			var event = InputEventKey.new()
			var key_text = settings[action]
			key_text = key_text.replace(" (Physical)", "")
			var keycode = OS.find_keycode_from_string(key_text)
			if keycode != KEY_NONE:
				event.keycode = keycode
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, event)

func setup_input_buttons():
	# Player 1 controls
	setup_input_button("Left", "left", $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer/VBoxContainer/Left)
	setup_input_button("Right", "right", $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer/VBoxContainer/Right)
	setup_input_button("Jump", "jump", $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer/VBoxContainer/Jump)
	setup_input_button("Down", "down", $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer/VBoxContainer/Down)
	setup_input_button("Attack", "attack", $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer2/VBoxContainer/Attack)
	setup_input_button("Block", "block", $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer2/VBoxContainer/Block)
	
	# Player 2 controls
	setup_input_button("Left", "p2left", $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer/VBoxContainer/Left)
	setup_input_button("Right", "p2right", $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer/VBoxContainer/Right)
	setup_input_button("Jump", "p2jump", $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer/VBoxContainer/Jump)
	setup_input_button("Down", "p2down", $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer/VBoxContainer/Down)
	setup_input_button("Attack", "p2attack", $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer2/VBoxContainer/Attack)
	setup_input_button("Block", "p2block", $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer2/VBoxContainer/Block)

func setup_input_button(display_name: String, action: String, button_node):
	if button_node and button_node.has_method("set_action_name"):
		button_node.action_label.text = display_name
		button_node.set_action_name(action)
		button_node.update_key_display()
	else:
		push_error("Nó do botão inválido ou método não encontrado: " + str(button_node))

func save_control_settings():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var settings = get_current_control_settings()
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		collection.update(auth.localid, {"controls": settings})
		
		# Show success notification
		show_notification("Configurações salvas com sucesso!", Color(0, 1, 0))
	else:
		# No user logged in, save locally
		save_local_settings()
		show_notification("Configurações salvas localmente!", Color(0, 1, 0))

func get_current_control_settings() -> Dictionary:
	var settings = {}
	
	# Player 1 controls
	settings["left"] = InputMap.action_get_events("left")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("left").size() > 0 else ""
	settings["right"] = InputMap.action_get_events("right")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("right").size() > 0 else ""
	settings["jump"] = InputMap.action_get_events("jump")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("jump").size() > 0 else ""
	settings["down"] = InputMap.action_get_events("down")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("down").size() > 0 else ""
	settings["attack"] = InputMap.action_get_events("attack")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("attack").size() > 0 else ""
	settings["block"] = InputMap.action_get_events("block")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("block").size() > 0 else ""
	
	# Player 2 controls
	settings["p2left"] = InputMap.action_get_events("p2left")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("p2left").size() > 0 else ""
	settings["p2right"] = InputMap.action_get_events("p2right")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("p2right").size() > 0 else ""
	settings["p2jump"] = InputMap.action_get_events("p2jump")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("p2jump").size() > 0 else ""
	settings["p2down"] = InputMap.action_get_events("p2down")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("p2down").size() > 0 else ""
	settings["p2attack"] = InputMap.action_get_events("p2attack")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("p2attack").size() > 0 else ""
	settings["p2block"] = InputMap.action_get_events("p2block")[0].as_text().replace(" (Physical)", "") if InputMap.action_get_events("p2block").size() > 0 else ""
	
	return settings

func _on_apply_pressed() -> void:
	save_control_settings()

func _on_reset_pressed() -> void:
	reset_to_default_controls()
	update_all_input_labels()
	show_notification("Configurações redefinidas para padrão!", Color(0, 1, 0))

func show_notification(message: String, color: Color = Color(0, 1, 0)):
	if has_node("NotificationLabel"):
		$NotificationLabel.text = message
		$NotificationLabel.modulate = color 
		$NotificationLabel.visible = true
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(func(): $NotificationLabel.visible = false)

func reset_to_default_controls():
	var default_controls = {
		"left": "A",
		"right": "D",
		"jump": "W",
		"down": "S",
		"attack": "E",
		"block": "Q",
		
		"p2left": "Left",
		"p2right": "Right",
		"p2jump": "Up",
		"p2down": "Down",
		"p2attack": "Enter",
		"p2block": "Shift"
	}
	apply_control_settings(default_controls)

func update_all_input_labels():
	# Define button paths dictionary for cleaner code
	var button_paths = {
		# Player 1 buttons
		"left": $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer/VBoxContainer/Left,
		"right": $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer/VBoxContainer/Right,
		"jump": $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer/VBoxContainer/Jump,
		"down": $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer/VBoxContainer/Down,
		"attack": $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer2/VBoxContainer/Attack,
		"block": $ScrollContainer/MarginContainer/VBoxContainer/P1Container/VBoxContainer/MarginContainer2/VBoxContainer/Block,
		
		# Player 2 buttons
		"p2left": $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer/VBoxContainer/Left,
		"p2right": $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer/VBoxContainer/Right,
		"p2jump": $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer/VBoxContainer/Jump,
		"p2down": $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer/VBoxContainer/Down,
		"p2attack": $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer2/VBoxContainer/Attack,
		"p2block": $ScrollContainer/MarginContainer/VBoxContainer/P2Container/VBoxContainer/MarginContainer2/VBoxContainer/Block
	}
	
	# Update all button labels
	for action in button_paths:
		var button = button_paths[action]
		if button and button.has_method("update_key_display"):
			button.update_key_display()

func switch_user(user_id: String):
	# Load the new user's settings
	var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
	var task: FirestoreTask = collection.get_doc(user_id)
	
	var finished_task: FirestoreTask = await task.task_finished
	var document = finished_task.document
	
	if document and document.doc_fields:
		# Update user info
		if document.doc_fields.has("username"): 
			$ScrollContainer/MarginContainer/VBoxContainer/AuthContainer/VBoxContainer/UserName/Name.text = document.doc_fields.username 
		if document.doc_fields.has("email"): 
			$ScrollContainer/MarginContainer/VBoxContainer/AuthContainer/VBoxContainer/ID/MyEmail.text = document.doc_fields.email
		
		# Load controls
		if document.doc_fields.has("controls"):
			apply_control_settings(document.doc_fields.controls)
			update_all_input_labels()
			show_notification("Configurações do usuário carregadas!", Color(0, 1, 0))
		else:
			# If user has no controls saved yet, use defaults
			reset_to_default_controls()
			update_all_input_labels()
			show_notification("Novo usuário: configurações padrão aplicadas", Color(1, 1, 0))
	else:
		# Handle new user case
		reset_to_default_controls()
		update_all_input_labels()
		show_notification("Novo usuário: configurações padrão aplicadas", Color(1, 1, 0))

# UI Navigation functions
func _on_voltar_pressed() -> void:
	get_parent().options.visible = false
	get_parent().pause_menu.visible = true
	
func _on_options_pressed() -> void:
	lp1.visible = true
	lp2.visible = true 
	
	ct1.visible = true
	ct2.visible = true 
	
	lsd.visible = true
	ctsd.visible = true
	
	lauth.visible = true
	ctauth.visible = true
	
func _on_player_1_pressed() -> void:
	p1.play("player1")
	lp1.visible = true
	ct1.visible = true

	lp2.visible = false 
	ct2.visible = false 

	lsd.visible = false
	ctsd.visible = false

	lauth.visible = false
	ctauth.visible = false

func _on_player_3_pressed() -> void:
	lp2.visible = true 
	ct2.visible = true 

	lp1.visible = false
	ct1.visible = false

	lsd.visible = false
	ctsd.visible = false

	lauth.visible = false
	ctauth.visible = false
	
func _on_sounds_pressed() -> void:
	lsd.visible = true
	ctsd.visible = true
	
	lp1.visible = false
	ct1.visible = false
	
	lp2.visible = false
	ct2.visible = false

	lauth.visible = false
	ctauth.visible = false

func _on_account_2_pressed() -> void:
	lauth.visible = true
	ctauth.visible = true

	lp1.visible = false
	ct1.visible = false
	
	lp2.visible = false
	ct2.visible = false

	lsd.visible = false
	ctsd.visible = false

# Animation hover functions
func _on_player_1_mouse_entered() -> void:
	p1.play("player1")

func _on_player_1_mouse_exited() -> void:
	p1.play("idle")

func _on_player_3_mouse_entered() -> void:
	p2.play("player2")

func _on_player_3_mouse_exited() -> void:
	p2.play("idle")

func _on_sounds_mouse_entered() -> void:
	sounds.play("msc")

func _on_sounds_mouse_exited() -> void:
	sounds.play("idle")

func _on_account_2_mouse_entered() -> void:
	account.play("conta")

func _on_account_2_mouse_exited() -> void:
	account.play("idle")
