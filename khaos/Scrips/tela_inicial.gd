extends Control

func _ready() -> void:
	for button in get_tree().get_nodes_in_group("butao"):
		button.connect("pressed", self, "on_button_pressed", [botao])
		button.connect("mouse_exited", self, "mouse_interaction", [botao, "exited"])
		button.connect("mouse_entered", self, "mouse_interaction", [botao, "entered"])

func mouse_interaction(button: Button, state: String) -> void:
	match state:
		"entered":
			can_click = true
			button.modulate.a = .5
				
		"exited":
			can_click = false
			button.modulate.a = 1.0
			
func on_button_pressed(button: Button) -> void:
	match button.name:
		"Campanha":
			var _game: bool = get_tree().chage_scene("res://Cenas/game.tscn")
		"Sair":
		 	get_tree().quit()
			
