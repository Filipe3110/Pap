extends Control

func _ready():
	$Voltar.pressed.connect(_on_voltar_pressed)

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://Cenas/tela_inicial.tscn")
