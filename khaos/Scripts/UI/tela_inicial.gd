extends Control



func _on_modo_história_pressed():
	get_tree().change_scene_to_file("res://Cenas/Modo_História/Tela_dos_mapas.tscn")

func _on_multijogador_pressed():
	get_tree().change_scene_to_file("res://Cenas/Multijogador/multijogador.tscn")

func _on_opções_pressed():
	get_tree().change_scene_to_file("res://Cenas/controles.tscn")

func _on_sair_pressed():
	Firebase.Auth.logout()
	get_tree().quit()


func carregar_cena_com_loading(caminho_da_proxima_cena):
	var loading = load("res://Cenas/UI/loading_screen.tscn").instantiate()
	loading.next_scene = caminho_da_proxima_cena
	get_tree().root.add_child(loading)
	queue_free()
