extends CharacterBody2D

const VELOCIDADE = 300.0
const FORCA_PULO = -400.0
var esta_pulando := false
var esta_atacando := false
var esta_abaixando := false
var esta_bloqueando := false
var direcao_atual := 1  

@onready var animation_player = $AnimationPlayer
@onready var barra_de_vida = $BarraDeVida
@onready var soco_area = $SocoArea
var combo = ["soco_direita", "soco_esquerda", "uppercut"]
var Baixo_combo = ["baixo_soco_direita", "baixo_soco_esquerda"]

var contcombo: int = 0
var contcombo_baixo: int = 0

func _ready():
	if barra_de_vida == null:
		print("Erro: Barra de vida não encontrada no nó Player!")
	animation_player.connect("animation_finished", Callable(self, "_quando_animacao_finalizar"))
	soco_area.connect("body_entered", Callable(self, "_on_soco_area_body_entered"))
	print("Sinal area_entered conectado")


func iniciar_ataque() -> void:
	if not esta_atacando:
		esta_atacando = true
		contcombo = 0
	else:
		contcombo += 1
		if contcombo >= combo.size():
			contcombo = 0
	animation_player.play(combo[contcombo])

func iniciar_ataque_baixo() -> void:
	if not esta_atacando:
		esta_atacando = true
		contcombo_baixo = 0
	else:
		contcombo_baixo += 1
		if contcombo_baixo >= Baixo_combo.size():
			contcombo_baixo = 0
	animation_player.play(Baixo_combo[contcombo_baixo])

func _quando_animacao_finalizar(anim_name):
	if anim_name in combo or anim_name in Baixo_combo:
		esta_atacando = false

func Enemy_receber_dano(dano):
	if barra_de_vida == null:
		return
	if not barra_de_vida.has_method("receber_dano"):
		return
	print("Dano recebido: ", dano)
	barra_de_vida.receber_dano(dano)

func morrer():
	get_tree().change_scene_to_file("res://Cenas/main.tscn")


func _on_soco_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if combo[contcombo] == "soco_direita" or combo[contcombo] == "soco_esquerda":
			body.call("Player_receber_dano", 5)  
		elif combo[contcombo] == "uppercut":
			body.call("Player_receber_dano", 10)
