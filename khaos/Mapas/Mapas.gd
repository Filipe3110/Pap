extends Node2D
@onready var options = $Options_ingame
@onready var pause_menu = $Menu_pausa
var is_paused = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_menu.visible = false
	options.visible = false


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if is_paused:
			_unpause_game()
		else:
			_pause_game()

func _pause_game():
	is_paused = true
	get_tree().paused = true
	pause_menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _unpause_game():
	is_paused = false
	get_tree().paused = false
	pause_menu.visible = false
	


func _on_options_pressed():
	options.visible = true
	pause_menu.visible = false


func _on_back_pressed() -> void:
	_unpause_game()
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")


func _on_change_map_pressed() -> void:
	_unpause_game()
	get_tree().change_scene_to_file("res://Cenas/Modo_História/Tela_dos_mapas.tscn")


func _on_resume_pressed() -> void:
	_unpause_game()
