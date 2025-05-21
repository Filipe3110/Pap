extends Node2D

@onready var options = $Options_ingame
@onready var pause_menu = $Menu_pausa
@onready var p1 = $Player
@onready var p2 = $ExEnemy 
@onready var vitoria_canvas = $Vitoria  
@onready var vitoria_label = $Vitoria/VitoriaLabel
@onready var camera = $StoryDynamicCamera 
@onready var conti = $Vitoria/VBoxContainer/Continue
@onready var restart = $Vitoria/VBoxContainer/Restart
@onready var victory = $Victory
var is_paused = false

func _ready():
	victory.process_mode = Node.PROCESS_MODE_ALWAYS
	conti.visible = false
	restart.visible = false

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_menu.visible = false
	options.visible = false
	vitoria_canvas.visible = false
	
	# Conecta os sinais dos personagens  
	if p1 and p1.has_node("BarraDeVida"):
		p1.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))
	if p2 and p2.has_node("BarraDeVida"):
		p2.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))
	
	# Aguarda um frame para garantir que todos os nós estão prontos
	await get_tree().process_frame
	
	# Configura a câmera dinâmica
	_setup_camera()

# Função para configurar a câmera
func _setup_camera():
	# Busca a câmera se ela não foi encontrada automaticamente
	if not camera:
		camera = get_node_or_null("StoryDynamicCamera")
	
	# Se a câmera existe e tem o método set_characters
	if camera and camera.has_method("set_characters"):
		# Verifica se o jogador e inimigo existem
		if p1 and p2:
			camera.set_characters(p1, p2)
		else:
			# Tenta encontrar os personagens por nome
			var player = get_node_or_null("Player")
			var enemy = get_node_or_null("Enemy")
			if player and enemy:
				camera.set_characters(player, enemy)

func _on_jogador_morreu(jogador_id):
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if jogador_id == "Player":
		vitoria_label.text = "[center][color=#FF0000]Defeat[/color][/center]"
		conti.visible = false
		restart.visible = true
	else:
		# Jogador ganhou
		vitoria_label.text = "[center][color=#00FF00]Victory[/color][/center]"
		victory.playing = true

		conti.visible = true
		restart.visible = false
		
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

func _on_resume_pressed() -> void:
	_unpause_game()

func _on_restart_pressed() -> void:
	_unpause_game()
	get_tree().reload_current_scene()

func _on_change_map_pressed() -> void:
	_unpause_game()
	get_tree().change_scene_to_file("res://Cenas/Modo_História/modo_história.tscn")
