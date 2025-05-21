extends Control

# Cores para as bordas
const COR_P1 = Color(0, 0, 1)        # Azul
const COR_P2 = Color(1, 0, 0)        # Vermelho
const COR_AMBOS = Color(0, 1, 0)     # Verde para escolha dupla
const COR = Color(255, 255, 255)     # Branco

# Variáveis de estado
var escolha_p1_mapa: String = ""
var escolha_p2_mapa: String = ""
var escolha_p1_pers: String = ""
var escolha_p2_pers: String = ""
var fase_selecao: int = 1  # 1 = seleção de mapa, 2 = seleção de personagem
var jogador_atual: int = 1  # Começa no Player 1

@onready var botao_play = $Play
@onready var personagens_container = $PersonagensContainer  # Container com os personagens     

# Mapas disponíveis (4 mapas)
var mapas = [
	"res://Mapas/Multmapa_montanhanheve.tscn",
	"res://Mapas/Multmapa_espço.tscn",
	"res://Mapas/Multmapa_barco.tscn",
	"res://Mapas/Multmapa_deserto.tscn"
]

# Personagens disponíveis (4 personagens)
var personagens = [
	"Pers1",
	"Pers2",
	"Pers3",
	"Pers4"
]

# Guarda quem escolheu qual mapa
var selecao_mapa = {
	"res://Mapas/Multmapa_espço.tscn": [],
	"res://Mapas/Multmapa_montanhanheve.tscn": [],
	"res://Mapas/Multmapa_barco.tscn": [],
	"res://Mapas/Multmapa_deserto.tscn": []
}

# Guarda quem escolheu qual personagem
var selecao_personagem = {
	"Pers1": [],
	"Pers2": [],
	"Pers3": [],
	"Pers4": []
}

func _ready():
	randomize()
	botao_play.visible = false
	personagens_container.visible = false  # Esconde os personagens inicialmente
	update_estado()
	# Atualiza bordas de todos os mapas inicialmente
	for mapa_path in mapas:
		var borda = get_borda_por_mapa(mapa_path)
		if borda != null:
			atualizar_borda_mapa(mapa_path, borda)
	# Atualiza bordas de todos os personagens inicialmente
	for pers in personagens:
		var borda = get_borda_por_personagem(pers)
		if borda != null:
			atualizar_borda_personagem(pers, borda)

# Atualiza a cor da borda de um mapa
func atualizar_borda_mapa(mapa: String, borda: ColorRect):
	var jogadores = selecao_mapa[mapa]
	
	if jogadores.size() == 0:
		borda.color = COR
	elif jogadores.size() == 1:
		borda.color = COR_P1 if jogadores[0] == 1 else COR_P2
	else:
		borda.color = COR_AMBOS

# Atualiza a cor da borda de um personagem
func atualizar_borda_personagem(pers: String, borda: ColorRect):
	var jogadores = selecao_personagem[pers]
	
	if jogadores.size() == 0:
		borda.color = COR
	elif jogadores.size() == 1:
		borda.color = COR_P1 if jogadores[0] == 1 else COR_P2
	else:
		borda.color = COR_AMBOS

# Função auxiliar para obter o ColorRect da borda pelo caminho do mapa
func get_borda_por_mapa(mapa: String) -> ColorRect:
	match mapa:
		"res://Mapas/Multmapa_espço.tscn":
			return $Borda1
		"res://Mapas/Multmapa_montanhanheve.tscn":
			return $Borda2
		"res://Mapas/Multmapa_barco.tscn":
			return $Borda3
		"res://Mapas/Multmapa_deserto.tscn":
			return $Borda4
		_:
			return null

# Função auxiliar para obter o ColorRect da borda pelo nome do personagem
func get_borda_por_personagem(pers: String) -> ColorRect:
	match pers:
		"Pers1":
			return $PersonagensContainer/BordaP1
		"Pers2":
			return $PersonagensContainer/BordaP2
		"Pers3":
			return $PersonagensContainer/BordaP3
		"Pers4":
			return $PersonagensContainer/BordaP4
		_:
			return null

# Hover functions para todos mapas
func _on_mapa_1_mouse_entered():
	if fase_selecao == 1 and jogador_atual == 1:
		$Borda1.color = COR_P1
	elif fase_selecao == 1 and jogador_atual == 2:
		$Borda1.color = COR_P2

func _on_mapa_1_mouse_exited():
	atualizar_borda_mapa("res://Mapas/Multmapa_espço.tscn", $Borda1)

func _on_mapa_2_mouse_entered():
	if fase_selecao == 1 and jogador_atual == 1:
		$Borda2.color = COR_P1
	elif fase_selecao == 1 and jogador_atual == 2:
		$Borda2.color = COR_P2

