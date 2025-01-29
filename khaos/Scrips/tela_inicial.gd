extends Control

func _ready():
	$HBoxContainer/Campanha.pressed.connect(_on_campanha_pressed)
	$HBoxContainer/Controles.pressed.connect(_on_controles_pressed)
	$HBoxContainer/Sair.pressed.connect(_on_sair_pressed)

func _on_controles_pressed():
	get_tree().change_scene_to_file("res://Cenas/controles.tscn")

func _on_campanha_pressed():
	carregar_cena_com_loading("res://Cenas/game.tscn")

func _on_multijogador_pressed():
	carregar_cena_com_loading("res://Cenas/Multimapasepersonagens.tscn")

func _on_sair_pressed():
	get_tree().quit()

func carregar_cena_com_loading(caminho_da_proxima_cena):
	var loading = load("res://Cenas/loading_screen.tscn").instantiate()
	loading.next_scene = caminho_da_proxima_cena
	get_tree().root.add_child(loading)
	queue_free()
