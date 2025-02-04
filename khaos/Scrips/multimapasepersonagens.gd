extends Control

var random_map = ["res://Cenas/game.tscn", "res://Cenas/mapa_montanhanheve.tscn"]

func _ready():
	randomize()

func _on_mapa_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/gameM.tscn")

func _on_mapa_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/mapa_montanhanheve.tscn")

func _on_mapa_r_pressed() -> void:
	var random_index = randi() % random_map.size()
	var random_scene = random_map[random_index]
	get_tree().change_scene_to_file(random_scene)
