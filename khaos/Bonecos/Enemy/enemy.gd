extends CharacterBody2D

const VELOCIDADE = 300.0
const FORCA_PULO = -400.0
const GRAVIDADE = 900.0
const DISTANCIA_MINIMA = 200.0  # Distância mínima do jogador

var esta_pulando := false
var esta_atacando := false
var esta_abaixando := false
var esta_bloqueando := false
var direcao_atual := 1

@onready var animation_player = $AnimationPlayer
@onready var barra_de_vida = $BarraDeVida
@onready var jogador = get_parent().get_node("Player")  

var combo = ["soco_direita", "soco_esquerda", "uppercut"]
var baixo_combo = ["baixo_soco_direita", "baixo_soco_esquerda"]

var contcombo: int = 0
var contcombo_baixo: int = 0

var tempo_para_proxima_acao := 0.0
var tempo_entre_acoes := 1.0  # Tempo entre ações em segundos

func _ready():
	if barra_de_vida == null:
		print("Erro: Barra de vida não encontrada no nó Inimigo!")
	animation_player.connect("animation_finished", Callable(self, "_quando_animacao_finalizar"))

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
		esta_pulando = true
	else:
		esta_pulando = false

	# Tomada de decisão
	tempo_para_proxima_acao -= delta
	if tempo_para_proxima_acao <= 0:
		tomar_decisao()
		tempo_para_proxima_acao = tempo_entre_acoes

	# Movimento horizontal melhorado
	if not esta_atacando and not esta_abaixando and not esta_bloqueando:
		var distancia = jogador.position.x - position.x
		var direcao: float = sign(distancia)
		
		# Só move se estiver longe o suficiente do jogador
		if abs(distancia) > DISTANCIA_MINIMA:
			velocity.x = direcao * VELOCIDADE
			if direcao * direcao_atual < 0:
				direcao_atual = direcao
				scale.x = -scale.x
		else:
			velocity.x = 0  # Para quando estiver próximo o suficiente

		# Animação de movimento
		if esta_pulando:
			animation_player.play("jump")
		elif velocity.x != 0:
			animation_player.play("run")
		else:
			animation_player.play("idle")

	move_and_slide()

func tomar_decisao():
	var decisao = randi() % 5  # Escolhe uma ação aleatória

	match decisao:
		0:
			iniciar_ataque()
		1:
			iniciar_ataque_baixo()
		2:
			pular()
		3:
			abaixar()
		4:
			bloquear()

func iniciar_ataque() -> void:
	if not esta_atacando:
		esta_atacando = true
		contcombo = 0
	else:
		contcombo += 1
		if contcombo >= combo.size():
			contcombo = 0
	animation_player.play(combo[contcombo])

func iniciar_ataque_baixo() -> void:
	if not esta_atacando:
		esta_atacando = true
		contcombo_baixo = 0
	else:
		contcombo_baixo += 1
		if contcombo_baixo >= baixo_combo.size():
			contcombo_baixo = 0
	animation_player.play(baixo_combo[contcombo_baixo])

func pular() -> void:
	if is_on_floor() and not esta_atacando:
		velocity.y = FORCA_PULO
		esta_pulando = true

func abaixar() -> void:
	if is_on_floor() and not esta_pulando and not esta_atacando:
		esta_abaixando = true
		animation_player.play("crouch")

func bloquear() -> void:
	if is_on_floor() and not esta_pulando and not esta_atacando:
		esta_bloqueando = true
		animation_player.play("block")

func _quando_animacao_finalizar(anim_name):
	if anim_name in combo or anim_name in baixo_combo:
		esta_atacando = false

var in_hit_cooldown = false

func Enemy_receber_dano(dano):
	if (in_hit_cooldown): return 
	in_hit_cooldown = true
	
	if barra_de_vida == null:
		return
	if not barra_de_vida.has_method("receber_dano"):
		return
	
	barra_de_vida.receber_dano(dano)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	await get_tree().create_timer(.5).timeout
	in_hit_cooldown = false



func _on_soco_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Inimigo acertou o jogador!")
		
		if combo[contcombo] == "soco_direita" or combo[contcombo] == "soco_esquerda":
			body.call("Player_receber_dano", 5)  # Causa 5 de dano
		elif combo[contcombo] == "uppercut":
			body.call("Player_receber_dano", 10)  # Causa 10 de dano
