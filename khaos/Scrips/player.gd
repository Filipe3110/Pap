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
		$AnimatedSprite2D.flip_h = false
	# Movimento para a esquerda
	elif Input.is_action_pressed("left"):
		velocity.x = -SPEED if is_on_floor() else -SPEED * 1.3
		$AnimatedSprite2D.flip_h = true
	# Nenhum movimento lateral
	else:
		velocity.x = 0

	# Salto
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_FORCE  # Aplica a força do salto
		$AnimationPlayer.play("jump")  # Toca a animação de salto

	# Controla as animações via AnimationPlayer
	if !is_on_floor():  # Se está no ar, toca a animação de pulo
		if $AnimationPlayer.current_animation != "jump":
			$AnimationPlayer.play("jump")
	elif velocity.x != 0:  # Se está no chão e se movendo, toca a animação de correr
		if $AnimationPlayer.current_animation != "run":
			$AnimationPlayer.play("run")
	else:  # Se está no chão e parado, toca a animação de idle
		if $AnimationPlayer.current_animation != "idle":
			$AnimationPlayer.play("idle")

	move_and_slide()  # Necessário para mover e aplicar física no personagem
