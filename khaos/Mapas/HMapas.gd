extends Node2D

var COLLECTION_ID = "khaos_stats"
var selected_map_path = ""
var selected_map_name = ""
var mapas_desbloqueados = [true, false, false, false]  # Espaço sempre desbloqueado

@onready var text = $Text
@onready var mapa1_btn = $Borda1/Mapa1
@onready var mapa2_btn = $Borda2/Mapa2
@onready var mapa3_btn = $Mapa3
@onready var mapa4_btn = $Mapa4

func _ready():
	await carregar_progresso_mapa()
	atualizar_botoes_mapas()
	print("Estado inicial dos mapas:", mapas_desbloqueados)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		# Atalho de desenvolvimento: desbloqueia todos com ESC
		for i in range(1, mapas_desbloqueados.size()):
			mapas_desbloqueados[i] = true
		text.text = "Todos os mapas desbloqueados (modo dev)"
		await salvar_progresso_mapa()
		atualizar_botoes_mapas()

# Função chamada pelo Global.gd quando o jogador vence
func desbloquear_nivel_atual():
	var ultimo_desbloqueado = mapas_desbloqueados.rfind(true)
	if ultimo_desbloqueado < mapas_desbloqueados.size() - 1:
		mapas_desbloqueados[ultimo_desbloqueado + 1] = true
		text.text = "Mapa %d desbloqueado!" % (ultimo_desbloqueado + 2)
		await salvar_progresso_mapa()
		atualizar_botoes_mapas()

func atualizar_botoes_mapas():
	mapa1_btn.disabled = !mapas_desbloqueados[0]
	mapa2_btn.disabled = !mapas_desbloqueados[1]
	mapa3_btn.disabled = !mapas_desbloqueados[2]
	mapa4_btn.disabled = !mapas_desbloqueados[3]

func tentar_entrar_mapa(index: int, nome: String, path: String) -> void:
	if index >= 0 and index < mapas_desbloqueados.size():
		if mapas_desbloqueados[index]:
			selected_map_name = nome
			selected_map_path = path
			carregar_cena_com_loading(path)
		else:
			text.text = "Mapa (%s) bloqueado!" % nome.capitalize()
	else:
		text.text = "Erro: Índice inválido!"

# Botões dos mapas (conecte esses sinais no editor)
func _on_mapa_1_pressed(): tentar_entrar_mapa(0, "mapa_espaco", "res://Mapas/mapa_espaco.tscn")
func _on_mapa_2_pressed(): tentar_entrar_mapa(1, "mapa_neve", "res://Mapas/mapa_montanhanheve.tscn")
func _on_mapa_3_pressed(): tentar_entrar_mapa(2, "mapa_floresta", "res://Mapas/mapa_floresta.tscn")
func _on_mapa_4_pressed(): tentar_entrar_mapa(3, "mapa_deserto", "res://Mapas/mapa_deserto.tscn")

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")

func carregar_cena_com_loading(caminho: String):
	var loading = load("res://Cenas/UI/loading_screen.tscn").instantiate()
	loading.next_scene = caminho
	get_tree().root.add_child(loading)
	queue_free()

# Firestore functions
func salvar_progresso_mapa() -> void:
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var task = Firebase.Firestore.collection(COLLECTION_ID).update(auth.localid, {
			"unlocked_maps": mapas_desbloqueados
		})
		var result = await task.task_finished
		if result is FirestoreDocument:
			print("Progresso salvo com sucesso!")
		else:
			print("Erro ao salvar progresso")

func carregar_progresso_mapa() -> void:
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var task = Firebase.Firestore.collection(COLLECTION_ID).get_doc(auth.localid)
		var document = await task.task_finished
		
		if document is FirestoreDocument and "unlocked_maps" in document.doc_fields:
			var dados = document.doc_fields["unlocked_maps"]
			if dados.size() == 4:  # Garante que temos 4 mapas
				mapas_desbloqueados = [true] + dados.slice(1)  # Mantém mapa 1 sempre desbloqueado
				print("Progresso carregado:", mapas_desbloqueados)
