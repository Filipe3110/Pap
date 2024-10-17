extends CharacterBody2D

const SPEED = 300.0
const JUMP_FORCE= -400.0
var is_jumping := false
@onready var anim_sprite :=$anim as AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_FORCE
		is_jumping = true
	elif  is_on_floor():
		is_jumping = false
	var direction := Input.get_axis("left", "right")
	if direction !=0:
		velocity.x = direction * SPEED
		anim_sprite.scale.x = direction
		if !is_jumping:
			anim_sprite.play("run")
	elif is_jumping:
		anim_sprite.play("jump")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		anim_sprite.play("idle")
		 
	move_and_slide()
