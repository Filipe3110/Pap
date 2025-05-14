extends Camera2D

# Referências aos jogadores
@export var player1_path: NodePath
@export var player2_path: NodePath

# Propriedades da câmera
@export var zoomed_in: Vector2 = Vector2(1.5, 1.5)     # Zoom quando próximos (valor maior = mais aproximado)
@export var normal_zoom: Vector2 = Vector2(1.0, 1.0)   # Zoom normal/padrão quando afastados
@export var proximity_threshold: float = 300.0         # Distância que ativa o zoom in
@export var zoom_speed: float = 0.05                   # Velocidade de zoom
@export var camera_speed: float = 5.0                  # Velocidade de movimentação da câmera

var player1: Node2D
var player2: Node2D
var screen_size: Vector2
var players_found: bool = false

func _ready():
	# Aguarda um frame para garantir que a cena foi completamente carregada
	await get_tree().process_frame
	
	# Tenta obter referências para os jogadores
	_find_players()
	
	# Obtém o tamanho da tela
	screen_size = Vector2(1152, 648)
	
	# Define zoom inicial como normal (sem zoom)
	zoom = normal_zoom

func _find_players():
	# Primeiro tenta pelos caminhos exportados
	if player1_path:
		player1 = get_node_or_null(player1_path)
	
	if player2_path:
		player2 = get_node_or_null(player2_path)
	
	# Se não encontrou, tenta buscar pelo nome
	if not player1:
		player1 = get_parent().get_node_or_null("Player1")
	
	if not player2:
		player2 = get_parent().get_node_or_null("Player2")
	
	# Verifica se encontrou os jogadores
	players_found = player1 != null and player2 != null
	
	# Se encontrou os jogadores, posiciona a câmera inicialmente
	if players_found:
		position = (player1.global_position + player2.global_position) / 2
	else:
		# Se não encontrou, tenta novamente no próximo frame
		await get_tree().process_frame
		_find_players()

func _process(delta):
	# Verifica se encontrou os jogadores
	if not players_found:
		return
	
	# Verifica se os jogadores ainda são válidos
	if not is_instance_valid(player1) or not is_instance_valid(player2):
		return
	
	# Calcula o ponto médio entre os jogadores
	var midpoint = (player1.global_position + player2.global_position) / 2
	
	# Calcula a distância entre os jogadores
	var distance = player1.global_position.distance_to(player2.global_position)
	
	# Define o zoom desejado baseado na proximidade
	var desired_zoom
	
	if distance < proximity_threshold:
		# Quando próximos: aplica o zoom in (mais aproximado)
		# A interpolação cria uma transição suave baseada na proximidade
		var proximity_factor = 1.0 - (distance / proximity_threshold)
		desired_zoom = Vector2(
			lerp(normal_zoom.x, zoomed_in.x, proximity_factor),
			lerp(normal_zoom.y, zoomed_in.y, proximity_factor)
		)
	else:
		# Quando distantes: usa o zoom normal (sem zoom)
		desired_zoom = normal_zoom
	
	# Aplica suavização ao zoom
	zoom = zoom.lerp(desired_zoom, zoom_speed)
	
	# Define a posição alvo e aplica suavização
	global_position = global_position.lerp(midpoint, camera_speed * delta)

# Função para definir os jogadores diretamente via script
func set_players(p1: Node2D, p2: Node2D):
	if is_instance_valid(p1) and is_instance_valid(p2):
		player1 = p1
		player2 = p2
		players_found = true
		position = (player1.global_position + player2.global_position) / 2
