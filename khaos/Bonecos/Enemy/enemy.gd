extends CharacterBody2D

# Constants
const VELOCIDADE = 300.0
const FORCA_PULO = -400.0
const GRAVIDADE = 900.0
const DISTANCIA_MINIMA = 200.0
const DISTANCIA_ATAQUE = 150.0  # Distance at which enemy can attack

# State variables
var esta_pulando := false
var esta_atacando := false
var esta_abaixando := false
var esta_bloqueando := false
var direcao_atual := 1
var in_hit_cooldown := false

# Node references
@onready var animation_player = $AnimationPlayer
@onready var barra_de_vida = $BarraDeVida
@onready var jogador = get_parent().get_node("Player")
@onready var soco_area = $SocoArea

# Combat system
var combo = ["soco_direita", "soco_esquerda", "uppercut"]
var baixo_combo = ["baixo_soco_direita", "baixo_soco_esquerda"]
var contcombo: int = 0
var contcombo_baixo: int = 0

# AI timing
var tempo_para_proxima_acao := 0.0
var tempo_entre_acoes := 1.0
var tempo_bloqueio := 0.0
var tempo_agachado := 0.0

# AI behavior weights
var peso_ataque := 30
var peso_ataque_baixo := 20
var peso_pulo := 15
var peso_agachar := 10
var peso_bloquear := 25

func _ready():
	if barra_de_vida == null:
		print("Erro: Barra de vida não encontrada no nó Inimigo!")
	
	# Connect animation signals
	if animation_player:
		animation_player.connect("animation_finished", Callable(self, "_quando_animacao_finalizar"))
	
	# Connect area signals if available
	
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
		esta_pulando = true
	else:
		esta_pulando = false

	# Update timers
	tempo_para_proxima_acao -= delta
	tempo_bloqueio -= delta
	tempo_agachado -= delta
	
	# End blocking/crouching after timer
	if tempo_bloqueio <= 0 and esta_bloqueando:
		esta_bloqueando = false
	
	if tempo_agachado <= 0 and esta_abaixando:
		esta_abaixando = false

	# AI decision making
	if tempo_para_proxima_acao <= 0 and not esta_atacando:
		tomar_decisao_inteligente()
		tempo_para_proxima_acao = randf_range(0.8, 1.5)  # Variable timing

	# Enhanced movement
	gerenciar_movimento()
	
	move_and_slide()

func gerenciar_movimento():
	if not esta_atacando and not esta_abaixando and not esta_bloqueando:
		var distancia = jogador.position.x - position.x
		var direcao: float = sign(distancia)
		
		# Move towards player if too far, maintain distance if close
		if abs(distancia) > DISTANCIA_MINIMA:
			velocity.x = direcao * VELOCIDADE
			_atualizar_direcao(direcao)
		elif abs(distancia) < DISTANCIA_ATAQUE:
			# Too close, back away slightly
			velocity.x = -direcao * VELOCIDADE * 0.3
			_atualizar_direcao(direcao)
		else:
			velocity.x = 0

		# Animation management
		_gerenciar_animacoes()
	else:
		velocity.x = 0

func _atualizar_direcao(nova_direcao: float):
	if nova_direcao * direcao_atual < 0:
		direcao_atual = nova_direcao
		scale.x = -scale.x

func _gerenciar_animacoes():
	if esta_pulando:
		animation_player.play("jump")
	elif esta_bloqueando:
		animation_player.play("block")
	elif esta_abaixando:
		animation_player.play("crouch")
	elif velocity.x != 0:
		animation_player.play("run")
	else:
		animation_player.play("idle")

