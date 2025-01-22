extends Control
@onready var animation_player = $AnimationPlayer
var next_scene = ""

func _ready():
   var random_speed = randf_range(0.3, 1)
   animation_player.speed_scale = random_speed
   animation_player.play("Barra de load")
   
   animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(_anim_name):
   get_tree().change_scene_to_file(next_scene)
