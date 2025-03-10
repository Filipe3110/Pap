extends CharacterBody2D

# Constantes
const VELOCIDADE = 250.0
const FORCA_PULO = -350.0
const GRAVIDADE = 900.0
const DISTANCIA_ATAQUE = 50.0
const DISTANCIA_PERSEGUIR = 300.0
const DISTANCIA_RECUAR = 100.0
const TEMPO_ESPERA_ATAQUE = 1.0  # Tempo entre ataques
const TEMPO_ESPERA_RECUAR = 0.5  # Tempo após recuar

# Variáveis de estado
enum Estado {
	IDLE,
	PERSEGUIR,
	ATACAR,
	BLOQUEAR,
	RECUAR,
	RECEBER_DANO
}

var estado_atual: Estado = Estado.IDLE
var esta_pulando := false
var esta_atacando := false
var esta_bloqueando := false
var direcao_atual := -1  # Começa virado para a esquerda (-1)
var tempo_espera: float = 0.0

# Referências
@onready var animation_player = $AnimationPlayer
@onready var barra_de_vida = $BarraDeVida
@onready var soco_area = $SocoArea
@onready var player = get_parent().get_node("Player")  # Ajuste o caminho para o jogador

# Combos
var combo = ["soco_direita", "soco_esquerda", "uppercut"]
var contcombo: int = 0

func _ready():
	animation_player.connect("animation_finished", Callable(self, "_quando_animacao_finalizar"))
	soco_area.connect("body_entered", Callable(self, "_on_soco_area_body_entered"))
	scale.x = -1  # Começa virado para a esquerda

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
		esta_pulando = true
	else:
		esta_pulando = false

	# Atualiza o tempo de espera
	if tempo_espera > 0:
		tempo_espera -= delta

	# Lógica da FSM
	match estado_atual:
		Estado.IDLE:
			_idle()
		Estado.PERSEGUIR:
			_perseguir()
		Estado.ATACAR:
			_atacar()
		Estado.BLOQUEAR:
			_bloquear()
		Estado.RECUAR:
			_recuar()
		Estado.RECEBER_DANO:
			_receber_dano()

	move_and_slide()

	# Transições de estado
	_transicoes_de_estado()

func _idle():
	# Fica parado e espera o jogador se aproximar
	velocity.x = 0
	animation_player.play("idle")

func _perseguir():
	# Move-se em direção ao jogador
	var direcao = sign(player.global_position.x - global_position.x)
	velocity.x = direcao * VELOCIDADE

	# Vira o sprite na direção correta
	if direcao != 0 and direcao != direcao_atual:
		direcao_atual = direcao
		scale.x = -scale.x

	# Animação de movimento
	if esta_pulando:
		animation_player.play("jump")
	else:
		animation_player.play("run")

func _atacar():
	# Executa o ataque
	if not esta_atacando and tempo_espera <= 0:
		esta_atacando = true
		animation_player.play(combo[contcombo])
		contcombo = (contcombo + 1) % combo.size()
		tempo_espera = TEMPO_ESPERA_ATAQUE  # Define o tempo de espera entre ataques

func _bloquear():
	# Bloqueia ataques
	velocity.x = 0
	animation_player.play("block")

func _recuar():
	# Recua após um ataque
	var direcao = -sign(player.global_position.x - global_position.x)
	velocity.x = direcao * VELOCIDADE

	# Vira o sprite na direção correta
	if direcao != 0 and direcao != direcao_atual:
		direcao_atual = direcao
		scale.x = -scale.x

	# Animação de movimento
	if esta_pulando:
		animation_player.play("jump")
	else:
		animation_player.play("run")

func _receber_dano():
	# Animação de receber dano
	velocity.x = 0
	animation_player.play("hurt")

func _transicoes_de_estado():
	# Lógica para mudar de estado
	var distancia_para_jogador = global_position.distance_to(player.global_position)

	if estado_atual != Estado.RECEBER_DANO:
		if distancia_para_jogador <= DISTANCIA_ATAQUE and tempo_espera <= 0:
			estado_atual = Estado.ATACAR
		elif distancia_para_jogador <= DISTANCIA_PERSEGUIR:
			estado_atual = Estado.PERSEGUIR
		elif distancia_para_jogador > DISTANCIA_PERSEGUIR:
			estado_atual = Estado.IDLE

	# Bloqueia se o jogador estiver atacando
	if player.esta_atacando and distancia_para_jogador <= DISTANCIA_ATAQUE:
		estado_atual = Estado.BLOQUEAR

	# Recua após atacar
	if estado_atual == Estado.ATACAR and not esta_atacando and tempo_espera <= 0:
		estado_atual = Estado.RECUAR
		tempo_espera = TEMPO_ESPERA_RECUAR

func _quando_animacao_finalizar(anim_name):
	if anim_name in combo:
		esta_atacando = false
		estado_atual = Estado.RECUAR  # Recua após o ataque

func _on_soco_area_body_entered(body):
	if body.is_in_group("player") and not body.esta_bloqueando:
		body.take_damage(10)  # Aplica dano ao jogador
		print("Jogador atingido!")

func take_damage(dano: int):
	if estado_atual == Estado.BLOQUEAR:
		dano = dano / 2  # Reduz o dano pela metade se estiver bloqueando
	barra_de_vida.receber_dano(dano)
	estado_atual = Estado.RECEBER_DANO
	animation_player.play("hurt")  # Animação de receber dano
