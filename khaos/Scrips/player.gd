extends CharacterBody2D

const SPEED = 300.0
const JUMP_FORCE = -400.0
var is_jumping := false
var is_attacking := false

@onready var anim_sprite = $anim as AnimatedSprite2D  
@onready var barra_de_vida = $BarraDeVida 

func _ready():
	if barra_de_vida == null:
		print("Erro: Barra de vida não encontrada no nó Player!")
	anim_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		is_jumping = true
	else:
		is_jumping = false
	
	if Input.is_action_just_pressed("up") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_FORCE
		is_jumping = true
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	var direction := Input.get_axis("left", "right")

	if not is_attacking:
		if direction != 0:
			velocity.x = direction * SPEED
			anim_sprite.scale.x = direction
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_jumping:
			anim_sprite.play("jump")
		elif direction != 0:
			anim_sprite.play("run")
		else:
			anim_sprite.play("idle")

	move_and_slide()

func start_attack() -> void:
	is_attacking = true
	anim_sprite.play("attack")

func _on_animation_finished() -> void:
	if anim_sprite.animation == "attack":
		is_attacking = false

		
func receber_dano(dano):
	if barra_de_vida == null:
		return
	if not barra_de_vida.has_method("receber_dano"):
		return
	
	barra_de_vida.receber_dano(dano)

func morrer():
	queue_free()
