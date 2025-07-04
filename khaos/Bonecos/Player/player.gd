extends CharacterBody2D

const VELOCIDADE = 300.0
const FORCA_PULO = -400.0
const GRAVIDADE = 900.0

var esta_pulando := false
var esta_atacando := false
var esta_abaixando := false
var esta_bloqueando := false
var direcao_atual := 1 

@onready var animation_player = $AnimationPlayer
@onready var barra_de_vida = $BarraDeVida
@onready var soco_area = $SocoArea

var combo = ["soco_direita", "soco_esquerda", "uppercut"]
var baixo_combo = ["baixo_soco_direita", "baixo_soco_esquerda"]

var contcombo: int = 0
var contcombo_baixo: int = 0

func _ready():
	if barra_de_vida == null:
		print("Erro: Barra de vida não encontrada no nó Player!")
	animation_player.connect("animation_finished", Callable(self, "_quando_animacao_finalizar"))
	soco_area.connect("body_entered", Callable(self, "_on_soco_area_body_entered"))
	print("Sinal area_entered conectado")

func _physics_process(delta: float) -> void:
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
		esta_pulando = true
	else:
		esta_pulando = false

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor() and not esta_atacando:
		velocity.y = FORCA_PULO
		esta_pulando = true

	# Movimento horizontal - Só permite movimento quando não está atacando
	var direcao := Input.get_axis("left", "right")
	
	if not esta_atacando and not esta_abaixando and not esta_bloqueando:
		if direcao != 0:
			velocity.x = direcao * VELOCIDADE
			if direcao * direcao_atual < 0:  # Inverte a direção
				direcao_atual = direcao
				scale.x = -scale.x
		else:
			velocity.x = move_toward(velocity.x, 0, VELOCIDADE)
	else:
		# Durante ataques, trava o movimento horizontal
		velocity.x = 0

	# Ataques (agora com prioridade e trava o movimento)
	if Input.is_action_just_pressed("attack") and not esta_bloqueando and not esta_pulando:
		if Input.is_action_pressed("down") and is_on_floor():
			iniciar_ataque_baixo()
		else:
			iniciar_ataque()

	# Abaixar
	esta_abaixando = Input.is_action_pressed("down") and is_on_floor() and not esta_pulando and not esta_atacando
	if esta_abaixando:
		animation_player.play("crouch")

	# Bloqueio
	esta_bloqueando = Input.is_action_pressed("block") and is_on_floor() and not esta_pulando and not esta_atacando
	if esta_bloqueando:
		animation_player.play("block")

	# Animação de movimento (só muda se não estiver atacando)
	if not esta_atacando:
		if esta_pulando:
			animation_player.play("jump")
		elif direcao != 0 and not esta_abaixando and not esta_bloqueando:
			animation_player.play("run")
		elif not esta_abaixando and not esta_bloqueando:
			animation_player.play("idle")

	move_and_slide()

func iniciar_ataque() -> void:
	if not esta_atacando:
		esta_atacando = true
		contcombo = 0
		velocity.x = 0  # Garante que para completamente ao começar ataque
	else:
		contcombo += 1
		if contcombo >= combo.size():
			contcombo = 0
	animation_player.play(combo[contcombo])

func iniciar_ataque_baixo() -> void:
	if not esta_atacando:
		esta_atacando = true
		contcombo_baixo = 0
		velocity.x = 0  # Garante que para completamente ao começar ataque
	else:
		contcombo_baixo += 1
		if contcombo_baixo >= baixo_combo.size():
			contcombo_baixo = 0
	animation_player.play(baixo_combo[contcombo_baixo])

func _quando_animacao_finalizar(anim_name):
	if anim_name in combo or anim_name in baixo_combo:
		esta_atacando = false

func _on_soco_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("inimigo"):
		
		print("Algo entrou na área de soco: ", body.name)

		if combo[contcombo] == "soco_direita" or combo[contcombo] == "soco_esquerda":
			body.call("Enemy_receber_dano", 5)  
		elif combo[contcombo] == "uppercut":
			body.call("Enemy_receber_dano", 10)

var in_hit_cooldown = false

func Player_receber_dano(dano):
	if (in_hit_cooldown): return
	in_hit_cooldown = true
	
	if barra_de_vida == null:
		return
	if not barra_de_vida.has_method("receber_dano"):
		return
	print(esta_bloqueando)
	if esta_bloqueando:
		dano = dano / 2  
	
	barra_de_vida.receber_dano(dano) 
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	await get_tree().create_timer(.5).timeout
	in_hit_cooldown = false
	
	
	
