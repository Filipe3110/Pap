extends CharacterBody2D

@export var vida_maxima: int = 100
var vida_atual: int

@onready var barra_de_vida = $BarraDeVida
@onready var animation_player = $AnimationPlayer

func _ready():
	vida_atual = vida_maxima
	atualizar_barra_de_vida()

func receber_dano(dano: int):
	vida_atual -= dano
	vida_atual = max(vida_atual, 0)  
	print("Inimigo recebeu ", dano, " de dano. Vida restante: ", vida_atual)
	
	atualizar_barra_de_vida()
	
	if vida_atual <= 0:
		morrer()

func atualizar_barra_de_vida():
	if barra_de_vida:
		barra_de_vida.value = vida_atual
		barra_de_vida.max_value = vida_maxima

func morrer():
	print("Inimigo morreu!")
	queue_free() 

func _on_area_ataque_body_entered(body: Node2D):
	if body.is_in_group("player"):
		print("Inimigo detectou o jogador na área de ataque!")
