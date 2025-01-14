extends CharacterBody2D

const VELOCIDADE = 300.0
const FORCA_PULO = -400.0
var esta_pulando := false
var esta_atacando := false
var esta_abaixando := false
var esta_bloqueando := false

@onready var animation_player = $AnimationPlayer
@onready var barra_de_vida = $BarraDeVida
var combo = ["soco_direita", "soco_esquerda", "uppercut"]
var Baixo_combo = ["baixo_soco_direita", "baixo_soco_esquerda"]

var contcombo: int = 0
var contcombo_baixo: int = 0

func _ready():
	if barra_de_vida == null:
		print("Erro: Barra de vida não encontrada no nó Player!")
	animation_player.connect("animation_finished", Callable(self, "_quando_animacao_finalizar"))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		esta_pulando = true
	else:
		esta_pulando = false

	if Input.is_action_just_pressed("up") and is_on_floor() and not esta_atacando:
		velocity.y = FORCA_PULO
		esta_pulando = true

	if Input.is_action_just_pressed("attack") and not esta_bloqueando:
		if Input.is_action_pressed("down") and is_on_floor():
			iniciar_ataque_baixo()
		else:
			iniciar_ataque()

	if Input.is_action_pressed("down") and is_on_floor() and not esta_pulando and not esta_atacando:
		esta_abaixando = true
		animation_player.play("Crunsh")
	else:
		esta_abaixando = false

	if Input.is_action_pressed("block") and is_on_floor() and not esta_pulando and not esta_atacando:
		esta_bloqueando = true
		animation_player.play("block")
	else:
		esta_bloqueando = false

	var direcao := Input.get_axis("left", "right")

	if not esta_atacando and not esta_abaixando and not esta_bloqueando:
		if direcao != 0:
			velocity.x = direcao * VELOCIDADE
			if (direcao < 0 and scale.x > 0) or (direcao > 0 and scale.x < 0):
				scale.x *= -1
		else:
			velocity.x = move_toward(velocity.x, 0, VELOCIDADE)
		if esta_pulando:
			animation_player.play("jump")
		elif direcao != 0:
			animation_player.play("run")
		else:
			animation_player.play("idle")

	move_and_slide()

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
		if contcombo_baixo >= Baixo_combo.size():
			contcombo_baixo = 0
	animation_player.play(Baixo_combo[contcombo_baixo])

func _quando_animacao_finalizar(anim_name):
	if anim_name in combo or anim_name in Baixo_combo:
		esta_atacando = false

func receber_dano(dano):
	if barra_de_vida == null:
		return
	if not barra_de_vida.has_method("receber_dano"):
		return

	barra_de_vida.receber_dano(dano)

func morrer():
	queue_free()
