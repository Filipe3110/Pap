extends CharacterBody2D

@export var SPEED:= 200.0
@export var grav: = 10.0
#@onready var anim_player: AnimationPlayer = get_node("AnimationPlayer")
	#anim_player.play("idle")
@onready var anim_sprite := $AnimatedSprite2

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += grav
	if Input.is_action_pressed("right"):
		velocity.x = SPEED if (is_on_floor()) else SPEED * 1.3
		$AnimatedSprite2D.flip_h = false
	elif Input.is_action_pressed("left"):
		velocity.x = -SPEED if (is_on_floor()) else -SPEED * 1.3
		$AnimatedSprite2D.flip_h = true
	else:
		velocity.x = 0
	
