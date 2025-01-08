extends Area2D

var dano = 2

func _on_body_entered(body):
	if body.name == "Player" or body.name == "Player2":  
		body.receber_dano(dano)
