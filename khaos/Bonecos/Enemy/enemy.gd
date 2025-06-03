extends CharacterBody2D

const VELOCIDADE = 300.0
const FORCA_PULO = -400.0
const GRAVIDADE = 900.0
const DISTANCIA_ATAQUE = 180.0  # Distância ideal para atacar
const DISTANCIA_PERSEGUICAO = 400.0  # Distância máxima para perseguir
const TEMPO_ESPERA = 0.8  # Tempo entre decisões

enum Comportamento { AGRESSIVO, DEFENSIVO, MISTO }

var esta_pulando := false
var esta_atacando := false
var esta_abaixando := false
var esta_bloqueando := false
var direcao_atual := 1
var comportamento := Comportamento.MISTO
var vida := 100
var pode_mudar_acao := true

@onready var animation_player = $AnimationPlayer
@onready var barra_de_vida = $BarraDeVida
@onready var jogador = get_parent().get_node("Player")

var combo = ["soco_direita", "soco_esquerda", "uppercut"]
var baixo_combo = ["baixo_soco_direita", "baixo_soco_esquerda"]

func _ready():
	if barra_de_vida:
		barra_de_vida.vida_maxima = vida
		barra_de_vida.vida_atual = vida
	animation_player.connect("animation_finished", Callable(self, "_quando_animacao_finalizar"))
	
	# Define comportamento aleatório
	comportamento = [Comportamento.AGRESSIVO, Comportamento.DEFENSIVO, Comportamento.MISTO][randi() % 3]

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
		esta_pulando = true
	else:
		esta_pulando = false

	# Lógica principal
	var distancia_jogador = jogador.position.x - position.x
	var abs_distancia = abs(distancia_jogador)
	var direcao_jogador = sign(distancia_jogador)
	
	# Movimentação
	if not esta_atacando and not esta_abaixando and not esta_bloqueando:
		if abs_distancia > DISTANCIA_ATAQUE and abs_distancia < DISTANCIA_PERSEGUICAO:
			velocity.x = direcao_jogador * VELOCIDADE
			if direcao_jogador * direcao_atual < 0:
				virar(direcao_jogador)
		else:
			velocity.x = move_toward(velocity.x, 0, VELOCIDADE)
	
	# Tomada de decisão
	if pode_mudar_acao and not esta_atacando:
		pode_mudar_acao = false
		determinar_acao(abs_distancia, direcao_jogador)
		await get_tree().create_timer(TEMPO_ESPERA).timeout
		pode_mudar_acao = true

	# Animação
	atualizar_animacao()

	move_and_slide()

func virar(direcao: float):
	direcao_atual = direcao
	scale.x = abs(scale.x) * direcao

func determinar_acao(distancia: float, direcao: float):
	# Comportamento baseado no tipo
	var acao: int
	
	match comportamento:
		Comportamento.AGRESSIVO:
			acao = determinar_acao_agressiva(distancia)
		Comportamento.DEFENSIVO:
			acao = determinar_acao_defensiva(distancia)
		_:
			acao = determinar_acao_mista(distancia)
	
	# Executa a ação
	match acao:
		0: iniciar_ataque()
		1: iniciar_ataque_baixo()
		2: pular()
		3: abaixar()
		4: bloquear()

func determinar_acao_agressiva(distancia: float) -> int:
	if distancia < DISTANCIA_ATAQUE * 1.2:
		if randf() < 0.7:  # 70% de chance de ataque
			return 0 if randf() < 0.6 else 1
		else:
			return 2  # Pular
	return 0  # Ataque padrão

func determinar_acao_defensiva(distancia: float) -> int:
	if distancia < DISTANCIA_ATAQUE:
		if randf() < 0.6:  # 60% de chance de defender
			return 3 if randf() < 0.5 else 4
	return 0  # Ataque padrão

func determinar_acao_mista(distancia: float) -> int:
	if distancia < DISTANCIA_ATAQUE:
		var rand = randf()
		if rand < 0.4:  # 40% ataque
			return 0 if rand < 0.2 else 1
		elif rand < 0.7:  # 30% defesa
			return 3 if rand < 0.55 else 4
		else:  # 30% mobilidade
			return 2
	return 0  # Ataque padrão

func iniciar_ataque():
	if not esta_atacando:
		esta_atacando = true
		velocity.x = 0  # Para o inimigo ao atacar
		animation_player.play(combo[randi() % combo.size()])

func iniciar_ataque_baixo():
	if not esta_atacando:
		esta_atacando = true
		velocity.x = 0  # Para o inimigo ao atacar
		animation_player.play(baixo_combo[randi() % baixo_combo.size()])

func pular():
	if is_on_floor() and not esta_atacando:
		velocity.y = FORCA_PULO
		esta_pulando = true

func abaixar():
	if is_on_floor() and not esta_pulando and not esta_atacando:
		esta_abaixando = true
		animation_player.play("crouch")
		await get_tree().create_timer(1.0).timeout
		esta_abaixando = false

func bloquear():
	if is_on_floor() and not esta_pulando and not esta_atacando:
		esta_bloqueando = true
		animation_player.play("block")
		await get_tree().create_timer(1.0).timeout
		esta_bloqueando = false

func atualizar_animacao():
	if esta_atacando:
		return
	elif esta_pulando:
		animation_player.play("jump")
	elif esta_abaixando:
		animation_player.play("crouch")
	elif esta_bloqueando:
		animation_player.play("block")
	elif velocity.x != 0:
		animation_player.play("run")
	else:
		animation_player.play("idle")

func _quando_animacao_finalizar(anim_name):
	if anim_name in combo or anim_name in baixo_combo:
		esta_atacando = false

func Enemy_receber_dano(dano: int):
	if esta_bloqueando:
		dano = max(1, dano / 2)  # No mínimo 1 de dano
	
	vida -= dano
	
	if barra_de_vida:
		barra_de_vida.receber_dano(dano)
	
	# Efeito visual
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	# Reação ao dano
	if vida <= 0:
		morrer()
	else:
		# Chance de mudar comportamento ao levar dano
		if randf() < 0.4:
			comportamento = Comportamento.DEFENSIVO if randf() < 0.7 else Comportamento.MISTO

func morrer():
	queue_free()

func _on_soco_area_body_entered(body: Node2D):
	if body.is_in_group("Player") and esta_atacando:
		var dano = 5
		if animation_player.current_animation == "uppercut":
			dano = 10
		body.call("Player_receber_dano", dano)
