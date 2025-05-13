extends Node2D

@onready var options = $Options_ingame
@onready var pause_menu = $Menu_pausa
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var vitoria_canvas = $Vitoria  
@onready var vitoria_label = $Vitoria/VitoriaLabel
@onready var camera = $Camera2D

var is_paused = false

# Tamanho da tela
const SCREEN_WIDTH = 1152
const SCREEN_HEIGHT = 648

# Configurações da câmera horizontal
const MIN_DISTANCE = 200.0
const MAX_DISTANCE = 1200.0
const MIN_MARGIN = SCREEN_WIDTH / 2     # Quando jogadores estão perto
const MAX_MARGIN = 1000.0               # Quando estão muito afastados

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_menu.visible = false
	options.visible = false
	vitoria_canvas.visible = false  

	p1.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))
	p2.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if is_paused:
			_unpause_game()
		else:
			_pause_game()

	if not get_tree().paused:
		_update_camera()

func _update_camera():
	var pos1 = p1.global_position
	var pos2 = p2.global_position

	# Posição central entre os jogadores
	var center_x = (pos1.x + pos2.x) / 2.0
	camera.position.x = center_x
	camera.position.y = SCREEN_HEIGHT / 2  # Fixa verticalmente

	# Distância horizontal entre jogadores
	var distance = abs(pos1.x - pos2.x)

	# Interpola a margem horizontal da câmera com base na distância
	var t = clamp((distance - MIN_DISTANCE) / (MAX_DISTANCE - MIN_DISTANCE), 0.0, 1.0)
	var margin = lerp(float(MIN_MARGIN), float(MAX_MARGIN), t)

	# Define os limites da câmera na horizontal
	camera.limit_left = int(center_x - margin)
	camera.limit_right = int(center_x + margin)

	# Limites verticais fixos
	camera.limit_top = 0
	camera.limit_bottom = SCREEN_HEIGHT

func _pause_game():
	is_paused = true
	get_tree().paused = true
	pause_menu.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unpause_game():
	is_paused = false
	get_tree().paused = false
	pause_menu.visible = false

func _on_jogador_morreu(jogador_id):
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var vencedor = "Player 2" if jogador_id == "Player1" else "Player 1"
	if vencedor == "Player 1":
		vitoria_label.text = "[color=#0000FF]Player 1[/color] Win"
	else:
		vitoria_label.text = "[color=#FF0000]Player 2[/color] Win"

	vitoria_canvas.visible = true
	pause_menu.visible = false
	options.visible = false

func _on_options_pressed():
	options.visible = true
	pause_menu.visible = false

func _on_back_pressed():
	_unpause_game()
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")

func _on_change_map_pressed():
	_unpause_game()
	get_tree().change_scene_to_file("res://Cenas/Multijogador/multijogador.tscn")

func _on_resume_pressed():
	_unpause_game()

func _on_restart_pressed():
	_unpause_game()
	get_tree().reload_current_scene()
