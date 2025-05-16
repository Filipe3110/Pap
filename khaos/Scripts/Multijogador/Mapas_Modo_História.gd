extends Control

var COLLECTION_ID = "khaos_stats"
var selected_map_path = ""
var selected_map_name = ""
# Mapa do espaço (índice 0) sempre desbloqueado, outros bloqueados inicialmente
var mapas_desbloqueados = [true, false, false, false]

@onready var text = $Text

func _ready():
	await carregar_progresso_mapa()
	print("Mapas desbloqueados:", mapas_desbloqueados)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		# Atalho para desbloquear todos os mapas (opcional)
		for i in range(1, mapas_desbloqueados.size()):
			mapas_desbloqueados[i] = true
		text.text = "Todos os mapas foram desbloqueados!"
		print("Mapas desbloqueados via ESC")
		await salvar_progresso_mapa()

func tentar_entrar_mapa(index: int, nome: String, path: String) -> void:
	if index >= 0 and index < mapas_desbloqueados.size():
		if mapas_desbloqueados[index]:
			selected_map_name = nome
			selected_map_path = path
			carregar_cena_com_loading(path)
		else:
			text.text = "Mapa (%s) está bloqueado!" % nome.capitalize()
			print("Tentativa de entrar no mapa bloqueado:", nome)
	else:
		text.text = "Erro: Índice de mapa inválido!"
		print("Índice de mapa inválido:", index)

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")

func _on_mapa_1_pressed() -> void:
	tentar_entrar_mapa(0, "mapa_espaco", "res://Mapas/mapa_espaco.tscn")

func _on_mapa_2_pressed() -> void:
	tentar_entrar_mapa(1, "mapa_neve", "res://Mapas/mapa_montanhanheve.tscn")

func _on_mapa_3_pressed() -> void:
	tentar_entrar_mapa(2, "mapa_floresta", "res://Mapas/mapa_floresta.tscn")

func _on_mapa_4_pressed() -> void:
	tentar_entrar_mapa(3, "mapa_deserto", "res://Mapas/mapa_deserto.tscn")

func carregar_cena_com_loading(caminho_da_proxima_cena: String) -> void:
	var loading = load("res://Cenas/UI/loading_screen.tscn").instantiate()
	loading.next_scene = caminho_da_proxima_cena
	get_tree().root.add_child(loading)
	queue_free()

func salvar_progresso_mapa() -> void:
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		# Garante que o mapa do espaço sempre aparece como desbloqueado
		var dados_para_salvar = {"unlocked_maps": mapas_desbloqueados}
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.update(auth.localid, dados_para_salvar)

		print("Salvando progresso dos mapas para ID:", auth.localid)

		var document = await task.task_finished
		if document is FirestoreDocument:
			print("Progresso dos mapas salvo com sucesso no Firestore!")
		else:
			print("Erro ao salvar progresso dos mapas")

func carregar_progresso_mapa() -> void:
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.get_doc(auth.localid)

		var document = await task.task_finished
		if document is FirestoreDocument and document.doc_fields.has("unlocked_maps"):
			var progresso_salvo = document.doc_fields["unlocked_maps"]
			# Mantém o mapa do espaço desbloqueado, atualiza os outros conforme salvo
			mapas_desbloqueados = [true] + progresso_salvo.slice(1, progresso_salvo.size())
			print("Progresso dos mapas carregado:", mapas_desbloqueados)
		else:
			# Se não encontrar dados, usa o padrão (mapa do espaço desbloqueado, outros bloqueados)
			print("Nenhum progresso de mapa encontrado, usando padrão")
			mapas_desbloqueados = [true, false, false, false]
