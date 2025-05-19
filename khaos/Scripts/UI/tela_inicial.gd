extends Control

var COLLECTION_ID = "khaos_stats"

@onready var Logout = $LogoutScrn

func _ready():
	Logout.visible = false
	load_player_data()
	
	
	

func load_player_data():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:  
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var task: FirestoreTask = collection.get_doc(auth.localid)
		
		var finished_task: FirestoreTask = await task.task_finished
		var document = finished_task.document
		
		if document and document.doc_fields:
			# Carrega o nome de usuário
			if document.doc_fields.has("username"): 
				$log.text = document.doc_fields.username 
			
			# Carrega as configurações de áudio (novo trecho adicionado)
			if document.doc_fields.has("controls"):
				var settings = document.doc_fields["controls"]
				if settings.has("music_volume"):
					var volume_value = float(settings["music_volume"])
					var db = linear_to_db(volume_value)
					var audio_bus_id = AudioServer.get_bus_index("Music")
					if audio_bus_id != -1:
						AudioServer.set_bus_volume_db(audio_bus_id, db)
				elif settings.has("sfx_volume"):
					var sfx_value = float(settings["sfx_volume"])
					var sfxdb = linear_to_db(sfx_value)
					var sfxaudio_bus_id = AudioServer.get_bus_index("Music")
					if sfxaudio_bus_id != -1:
						AudioServer.set_bus_volume_db(sfxaudio_bus_id, sfxdb)
		
				
func _on_modo_história_pressed():
	get_tree().change_scene_to_file("res://Cenas/Modo_História/Tela_dos_mapas.tscn")

func _on_multijogador_pressed():
	get_tree().change_scene_to_file("res://Cenas/Multijogador/multijogador.tscn")

func _on_opções_pressed():
	get_tree().change_scene_to_file("res://Cenas/UI/options.tscn")

func _on_sair_pressed():
	get_tree().quit()


func carregar_cena_com_loading(caminho_da_proxima_cena):
	var loading = load("res://Cenas/UI/loading_screen.tscn").instantiate()
	loading.next_scene = caminho_da_proxima_cena
	get_tree().root.add_child(loading)
	queue_free()


func _on_log_pressed() -> void:
	Logout.visible = true
	
func _on_no_2_pressed() -> void:
		Logout.visible = false


func _on_yes_2_pressed() -> void:
	Firebase.Auth.logout()
	get_tree().change_scene_to_file("res://Cenas/UI/Authentication.tscn")
