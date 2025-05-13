extends Node2D
@onready var options = $Options_ingame
@onready var pause_menu = $Menu_pausa
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var vitoria_canvas = $Vitoria  
@onready var vitoria_label = $Vitoria/VitoriaLabel
var is_paused = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_menu.visible = false
	options.visible = false
	vitoria_canvas.visible = false  

	p1.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))
	p2.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))

func _on_jogador_morreu(jogador_id):
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var cor = Color.WHITE

	var vencedor = "Player 2" if jogador_id == "Player1" else "Player 1"
	if vencedor == "Player 1":
		vitoria_label.text = "[color=#0000FF]Player 1[/color] Win"
	else:
		vitoria_label.text = "[color=#FF0000]Player 2[/color] Win"


	vitoria_canvas.visible = true
	pause_menu.visible = false  # Garante que o menu de pausa está oculto
	options.visible = false     # Garante que as opções estão ocultas

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
	get_tree().change_scene_to_file("res://Cenas/Multijogador/multijogador.tscn")


func _on_resume_pressed() -> void:
	_unpause_game()


func _on_restart_pressed() -> void:
	_unpause_game()
	get_tree().reload_current_scene()
