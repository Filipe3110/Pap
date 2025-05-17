extends Control

var COLLECTION_ID = "khaos_stats"

@onready var map_buttons = {
	"map1": $MapContainer/Map1,
	"map2": $MapContainer/Map2,
	"map3": $MapContainer/Map3,
	"map4": $MapContainer/Map4,
}

@onready var text_label = $text

func _ready():
	load_unlocked_maps()

func load_unlocked_maps():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		print("Autenticação encontrada. Carregando mapas desbloqueados para o ID:", auth.localid)
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.get_doc(auth.localid)
		
		var finished_task: FirestoreTask = await task.task_finished
		var document = finished_task.document
		
		if document and document.doc_fields and document.doc_fields.has("unlocked_maps"):
			var unlocked_maps = document.doc_fields.unlocked_maps
			print("Mapas desbloqueados encontrados no Firebase:", unlocked_maps)
			apply_map_unlocks(unlocked_maps)
		else:
			print("Nenhuma informação de mapas desbloqueados encontrada. Somente o mapa 1 será desbloqueado.")
			apply_map_unlocks([])  # Nenhum mapa desbloqueado além do primeiro
	else:
		print("Erro: autenticação Firebase não encontrada.")
		apply_map_unlocks([])

func apply_map_unlocks(unlocked_maps: Array):
	for map_key in map_buttons:
		var button = map_buttons[map_key]
		if map_key == "map1" or map_key in unlocked_maps:
			print(map_key, "foi desbloqueado.")
		else:
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5)  # Cor esmaecida
			print(map_key, "está bloqueado.")

func _on_Map1_pressed():
	select_map("map1")

func _on_Map2_pressed():
	select_map("map2")

func _on_Map3_pressed():
	select_map("map3")

func _on_Map4_pressed():
	select_map("map4")

func select_map(map_name: String):
	if map_buttons[map_name].disabled:
		text_label.text = "Mapa bloqueado!"
		print("Tentativa de seleção de mapa bloqueado:", map_name)
	else:
		text_label.text = "Mapa selecionado: " + map_name
		print("Mapa selecionado com sucesso:", map_name)
