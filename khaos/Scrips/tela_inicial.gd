extends Control

func _ready():
	$HBoxContainer/Campanha.pressed.connect(_on_campanha_pressed)
	$HBoxContainer/Controles.pressed.connect(_on_controles_pressed)
	$HBoxContainer/Sair.pressed.connect(_on_sair_pressed)

func _on_controles_pressed():
	var loading = load("res://Cenas/loading_screen.tscn").instantiate()
	loading.next_scene = "res://Cenas/controles.tscn"
	get_tree().root.add_child(loading)
	queue_free()
	
func _on_campanha_pressed():
	var loading = load("res://Cenas/loading_screen.tscn").instantiate()
	loading.next_scene = "res://Cenas/game.tscn"
	get_tree().root.add_child(loading)
	queue_free()

func _on_multijogador_pressed():
	var loading = load("res://Cenas/loading_screen.tscn").instantiate()
	loading.next_scene = "res://Cenas/mapa_montanhanheve.tscn"
	get_tree().root.add_child(loading)
	queue_free()

func _on_sair_pressed():
	get_tree().quit()
