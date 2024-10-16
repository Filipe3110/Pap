extends CharacterBody2D

@export var SPEED := 200.0
@export var grav := 10.0
@export var JUMP_FORCE := -300.0  # Força do salto, negativo para ir para cima

func _physics_process(delta: float) -> void:
	# Aplica gravidade quando o personagem não está no chão
	if !is_on_floor():
		velocity.y += grav
	else:
		velocity.y = 0  # Reset da gravidade no chão

	# Movimento para a direita
	if Input.is_action_pressed("right"):
		velocity.x = SPEED if is_on_floor() else SPEED * 1.3
	# Movimento para a esquerda
	elif Input.is_action_pressed("left"):
		velocity.x = -SPEED if is_on_floor() else -SPEED * 1.3
	# Nenhum movimento lateral
	else:
		velocity.x = 0

	# Salto
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_FORCE  # Aplica a força do salto


	move_and_slide()  # Necessário para mover e aplicar física no personagem
