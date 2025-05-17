extends Control

# Cores para as bordas
const COR_P1 = Color(0, 0, 1)        # Azul
const COR_P2 = Color(1, 0, 0)        # Vermelho
const COR_AMBOS = Color(0, 1, 0) # Roxo para escolha dupla
const COR = Color(255, 255, 255)

# Variáveis de estado
var escolha_p1: String = ""
var escolha_p2: String = ""
var jogador_atual: int = 1  # Começa no Player 1

@onready var botao_play = $Play

# Mapas disponíveis (4 mapas)
var mapas = [
	"res://Mapas/Multmapa_montanhanheve.tscn",
	"res://Mapas/Multmapa_espço.tscn",
	"res://Mapas/Multmapa_barco.tscn",
	"res://Mapas/Multmapa_deserto.tscn"
]

# Guarda quem escolheu qual mapa
var selecao_mapa = {
	"res://Mapas/Multmapa_espço.tscn": [],
	"res://Mapas/Multmapa_montanhanheve.tscn": [],
	"res://Mapas/Multmapa_barco.tscn": [],
	"res://Mapas/Multmapa_deserto.tscn": []
}

func _ready():
	randomize()
	botao_play.visible = false
	print("🎮 Player 1, escolha o mapa.")
	update_estado()
	# Atualiza bordas de todos os mapas inicialmente
	for mapa_path in mapas:
		var borda = get_borda_por_mapa(mapa_path)
		if borda != null:
			atualizar_borda_mapa(mapa_path, borda)

# Atualiza a cor da borda de um mapa
func atualizar_borda_mapa(mapa: String, borda: ColorRect):
	var jogadores = selecao_mapa[mapa]
	
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

# Hover functions para todos mapas

func _on_mapa_1_mouse_entered():
	if jogador_atual == 1:
		$Borda1.color = COR_P1
	elif jogador_atual == 2:
		$Borda1.color = COR_P2

func _on_mapa_1_mouse_exited():
	atualizar_borda_mapa("res://Mapas/Multmapa_espço.tscn", $Borda1)

func _on_mapa_2_mouse_entered():
	if jogador_atual == 1:
		$Borda2.color = COR_P1
	elif jogador_atual == 2:
		$Borda2.color = COR_P2

func _on_mapa_2_mouse_exited():
	atualizar_borda_mapa("res://Mapas/Multmapa_montanhanheve.tscn", $Borda2)

func _on_mapa_3_mouse_entered():
	if jogador_atual == 1:
		$Borda3.color = COR_P1
	elif jogador_atual == 2:
		$Borda3.color = COR_P2

func _on_mapa_3_mouse_exited():
	atualizar_borda_mapa("res://Mapas/Multmapa_barco.tscn", $Borda3)

func _on_mapa_4_mouse_entered():
	if jogador_atual == 1:
		$Borda4.color = COR_P1
	elif jogador_atual == 2:
		$Borda4.color = COR_P2

func _on_mapa_4_mouse_exited():
	atualizar_borda_mapa("res://Mapas/Multmapa_deserto.tscn", $Borda4)

# Seleção do mapa pelo jogador atual
func selecionar_mapa(mapa: String) -> void:
	if jogador_atual == 1:
		if escolha_p1 != "":
			selecao_mapa[escolha_p1].erase(1)
			atualizar_borda_mapa(escolha_p1, get_borda_por_mapa(escolha_p1))
		escolha_p1 = mapa
		selecao_mapa[mapa].append(1)
		atualizar_borda_mapa(mapa, get_borda_por_mapa(mapa))
		print("✅ Player 1 escolheu:", mapa)
		jogador_atual = 2
		print("🎮 Player 2, escolha o mapa.")
	elif jogador_atual == 2:
		if escolha_p2 != "":
			selecao_mapa[escolha_p2].erase(2)
			atualizar_borda_mapa(escolha_p2, get_borda_por_mapa(escolha_p2))
		escolha_p2 = mapa
		selecao_mapa[mapa].append(2)
		atualizar_borda_mapa(mapa, get_borda_por_mapa(mapa))
		print("✅ Player 2 escolheu:", mapa)
		jogador_atual = 3
		print("✅ Ambos os jogadores escolheram! Clique em 'Play'.")
		botao_play.visible = true
	update_estado()

# Cancelar seleção com 'ui_cancel'
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if jogador_atual == 2 and escolha_p1 != "":
			selecao_mapa[escolha_p1].erase(1)
			atualizar_borda_mapa(escolha_p1, get_borda_por_mapa(escolha_p1))
			print("🔙 Player 1 cancelou a escolha. Escolha novamente.")
			escolha_p1 = ""
			jogador_atual = 1
			botao_play.visible = false
		elif jogador_atual == 3 and escolha_p2 != "":
			selecao_mapa[escolha_p2].erase(2)
			atualizar_borda_mapa(escolha_p2, get_borda_por_mapa(escolha_p2))
			print("🔙 Player 2 cancelou a escolha. Escolha novamente.")
			escolha_p2 = ""
			jogador_atual = 2
			botao_play.visible = false
		update_estado()

func update_estado():
	if jogador_atual == 1:
		print("🟣 Player 1 deve escolher.")
	elif jogador_atual == 2:
		print("🔵 Player 2 deve escolher.")
	elif jogador_atual == 3:
		print("✅ Ambos escolheram.")

# Botões dos mapas ligados no editor para chamar essa função
func _on_mapa_1_pressed():
	selecionar_mapa("res://Mapas/Multmapa_espço.tscn")

func _on_mapa_2_pressed():
	selecionar_mapa("res://Mapas/Multmapa_montanhanheve.tscn")

func _on_mapa_3_pressed():
	selecionar_mapa("res://Mapas/Multmapa_barco.tscn")

func _on_mapa_4_pressed():
	selecionar_mapa("res://Mapas/Multmapa_deserto.tscn")

# Botão play: escolhe aleatoriamente entre as duas escolhas dos jogadores
func _on_play_pressed() -> void:
	if escolha_p1 != "" and escolha_p2 != "":
		var escolhido = escolha_p1 if randi() % 2 == 0 else escolha_p2
		print("🎲 Mapa sorteado aleatoriamente:", escolhido)
		carregar_cena_com_loading(escolhido)
	else:
		print("⚠️ Ainda faltam escolhas.")

# Botão para escolher mapa aleatório (random)
func _on_mapa_r_pressed():
	# Escolhe aleatoriamente um dos 4 mapas e seleciona para o jogador atual
	var mapa_aleatorio = mapas[randi() % mapas.size()]
	print("🎲 Mapa aleatório escolhido para Player %d: %s" % [jogador_atual, mapa_aleatorio])
	selecionar_mapa(mapa_aleatorio)

func _on_mapa_r_mouse_entered():
	if jogador_atual == 1:
		$BordaR.color = COR_P1
	elif jogador_atual == 2:
		$BordaR.color = COR_P2

func _on_mapa_r_mouse_exited():
	# No caso do random, só fica transparente, pois não é selecionável fixo
	$BordaR.color = COR

func carregar_cena_com_loading(caminho_da_proxima_cena):
	var loading = load("res://Cenas/UI/loading_screen.tscn").instantiate()
	loading.next_scene = caminho_da_proxima_cena
	get_tree().root.add_child(loading)

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")
