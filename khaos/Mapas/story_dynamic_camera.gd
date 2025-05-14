extends Camera2D

# Referências ao jogador e inimigo
@export var player_path: NodePath
@export var enemy_path: NodePath

# Propriedades da câmera
@export var zoomed_in: Vector2 = Vector2(1.5, 1.5)     # Zoom quando próximos (valor maior = mais aproximado)
@export var normal_zoom: Vector2 = Vector2(1.0, 1.0)   # Zoom normal/padrão quando afastados
@export var proximity_threshold: float = 300.0         # Distância que ativa o zoom in
@export var zoom_speed: float = 0.05                   # Velocidade de zoom
@export var camera_speed: float = 5.0                  # Velocidade de movimentação da câmera
@export var focus_player_weight: float = 0.6           # Peso para focar mais no jogador (0.5 = igual, 1.0 = apenas jogador)

var player: Node2D
var enemy: Node2D
var screen_size: Vector2
var characters_found: bool = false

func _ready():
	# Aguarda um frame para garantir que a cena foi completamente carregada
	await get_tree().process_frame
	
	# Tenta obter referências para o jogador e inimigo
	_find_characters()
	
	# Obtém o tamanho da tela
	screen_size = Vector2(1152, 648)
	
	# Define zoom inicial como normal (sem zoom)
	zoom = normal_zoom

func _find_characters():
	# Primeiro tenta pelos caminhos exportados
	if player_path:
		player = get_node_or_null(player_path)
	if enemy_path:
		enemy = get_node_or_null(enemy_path)
	
	# Se não encontrou, tenta buscar pelo nome
	if not player:
		player = get_parent().get_node_or_null("Player")
	if not enemy:
		enemy = get_parent().get_node_or_null("Enemy")
	
	# Verifica se encontrou os personagens
	characters_found = player != null and enemy != null
	
	# Se encontrou os personagens, posiciona a câmera inicialmente
	if characters_found:
		# Posição ponderada (dando mais foco ao jogador)
		position = player.global_position * focus_player_weight + enemy.global_position * (1.0 - focus_player_weight)
	else:
		# Se não encontrou, tenta novamente no próximo frame
		await get_tree().process_frame
		_find_characters()

func _process(delta):
	# Verifica se encontrou os personagens
	if not characters_found:
		return
	
	# Verifica se os personagens ainda são válidos
	if not is_instance_valid(player) or not is_instance_valid(enemy):
		return
	
	# Calcula o ponto médio ponderado (dando mais foco ao jogador)
	var weighted_midpoint = player.global_position * focus_player_weight + enemy.global_position * (1.0 - focus_player_weight)
	
	# Calcula a distância entre jogador e inimigo
	var distance = player.global_position.distance_to(enemy.global_position)
	
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
	global_position = global_position.lerp(weighted_midpoint, camera_speed * delta)

# Função para definir os personagens diretamente via script
func set_characters(p: Node2D, e: Node2D):
	if is_instance_valid(p) and is_instance_valid(e):
		player = p
		enemy = e
		characters_found = true
		position = player.global_position * focus_player_weight + enemy.global_position * (1.0 - focus_player_weight)
