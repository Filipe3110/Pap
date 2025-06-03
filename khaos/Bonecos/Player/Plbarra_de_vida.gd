extends CanvasLayer


@onready var barra_sprite = $BarraSprite  
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
		var root_nome = get_parent().get_parent().name  
		emit_signal("jogador_morreu", get_parent())  
	update_barra()

func update_barra():
	barra_sprite.frame = vida_atual
