extends Node2D

@onready var options = $Options_ingame
@onready var pause_menu = $Menu_pausa
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var vitoria_canvas = $Vitoria  
@onready var vitoria_label = $Vitoria/VitoriaLabel
@onready var camera = $DynamicCamera 
@onready var p1_indicator = $P1Indicator
@onready var p2_indicator = $P2Indicator

var is_paused = false
var indicator_margin = 50  # Margem das bordas da tela

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_menu.visible = false
	options.visible = false
	vitoria_canvas.visible = false  
	
	# Esconde os indicadores inicialmente
	if p1_indicator:
		p1_indicator.visible = false
	if p2_indicator:
		p2_indicator.visible = false
	
	# Conecta os sinais dos jogadores
	if p1 and p1.has_node("BarraDeVida"):
		p1.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))
	
	if p2 and p2.has_node("BarraDeVida"):
		p2.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))
	
	# Aguarda um frame para garantir que todos os nós estão prontos
	await get_tree().process_frame
	
	# Configura a câmera dinâmica
	_setup_camera()

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

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if is_paused:
			_unpause_game()
		else:
			_pause_game()
	
	# Atualiza os indicadores a cada frame
	_update_player_indicators()

func _update_player_indicators():
	if not camera or not p1 or not p2:
		return
	
	# Atualiza indicador do Player 1
	_update_single_indicator(p1, p1_indicator)
	
	# Atualiza indicador do Player 2
	_update_single_indicator(p2, p2_indicator)

func _update_single_indicator(player, indicator):
	if not player or not indicator:
		return
	
	# Converte a posição global do player para coordenadas da tela
	var player_screen_pos = camera.get_screen_center_position() - camera.get_viewport_rect().size / 2 + (player.global_position - camera.global_position) * camera.zoom
	
	# Obtém o retângulo da viewport
	var viewport_rect = camera.get_viewport_rect()
	viewport_rect.position = Vector2.ZERO  # Ajusta para coordenadas locais
	
	# Verifica se o player está visível na tela
	if viewport_rect.has_point(player_screen_pos):
		# Player está visível - esconde o indicador
		indicator.visible = false
	else:
		# Player está fora da tela - mostra o indicador
		indicator.visible = true
		
		# Calcula a direção do player em relação ao centro da tela
		var center = viewport_rect.size / 2
		var direction = (player_screen_pos - center).normalized()
		
		# Encontra o ponto de interseção com as bordas da tela
		var intersection = _get_border_intersection(center, direction, viewport_rect)
		
		# Posiciona o indicador na borda com margem (com suavização)
		var target_position = intersection - direction * indicator_margin
		indicator.position = indicator.position.lerp(target_position, 0.2)
		
		# Rotaciona o indicador para apontar para o player
		indicator.rotation = direction.angle() + PI/2
		
		# Efeito de pulsação baseado na distância
		var distance = player_screen_pos.distance_to(center)
		var pulse = sin(Time.get_ticks_msec() * 0.005) * 0.2 + 1.0
		indicator.scale = Vector2.ONE * pulse * clamp(distance / 500.0, 0.8, 1.2)

func _get_border_intersection(center, direction, viewport_rect):
	# Calcula onde a linha do centro na direção do player intersecta as bordas
	var viewport_size = viewport_rect.size
	var t_values = []
	
	# Calcula interseções com as bordas verticais
	if direction.x != 0:
		t_values.append((viewport_size.x - center.x) / direction.x)  # Borda direita
		t_values.append((0 - center.x) / direction.x)                # Borda esquerda
	
	# Calcula interseções com as bordas horizontais
	if direction.y != 0:
		t_values.append((viewport_size.y - center.y) / direction.y)  # Borda inferior
		t_values.append((0 - center.y) / direction.y)                # Borda superior
	
	# Encontra o menor t positivo (primeira interseção)
	var min_t = INF
	for t in t_values:
		if t > 0 and t < min_t:
			min_t = t
	
	return center + direction * min_t

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
