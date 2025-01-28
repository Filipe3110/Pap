extends CanvasLayer


func _on_touch_screen_button_pressed() -> void:
	get_tree().change_scene("res://Cenas/loading_screen.tscn")  # Muda para a cena de pausa
