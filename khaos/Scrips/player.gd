extends CharacterBody2D

const SPEED = 300.0
const JUMP_FORCE = -400.0
var is_jumping := false
var is_attacking := false
@onready var anim_sprite := $anim as AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Checa se o player está no ar
	if not is_on_floor():
		velocity += get_gravity() * delta
		is_jumping = true
	else:
		is_jumping = false
	
	# Verifica se o player pode pular
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
	
	# Verifica se o player está atacando
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	var direction := Input.get_axis("left", "right")

	# Executa o movimento independentemente de estar atacando ou não
	if direction != 0:
		velocity.x = direction * SPEED
		anim_sprite.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Escolhe a animação correta
	if is_attacking:
		anim_sprite.play("attack")
	elif is_jumping:
		anim_sprite.play("jump")
	elif direction != 0:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")
	
	move_and_slide()

func start_attack() -> void:
	is_attacking = true
	anim_sprite.play("attack")

# Este método será chamado automaticamente quando qualquer animação acabar
func _on_animation_finished() -> void:
	if anim_sprite.animation == "attack":
		is_attacking = false
