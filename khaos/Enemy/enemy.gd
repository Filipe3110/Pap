extends CharacterBody2D

const VELOCIDADE = 150.0
const GRAVIDADE = 900.0
const DANO_ATAQUE = 10

var vida: int = 100
var esta_atacando: bool = false
var esta_morto: bool = false

@onready var animation_player = $AnimationPlayer
@onready var area_ataque = $AreaAtaque
@onready var sprite = $Sprite2D  # Referência ao nó Sprite2D

func _ready():
	area_ataque.connect("body_entered", Callable(self, "_on_area_ataque_body_entered"))

func _physics_process(delta: float) -> void:
	if esta_morto:
		return

	# Aplica gravidade
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta

	# Segue o personagem
	var personagem = get_parent().find_child("Player")  # Substitua "Player" pelo nome do nó do personagem
	if personagem:
		var direcao = (personagem.global_position - global_position).normalized()
		velocity.x = direcao.x * VELOCIDADE

		# Vira o inimigo na direção do personagem
		if direcao.x < 0:
			sprite.flip_h = true  # Vira o sprite para a esquerda
		else:
			sprite.flip_h = false  # Vira o sprite para a direita

		# Ataca se estiver perto
		if global_position.distance_to(personagem.global_position) < 50 and not esta_atacando:
			atacar()

	move_and_slide()

func atacar():
	esta_atacando = true
	animation_player.play("attack")
	print("Inimigo atacou!")

func receber_dano(dano: int):
	vida -= dano
	if vida <= 0:
		morrer()
	else:
		animation_player.play("hurt")
	print("Inimigo recebeu dano! Vida restante: ", vida)

func morrer():
	esta_morto = true
	animation_player.play("die")
	await animation_player.animation_finished
	queue_free()
	print("Inimigo morreu!")

func _on_area_ataque_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(DANO_ATAQUE)
		print("Personagem atingido pelo inimigo!")
