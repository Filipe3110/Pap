extends CanvasLayer
@onready var parent_node = get_parent()
func _on_button_pressed() -> void:
	parent_node.pauseMenu()
