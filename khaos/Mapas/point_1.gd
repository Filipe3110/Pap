extends Sprite2D

var x_offset: float = 10
var y_offset: float = -170

func _ready():
	top_level = true  

func _process(delta):
	global_position = get_parent().global_position + Vector2(x_offset,  y_offset)
	global_rotation = 0
