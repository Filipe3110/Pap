extends Control

var COLLECTION_ID = "khaos_stats"

const COLECAO_ID = "khaos_stats"

# Referências aos nós da cena
@onready var btn_mapa1 = $"1/Mapa1"
@onready var btn_mapa2 = $"2/Mapa2"
@onready var btn_mapa3 = $"3/Mapa3"
@onready var btn_mapa4 = $"4/Mapa4"
@onready var lbl_status = $text
@onready var unlocked2 = $"2/Mapas unlocked"
@onready var unlocked3 = $"3/Mapas unlocked"
@onready var unlocked4 = $"4/Mapas unlocked"

# Estado inicial dos mapas (valores padrão)
var mapas_desbloqueados = {
	"mapa_1": true,   # Mapa 1 sempre liberado por padrão
	"mapa_2": false,
	"mapa_3": false,
	"mapa_4": false
}

# Caminhos das cenas
const CENAS_MAPAS = {
	"mapa_1": "res://Mapas/mapa_espço.tscn",
	"mapa_2": "res://Mapas/mapa_montanhanheve.tscn", 
	"mapa_3": "res://Mapas/mapa_barco.tscn",
	"mapa_4": "res://Mapas/mapa_montanhanheve.tscn"
}

func _ready():
	load_player_data()
	update_unlocked_visibility()

func load_player_data():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:  
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.get_doc(auth.localid)
		
		var finished_task: FirestoreTask = await task.task_finished
		var document = finished_task.document
		
		if document and document.doc_fields:
			if document.doc_fields.has("mapas_desbloqueados"):
				for mapa in document.doc_fields.mapas_desbloqueados:
					if mapas_desbloqueados.has(mapa):
						mapas_desbloqueados[mapa] = document.doc_fields.mapas_desbloqueados[mapa]
			else:
				var novos_dados = {
					"mapas_desbloqueados": {
						"mapa_1": true,   
						"mapa_2": false,
						"mapa_3": false,
						"mapa_4": false
					}
				}
				var update_task: FirestoreTask = collection.update(auth.localid, novos_dados)
				await update_task.task_finished
		else:
			var initial_data = {
				"mapas_desbloqueados": mapas_desbloqueados
			}
			var create_task: FirestoreTask = collection.set_doc(auth.localid, initial_data)
			await create_task.task_finished
		
		update_unlocked_visibility()
	else:
		update_unlocked_visibility()

func update_unlocked_visibility():
	unlocked2.visible = !mapas_desbloqueados["mapa_2"]
	unlocked3.visible = !mapas_desbloqueados["mapa_3"]
	unlocked4.visible = !mapas_desbloqueados["mapa_4"]

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")

func _on_mapa_1_pressed():
	tentar_carregar_mapa("mapa_1")

func _on_mapa_2_pressed():
	tentar_carregar_mapa("mapa_2")

func _on_mapa_3_pressed():
	tentar_carregar_mapa("mapa_3")

func _on_mapa_4_pressed():
	tentar_carregar_mapa("mapa_4")

func tentar_carregar_mapa(id_mapa):
	if mapas_desbloqueados[id_mapa]:
		carregar_cena_com_loading(CENAS_MAPAS[id_mapa])
	else:
		var numero_mapa = id_mapa.split("_")[1]
		lbl_status.text = "Mapa %s bloqueado!" % numero_mapa
		var tween = create_tween()
		tween.tween_property(lbl_status, "modulate", Color(1, 0, 0), 0.2)
		tween.tween_property(lbl_status, "modulate", Color(1, 1, 1), 0.2)

func carregar_cena_com_loading(cena):
	var tela_loading = load("res://Cenas/UI/loading_screen.tscn").instantiate()
	tela_loading.next_scene = cena
	get_tree().root.add_child(tela_loading)
	queue_free()

func _on_mapa_1_mouse_entered() -> void:
	$"1".color = Color(0.7, 0.7, 0.7) 

func _on_mapa_1_mouse_exited() -> void:
	$"1".color = Color(1, 1, 1)  

func _on_mapa_2_mouse_entered() -> void:
	$"2".color = Color(0.7, 0.7, 0.7)

func _on_mapa_2_mouse_exited() -> void:
	$"2".color = Color(1, 1, 1)

func _on_mapa_3_mouse_entered() -> void:
	$"3".color = Color(0.7, 0.7, 0.7)

func _on_mapa_3_mouse_exited() -> void:
	$"3".color = Color(1, 1, 1)

func _on_mapa_4_mouse_entered() -> void:
	$"4".color = Color(0.7, 0.7, 0.7)

func _on_mapa_4_mouse_exited() -> void:
	$"4".modulate = Color(1, 1, 1)