func _on_mapa_2_mouse_exited():
	atualizar_borda_mapa("res://Mapas/Multmapa_montanhanheve.tscn", $Borda2)

func _on_mapa_3_mouse_entered():
	if fase_selecao == 1 and jogador_atual == 1:
		$Borda3.color = COR_P1
	elif fase_selecao == 1 and jogador_atual == 2:
		$Borda3.color = COR_P2

func _on_mapa_3_mouse_exited():
	atualizar_borda_mapa("res://Mapas/Multmapa_barco.tscn", $Borda3)

func _on_mapa_4_mouse_entered():
	if fase_selecao == 1 and jogador_atual == 1:
		$Borda4.color = COR_P1
	elif fase_selecao == 1 and jogador_atual == 2:
		$Borda4.color = COR_P2

func _on_mapa_4_mouse_exited():
	atualizar_borda_mapa("res://Mapas/Multmapa_deserto.tscn", $Borda4)

# Hover functions para todos personagens
func _on_pers_1_mouse_entered():
	if fase_selecao == 2 and jogador_atual == 1:
		$PersonagensContainer/BordaP1.color = COR_P1
	elif fase_selecao == 2 and jogador_atual == 2:
		$PersonagensContainer/BordaP1.color = COR_P2

func _on_pers_1_mouse_exited():
	atualizar_borda_personagem("Pers1", $PersonagensContainer/BordaP1)

func _on_pers_2_mouse_entered():
	if fase_selecao == 2 and jogador_atual == 1:
		$PersonagensContainer/BordaP2.color = COR_P1
	elif fase_selecao == 2 and jogador_atual == 2:
		$PersonagensContainer/BordaP2.color = COR_P2

func _on_pers_2_mouse_exited():
	atualizar_borda_personagem("Pers2", $PersonagensContainer/BordaP2)

func _on_pers_3_mouse_entered():
	if fase_selecao == 2 and jogador_atual == 1:
		$PersonagensContainer/BordaP3.color = COR_P1
	elif fase_selecao == 2 and jogador_atual == 2:
		$PersonagensContainer/BordaP3.color = COR_P2

func _on_pers_3_mouse_exited():
	atualizar_borda_personagem("Pers3", $PersonagensContainer/BordaP3)

func _on_pers_4_mouse_entered():
	if fase_selecao == 2 and jogador_atual == 1:
		$PersonagensContainer/BordaP4.color = COR_P1
	elif fase_selecao == 2 and jogador_atual == 2:
		$PersonagensContainer/BordaP4.color = COR_P2

func _on_pers_4_mouse_exited():
	atualizar_borda_personagem("Pers4", $PersonagensContainer/BordaP4)

# Seleção do mapa pelo jogador atual
func selecionar_mapa(mapa: String) -> void:
	if fase_selecao != 1:
		return
	
	if jogador_atual == 1:
		if escolha_p1_mapa != "":
			selecao_mapa[escolha_p1_mapa].erase(1)
			atualizar_borda_mapa(escolha_p1_mapa, get_borda_por_mapa(escolha_p1_mapa))
		escolha_p1_mapa = mapa
		selecao_mapa[mapa].append(1)
		atualizar_borda_mapa(mapa, get_borda_por_mapa(mapa))
		jogador_atual = 2
	elif jogador_atual == 2:
		if escolha_p2_mapa != "":
			selecao_mapa[escolha_p2_mapa].erase(2)
			atualizar_borda_mapa(escolha_p2_mapa, get_borda_por_mapa(escolha_p2_mapa))
		escolha_p2_mapa = mapa
		selecao_mapa[mapa].append(2)
		atualizar_borda_mapa(mapa, get_borda_por_mapa(mapa))
		# Transição para seleção de personagens
		fase_selecao = 2
		jogador_atual = 1
		personagens_container.visible = true
	update_estado()

