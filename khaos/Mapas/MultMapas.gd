extends Node2D
@onready var options = $Options_ingame
@onready var pause_menu = $Menu_pausa
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var vitoria_canvas = $Vitoria  
@onready var vitoria_label = $Vitoria/VitoriaLabel
@onready var camera = $DynamicCamera 
var is_paused = false

#@onready var p1ind1 = $point1
@onready var p1ind2 = $point2
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_menu.visible = false
	options.visible = false
	vitoria_canvas.visible = false  
	points()
	
	if p1 and p1.has_node("BarraDeVida"):
		p1.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))
	
	if p2 and p2.has_node("BarraDeVida"):
		p2.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))
	
	await get_tree().process_frame
	
	_setup_camera()

# Função para configurar a câmera
func _setup_camera():
	# Busca a câmera se ela não foi encontrada automaticamente
	if not camera:
		camera = get_node_or_null("DynamicCamera")
	
	# Se a câmera existe e tem o método set_players
	if camera and camera.has_method("set_players"):
		# Verifica se os jogadores existem
		if p1 and p2:
			camera.set_players(p1, p2)
		else:
			# Tenta encontrar os jogadores por nome
			var player1 = get_node_or_null("Player1")
			var player2 = get_node_or_null("Player2")
			
			if player1 and player2:
				camera.set_players(player1, player2)

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
	
func points():
	pass
