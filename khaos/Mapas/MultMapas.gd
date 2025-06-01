extends Node2D

@onready var options = $Options_ingame
@onready var pause_menu = $Menu_pausa
@onready var vitoria_canvas = $Vitoria  
@onready var vitoria_label = $Vitoria/VitoriaLabel
@onready var camera = $DynamicCamera 

var is_paused = false
var player1_active : Node = null
var player2_active : Node = null

func _ready():
	personagens()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_menu.visible = false
	options.visible = false
	vitoria_canvas.visible = false

	await get_tree().process_frame
	
	# Descobre os jogadores ativos
	player1_active = get_active_player($Player1)
	player2_active = get_active_player($Player2)

	# Conecta o sinal de morte
# Conecta o sinal de morte
	if player1_active and player1_active.has_node("BarraDeVida"):
		player1_active.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))  # <- Remover o .bind()
	if player2_active and player2_active.has_node("BarraDeVida"):
		player2_active.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))  # <- Remover o .bind()


	# Configura a câmera
	_setup_camera()


# Função para descobrir qual personagem está ativo (visível)
func get_active_player(player_group: Node) -> Node:
	for child in player_group.get_children():
		if child.visible:
			return child
	return null


# Função para configurar a câmera dinamicamente
func _setup_camera():
	if not camera:
		camera = get_node_or_null("DynamicCamera")
	
	if camera and camera.has_method("set_players") and player1_active and player2_active:
		camera.set_players(player1_active, player2_active)


# Quando algum jogador morre, mostra tela de vitória
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


# Função para ativar personagens escolhidos no menu anterior
func personagens():
	if Global.personagem_jogador1 == "Pers1":
		$Player1/exPlayer1.visible = true
	elif Global.personagem_jogador1 == "Pers2":
		$Player1/pirPlayer1.visible = true
	elif Global.personagem_jogador1 == "Pers3":
		$Player1/monPlayer1.visible = true
	elif Global.personagem_jogador1 == "Pers4":
		$Player1/mumPlayer1.visible = true
	elif Global.personagem_jogador1 == "Pers":
		$Player1/Player1.visible = true
		
	if Global.personagem_jogador2 == "Pers1":
		$Player2/exPlayer2.visible = true
	elif Global.personagem_jogador2 == "Pers2":
		$Player2/pirPlayer2.visible = true
	elif Global.personagem_jogador2 == "Pers3":
		$Player2/monPlayer2.visible = true
	elif Global.personagem_jogador2 == "Pers4":
		$Player2/mumPlayer2.visible = true
	elif Global.personagem_jogador2 == "Pers":
		$Player2/Player2.visible = true