# Seleção do personagem pelo jogador atual
func selecionar_personagem(pers: String) -> void:
	if fase_selecao != 2:
		return
	
	if jogador_atual == 1:
		if escolha_p1_pers != "":
			selecao_personagem[escolha_p1_pers].erase(1)
			atualizar_borda_personagem(escolha_p1_pers, get_borda_por_personagem(escolha_p1_pers))
		escolha_p1_pers = pers
		selecao_personagem[pers].append(1)
		atualizar_borda_personagem(pers, get_borda_por_personagem(pers))
		jogador_atual = 2
	elif jogador_atual == 2:
		if escolha_p2_pers != "":
			selecao_personagem[escolha_p2_pers].erase(2)
			atualizar_borda_personagem(escolha_p2_pers, get_borda_por_personagem(escolha_p2_pers))
		escolha_p2_pers = pers
		selecao_personagem[pers].append(2)
		atualizar_borda_personagem(pers, get_borda_por_personagem(pers))
		jogador_atual = 3
		botao_play.visible = true
	update_estado()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if fase_selecao == 1:
			if jogador_atual == 2 and escolha_p1_mapa != "":
				selecao_mapa[escolha_p1_mapa].erase(1)
				atualizar_borda_mapa(escolha_p1_mapa, get_borda_por_mapa(escolha_p1_mapa))
				escolha_p1_mapa = ""
				jogador_atual = 1
			elif jogador_atual == 1 and escolha_p2_mapa != "":
				selecao_mapa[escolha_p2_mapa].erase(2)
				atualizar_borda_mapa(escolha_p2_mapa, get_borda_por_mapa(escolha_p2_mapa))
				escolha_p2_mapa = ""
				jogador_atual = 2
		elif fase_selecao == 2:
			if jogador_atual == 2 and escolha_p1_pers != "":
				selecao_personagem[escolha_p1_pers].erase(1)
				atualizar_borda_personagem(escolha_p1_pers, get_borda_por_personagem(escolha_p1_pers))
				escolha_p1_pers = ""
				jogador_atual = 1
				botao_play.visible = false
			elif jogador_atual == 3 and escolha_p2_pers != "":
				selecao_personagem[escolha_p2_pers].erase(2)
				atualizar_borda_personagem(escolha_p2_pers, get_borda_por_personagem(escolha_p2_pers))
				escolha_p2_pers = ""
				jogador_atual = 2
				botao_play.visible = false
		update_estado()

func update_estado():
	pass  # Esta função agora está vazia já que removemos todos os prints

# Botões dos mapas ligados no editor para chamar essa função
func _on_mapa_1_pressed():
	selecionar_mapa("res://Mapas/Multmapa_espço.tscn")

func _on_mapa_2_pressed():
	selecionar_mapa("res://Mapas/Multmapa_montanhanheve.tscn")

func _on_mapa_3_pressed():
	selecionar_mapa("res://Mapas/Multmapa_barco.tscn")

func _on_mapa_4_pressed():
	selecionar_mapa("res://Mapas/Multmapa_deserto.tscn")

# Botões dos personagens ligados no editor para chamar essa função
func _on_pers_1_pressed():
	selecionar_personagem("Pers1")

func _on_pers_2_pressed():
	selecionar_personagem("Pers2")

func _on_pers_3_pressed():
	selecionar_personagem("Pers3")

func _on_pers_4_pressed():
	selecionar_personagem("Pers4")

# Botão para escolher mapa aleatório (random)
func _on_mapa_r_pressed():
	# Escolhe aleatoriamente um dos 4 mapas e seleciona para o jogador atual
	var mapa_aleatorio = mapas[randi() % mapas.size()]
	selecionar_mapa(mapa_aleatorio)

func _on_mapa_r_mouse_entered():
	if fase_selecao == 1 and jogador_atual == 1:
		$BordaR.color = COR_P1
	elif fase_selecao == 1 and jogador_atual == 2:
		$BordaR.color = COR_P2

func _on_mapa_r_mouse_exited():
	$BordaR.color = COR

# Botão para escolher personagem aleatório (random)
func _on_pers_r_pressed():
	# Escolhe aleatoriamente um dos 4 personagens e seleciona para o jogador atual
	var pers_aleatorio = personagens[randi() % personagens.size()]
	selecionar_personagem(pers_aleatorio)

func _on_pers_r_mouse_entered():
	if fase_selecao == 2 and jogador_atual == 1:
		$BordaR.color = COR_P1
	elif fase_selecao == 2 and jogador_atual == 2:
		$BordaR.color = COR_P2

func _on_pers_r_mouse_exited():
	$BordaR.color = COR

# Botão play: inicia o jogo com as escolhas feitas
func _on_play_pressed() -> void:
	if escolha_p1_mapa != "" and escolha_p2_mapa != "" and escolha_p1_pers != "" and escolha_p2_pers != "":
		var mapa_escolhido = escolha_p1_mapa if randi() % 2 == 0 else escolha_p2_mapa
		Global.personagem_jogador1 = escolha_p1_pers
		Global.personagem_jogador2 = escolha_p2_pers
		carregar_cena_com_loading(mapa_escolhido)

func carregar_cena_com_loading(caminho_da_proxima_cena):
	var loading = load("res://Cenas/UI/loading_screen.tscn").instantiate()
	loading.next_scene = caminho_da_proxima_cena
	get_tree().root.add_child(loading)

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")
