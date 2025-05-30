extends CanvasLayer

@onready var barra_sprite = $BarraSprite  
signal jogador_morreu(jogador_id)  # Adicione esta linha

var vida_atual = 100
var vida_maxima = 100  
var esta_bloqueando = false 

func _ready():
	update_barra()
	
func receber_dano(dano):
	if esta_bloqueando: 
		dano = dano / 2 

	vida_atual -= dano
	vida_atual = clamp(vida_atual, 0, vida_maxima)  

	if vida_atual <= 0:
		vida_atual = 0
		emit_signal("jogador_morreu", get_parent().name) 
	update_barra()

func update_barra():
	barra_sprite.frame = vida_atual
