extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var anim_sprite :=$anim as AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("left", "right")
	if direction !=0:
		velocity.x = direction * SPEED
		anim_sprite.play("run")
		anim_sprite.scale.x = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		anim_sprite.play("idle")
		 

	move_and_slide()
