extends Control


func _on_mapa_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/game.tscn")


func _on_mapa_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/mapa_montanhanheve.tscn")
