extends CanvasLayer
@onready var parent_node = get_parent()



func _on_voltarjogo_pressed() -> void:
	parent_node.pauseMenu()




func _on_sair_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/main.tscn")


func _on_trocar_personagem_mapa_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Multimapasepersonagens.tscn")
