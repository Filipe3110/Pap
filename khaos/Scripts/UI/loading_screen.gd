extends Control

@onready var animation_player = $AnimationPlayer
@onready var label_carregamento = $Carregar 
var next_scene = ""
var is_paused = false
var pause_timer = null
var text_timer = null
var carregando_texto = "A carregar"
var pontos = 0

func _ready():
	var random_speed = randf_range(1, 3)
	animation_player.speed_scale = random_speed
	animation_player.play("Barra de load")
	animation_player.animation_finished.connect(_on_animation_finished)
	start_pause_timer()
	start_text_timer()

func start_pause_timer():
	var pause_time = randf_range(0.5, 2.0)
	pause_timer = Timer.new()
	pause_timer.wait_time = pause_time
	pause_timer.one_shot = true
	pause_timer.connect("timeout", Callable(self, "_on_pause_timeout"))
	add_child(pause_timer)
	pause_timer.start()

func _on_pause_timeout():
	if not is_paused:
		animation_player.pause()
		is_paused = true
		var resume_time = randf_range(0.5, 2.0)
		pause_timer.wait_time = resume_time
		pause_timer.start()
	else:
		var random_offset = randf_range(0.0, animation_player.current_animation_length)
		animation_player.play("Barra de load", random_offset)
		animation_player.speed_scale = randf_range(0.3, 1)
		is_paused = false
		start_pause_timer()

func start_text_timer():
	text_timer = Timer.new()
	text_timer.wait_time = 0.5  
	text_timer.one_shot = false
	text_timer.connect("timeout", Callable(self, "_on_text_timeout"))
	add_child(text_timer)
	text_timer.start()

func _on_text_timeout():
	pontos = (pontos + 1) % 4  
	var sufixo = ".".repeat(pontos) 
	label_carregamento.text = carregando_texto + sufixo

func _on_animation_finished(_anim_name):
	get_tree().change_scene_to_file(next_scene)
	queue_free()
