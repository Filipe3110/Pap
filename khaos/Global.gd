extends Node

var COLLECTION_ID = "khaos_stats"
var music_volume: float = 1.0  
var sfx_volume: float = 1.0
var personagem_jogador1 
var personagem_jogador2 

var mapas_desbloqueados = {
	"mapa_1": true,
	"mapa_2": false,
	"mapa_3": false,
	"mapa_4": false
}

func desbloquear_proximo_mapa():
	if !mapas_desbloqueados["mapa_2"]:
		mapas_desbloqueados["mapa_2"] = true
	elif !mapas_desbloqueados["mapa_3"]:
		mapas_desbloqueados["mapa_3"] = true
	elif !mapas_desbloqueados["mapa_4"]:
		mapas_desbloqueados["mapa_4"] = true
	
	# Salvar no Firebase
	save_to_firebase()

func save_to_firebase():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var novos_dados = {
			"mapas_desbloqueados": mapas_desbloqueados
		}
		var update_task: FirestoreTask = collection.update(auth.localid, novos_dados)
		await update_task.task_finished
