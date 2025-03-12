extends Control

var random_map = ["res://Mapas/Multmapa_espço.tscn", "res://Mapas/Multmapa_montanhanheve.tscn"]

func _ready():
	randomize()

func _on_mapa_1_pressed() -> void:
	carregar_cena_com_loading("res://Mapas/Multmapa_espço.tscn")


func _on_mapa_2_pressed() -> void:
	carregar_cena_com_loading("res://Mapas/Multmapa_montanhanheve.tscn")

func _on_mapa_r_pressed() -> void:
	var random_index = randi() % random_map.size()
	var random_scene = random_map[random_index]
	carregar_cena_com_loading(random_scene)



func carregar_cena_com_loading(caminho_da_proxima_cena):
	var loading = load("res://Cenas/UI/loading_screen.tscn").instantiate()
	loading.next_scene = caminho_da_proxima_cena
	get_tree().root.add_child(loading)
	queue_free()
	
