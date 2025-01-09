extends CharacterBody2D

const VELOCIDADE = 300.0
const FORCA_PULO = -400.0
var esta_pulando := false
var esta_atacando := false

@onready var sprite_animado = $anim as AnimatedSprite2D  
@onready var barra_de_vida = $BarraDeVida 

var combo = ["soco_direita", "soco_esquerda", "uppercut"]
var contcombo: int = 0  
var tempultclick: int = 0

func _ready():
	if barra_de_vida == null:
		print("Erro: Barra de vida não encontrada no nó Player!")
	sprite_animado.connect("animation_finished", Callable(self, "_quando_animacao_finalizar"))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		esta_pulando = true
	else:
		esta_pulando = false
	
	if Input.is_action_just_pressed("up") and is_on_floor() and not esta_atacando:
		velocity.y = FORCA_PULO
		esta_pulando = true
	
	if Input.is_action_just_pressed("attack") and not esta_atacando:
		iniciar_ataque()

	var direcao := Input.get_axis("left", "right")

	if not esta_atacando:
		if direcao != 0:
			velocity.x = direcao * VELOCIDADE
			sprite_animado.scale.x = direcao
		else:
			velocity.x = move_toward(velocity.x, 0, VELOCIDADE)
		if esta_pulando:
			sprite_animado.play("jump")
		elif direcao != 0:
			sprite_animado.play("run")
		else:
			sprite_animado.play("idle")

	move_and_slide()

func iniciar_ataque() -> void:
	esta_atacando = true
	sprite_animado.play("soco_direita")


func _quando_animacao_finalizar() -> void:
	if sprite_animado.animation == "soco_direita":
		esta_atacando = false
		


func receber_dano(dano):
	if barra_de_vida == null:
		return
	if not barra_de_vida.has_method("receber_dano"):
		return
	
	barra_de_vida.receber_dano(dano)

func morrer():
	queue_free()
