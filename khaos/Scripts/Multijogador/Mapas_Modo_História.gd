extends Control


var COLLECTION_ID = "khaos_stats"
var selected_map_path = ""
var selected_map_name = ""
# Mapa do espaço (índice 0) sempre desbloqueado, outros bloqueados inicialmente
var mapas_desbloqueados = [true, false, false, false]

var random_map = ["res://Mapas/Multmapa_espço.tscn", "res://Mapas/Multmapa_montanhanheve.tscn"]

func _ready():
	randomize()

func _on_mapa_1_pressed() -> void:

	carregar_cena_com_loading("res://Mapas/Multmapa_espço.tscn")


	tentar_entrar_mapa(0, "mapa_espaco", "res://Mapas/mapa_espaco.tscn")

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
	


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")
