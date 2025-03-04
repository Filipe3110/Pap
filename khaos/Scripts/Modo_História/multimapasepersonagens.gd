extends Control

func _on_mapa_1_pressed() -> void:
	get_tree().change_scene_to_file("")

func _on_mapa_2_pressed() -> void:
	get_tree().change_scene_to_file("")

func _on_mapa_4_pressed():
	get_tree().change_scene_to_file("")


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")
