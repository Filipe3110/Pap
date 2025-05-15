extends Control

var COLLECTION_ID = "khaos_stats"
var selected_map_path = ""
var selected_map_name = ""
var mapas_desbloqueados = [true, false, false, false] # Apenas o primeiro está desbloqueado

@onready var text = $text

func _ready():
	await carregar_mapa_salvo()
	await carregar_progresso_mapa()  # Carrega o progresso dos mapas desbloqueados
	# DEBUG: Mostrar mapas desbloqueados
	print("Mapas desbloqueados:", mapas_desbloqueados)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"): # ESC
		for i in range(1, mapas_desbloqueados.size()):
			mapas_desbloqueados[i] = true
		text.text = "Todos os mapas foram desbloqueados!"
		print("Mapas desbloqueados via ESC")
		await salvar_progresso_mapa()  # Salva o progresso quando desbloqueia via ESC


func tentar_entrar_mapa(index: int, nome: String, path: String) -> void:
	if index >= 0 and index < mapas_desbloqueados.size():  # Verificação de segurança
		if mapas_desbloqueados[index]:
			selected_map_name = nome
			selected_map_path = path
			await salvar_mapa(nome)
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
	tentar_entrar_mapa(0, "mapa_espaco", "res://Mapas/mapa_espaco.tscn")  # Corrigido o nome do arquivo


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


# SALVA o nome do mapa no Firestore
func salvar_mapa(nome_do_mapa: String) -> void:
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var data = {"selected_map": nome_do_mapa}
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.update(auth.localid, data)

		print("Salvando mapa:", nome_do_mapa, "para ID:", auth.localid)

		var resultado = await task.task_finished

		if resultado.success:
			print("Mapa salvo com sucesso no Firestore!")
		else:
			print("Erro ao salvar mapa:", resultado.error_message)


# CARREGA o nome do último mapa salvo do Firestore
func carregar_mapa_salvo() -> void:
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.get_doc(auth.localid)

		var resultado = await task.task_finished

		if resultado.success and resultado.document.doc_fields.has("selected_map"):
			var mapa = resultado.document.doc_fields["selected_map"]
			text.text = "Último mapa salvo: %s" % mapa.capitalize()
			print("Mapa salvo carregado:", mapa)
		else:
			text.text = "Nenhum mapa salvo encontrado"
			print("Nenhum mapa salvo encontrado")


# SALVA o progresso dos mapas desbloqueados no Firestore
func salvar_progresso_mapa() -> void:
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var data = {"unlocked_maps": mapas_desbloqueados}
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.update(auth.localid, data)

		print("Salvando progresso dos mapas para ID:", auth.localid)

		var resultado = await task.task_finished

		if resultado.success:
			print("Progresso dos mapas salvo com sucesso no Firestore!")
		else:
			print("Erro ao salvar progresso dos mapas:", resultado.error_message)


# CARREGA o progresso dos mapas desbloqueados do Firestore
func carregar_progresso_mapa() -> void:
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.get_doc(auth.localid)

		var resultado = await task.task_finished

		if resultado.success and resultado.document.doc_fields.has("unlocked_maps"):
			mapas_desbloqueados = resultado.document.doc_fields["unlocked_maps"]
			print("Progresso dos mapas carregado:", mapas_desbloqueados)
		else:
			print("Nenhum progresso de mapa encontrado, usando padrão")
