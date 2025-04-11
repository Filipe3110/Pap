extends Control


@onready var p1 = $"Butões/Player"
@onready var p2 = $"Butões/Player2"
@onready var sounds = $"Butões/Sounds2"
@onready var account = $"Butões/account"

@onready var lp1 =$ScrollContainer/VBoxContainer/P1
#@onready var lp2 =$ScrollContainer/VBoxContainer/P2

func _ready():
	p1.play("idle")
	p2.play("idle")
	sounds.play("idle")
	account.play("idle")
	
func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")
	
func _on_options_pressed() -> void:
	lp1.visible = true

func _on_player_1_pressed() -> void:
	p1.play("player1")
	#lp2.visible = true 
	lp1.visible = false





















func _on_player_1_mouse_entered() -> void:
	p1.play("player1")
func _on_player_1_mouse_exited() -> void:
	p1.play("idle")
func _on_player_3_mouse_entered() -> void:
	p2.play("player2")
func _on_player_3_mouse_exited() -> void:
	p2.play("idle")
func _on_sounds_mouse_entered() -> void:
	sounds.play("msc")
func _on_sounds_mouse_exited() -> void:
	sounds.play("idle")
func _on_account_2_mouse_entered() -> void:
	account.play("conta")
func _on_account_2_mouse_exited() -> void:
	account.play("idle")
