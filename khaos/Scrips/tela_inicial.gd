extends Control

func _ready():
	$HBoxContainer/Campanha.pressed.connect(_on_campanha_pressed)
	$HBoxContainer/Controles.pressed.connect(_on_controles_pressed)
	$HBoxContainer/Sair.pressed.connect(_on_sair_pressed)

func _on_controles_pressed():
	get_tree().change_scene_to_file("res://Cenas/controles.tscn")
	
func _on_campanha_pressed():
	get_tree().change_scene_to_file("res://Cenas/game.tscn")

func _on_sair_pressed():
	get_tree().quit()