func tomar_decisao_inteligente():
	var distancia = abs(jogador.position.x - position.x)
	var decisao_ponderada = []
	
	# Adjust behavior based on distance and situation
	if distancia <= DISTANCIA_ATAQUE:
		# Close range - favor attacks
		for i in peso_ataque:
			decisao_ponderada.append("ataque")
		for i in peso_ataque_baixo:
			decisao_ponderada.append("ataque_baixo")
		for i in peso_bloquear * 2:  # More likely to block when close
			decisao_ponderada.append("bloquear")
	else:
		# Far range - favor movement and positioning
		for i in peso_pulo:
			decisao_ponderada.append("pular")
		for i in peso_agachar:
			decisao_ponderada.append("agachar")
		for i in peso_ataque / 2:  # Less likely to attack when far
			decisao_ponderada.append("ataque")
	
	# Random decision from weighted options
	if decisao_ponderada.size() > 0:
		var escolha = decisao_ponderada[randi() % decisao_ponderada.size()]
		executar_acao(escolha)

func executar_acao(acao: String):
	match acao:
		"ataque":
			iniciar_ataque()
		"ataque_baixo":
			iniciar_ataque_baixo()
		"pular":
			pular()
		"agachar":
			agachar()
		"bloquear":
			bloquear()

func iniciar_ataque() -> void:
	if not esta_atacando and not esta_abaixando and not esta_bloqueando:
		esta_atacando = true
		animation_player.play(combo[contcombo])
		contcombo = (contcombo + 1) % combo.size()

func iniciar_ataque_baixo() -> void:
	if not esta_atacando and not esta_bloqueando:
		esta_atacando = true
		esta_abaixando = true
		animation_player.play(baixo_combo[contcombo_baixo])
		contcombo_baixo = (contcombo_baixo + 1) % baixo_combo.size()

func pular() -> void:
	if is_on_floor() and not esta_atacando and not esta_abaixando and not esta_bloqueando:
		velocity.y = FORCA_PULO
		esta_pulando = true

func agachar() -> void:
	if is_on_floor() and not esta_pulando and not esta_atacando and not esta_bloqueando:
		esta_abaixando = true
		tempo_agachado = randf_range(0.5, 1.5)
		animation_player.play("crouch")

func bloquear() -> void:
	if is_on_floor() and not esta_pulando and not esta_atacando and not esta_abaixando:
		esta_bloqueando = true
		tempo_bloqueio = randf_range(1.0, 2.0)
		animation_player.play("block")

func _quando_animacao_finalizar(anim_name: String):
	if anim_name in combo or anim_name in baixo_combo:
		esta_atacando = false
		if anim_name in baixo_combo:
			esta_abaixando = false

func Enemy_receber_dano(dano):
	if in_hit_cooldown:
		return
	
	in_hit_cooldown = true
	
	if barra_de_vida == null or not barra_de_vida.has_method("receber_dano"):
		print("Erro: Sistema de vida não configurado corretamente!")
		in_hit_cooldown = false
		return
	
	# Apply damage
	barra_de_vida.receber_dano(2 * dano)
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	# Reset cooldown
	await get_tree().create_timer(0.01).timeout
	in_hit_cooldown = false
	
	# Chance to react to being hit
	if randf() < 0.3:  # 30% chance
		if randf() < 0.5:
			bloquear()
		else:
			pular()

func _on_soco_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and esta_atacando:
		print("Inimigo acertou o jogador!")
		
		var dano = 5  # Default damage
		
		# Calculate damage based on current attack
		var ataque_atual = ""
		if contcombo > 0:
			ataque_atual = combo[contcombo - 1]
		elif contcombo_baixo > 0:
			ataque_atual = baixo_combo[contcombo_baixo - 1]
		
		match ataque_atual:
			"uppercut":
				dano = 10
			"soco_direita", "soco_esquerda":
				dano = 5
			"baixo_soco_direita", "baixo_soco_esquerda":
				dano = 5
		
		if body.has_method("Player_receber_dano"):
			body.call("Player_receber_dano", dano)

# Additional utility functions
func obter_distancia_jogador() -> float:
	return abs(jogador.position.x - position.x)

func jogador_esta_proximo() -> bool:
	return obter_distancia_jogador() <= DISTANCIA_ATAQUE

func esta_virado_para_jogador() -> bool:
	var direcao_jogador = sign(jogador.position.x - position.x)
	return direcao_jogador == direcao_atual
