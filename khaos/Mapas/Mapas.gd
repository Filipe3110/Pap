extends Node2D

@onready var options = $Options_ingame
@onready var pause_menu = $Menu_pausa
@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var vitoria_canvas = $Vitoria  
@onready var vitoria_label = $Vitoria/VitoriaLabel

var is_paused = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pause_menu.visible = false
	options.visible = false
	vitoria_canvas.visible = false  
	
	p1.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))
	p2.get_node("BarraDeVida").connect("jogador_morreu", Callable(self, "_on_jogador_morreu"))

func _on_jogador_morreu(jogador_id):
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Mostra quem venceu
	var vencedor = "Player 2" if jogador_id == "Player1" else "Player 1"
	vitoria_label.text = vencedor + " Venceu!"

	vitoria_canvas.visible = true
	pause_menu.visible = false  # Garante que o menu de pausa está oculto
	options.visible = false     # Garante que as opções estão ocultas

func _input(event):
	if event.is_action_pressed("ui_cancel") and not vitoria_canvas.visible:
		if options.visible:
			# Volta para o menu de pausa se estiver nas opções
			options.visible = false
			pause_menu.visible = true
		elif is_paused:
			# Despausar se já estiver pausado
			unpause_game()
		else:
			# Pausar o jogo
			pause_game()
		
func pause_game():
	is_paused = true
	get_tree().paused = true
	pause_menu.visible = true
	options.visible = false  # Garante que as opções estão ocultas
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unpause_game():
	is_paused = false
	get_tree().paused = false
	pause_menu.visible = false
	options.visible = false  # Garante que as opções estão ocultas
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_options_pressed():
	options.visible = true
	pause_menu.visible = false

func _on_back_pressed() -> void:
	get_tree().paused = false  # Despausar antes de mudar de cena
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")

func _on_change_map_pressed() -> void:
	get_tree().paused = false  # Despausar antes de mudar de cena
	get_tree().change_scene_to_file("res://Cenas/Modo_História/Tela_dos_mapas.tscn")

func _on_resume_pressed() -> void:
	unpause_game()
