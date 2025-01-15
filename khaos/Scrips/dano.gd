extends Node2D

var dano = 2

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.name == "Player2":  
		body.receber_dano(dano)
