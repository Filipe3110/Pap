extends CanvasLayer

@onready var barra_sprite = $BarraSprite  

var vida_atual = 100 
var vida_maxima = 100  

func _ready():
	update_barra()
	
func receber_dano(dano):
	vida_atual -= dano
	vida_atual = clamp(vida_atual, 0, vida_maxima)  

	if vida_atual <= 0:
		get_parent().morrer()  

	update_barra()

func update_barra():
	barra_sprite.frame = vida_atual
