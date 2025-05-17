extends Control


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")

func _on_mapa_1_pressed() -> void:
	carregar_cena_com_loading("res://Mapas/mapa_espço.tscn")


func _on_mapa_2_pressed() -> void:
	carregar_cena_com_loading("res://Mapas/mapa_montanhanheve.tscn")


func _on_mapa_3_pressed() -> void:
	carregar_cena_com_loading("res://Mapas/mapa_montanhanheve.tscn")


func _on_mapa_4_pressed() -> void:
	carregar_cena_com_loading("res://Mapas/mapa_montanhanheve.tscn")


func carregar_cena_com_loading(caminho_da_proxima_cena):
	var loading = load("res://Cenas/UI/loading_screen.tscn").instantiate()
	loading.next_scene = caminho_da_proxima_cena
	get_tree().root.add_child(loading)
	queue_free()
