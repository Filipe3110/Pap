extends Node

var from_authentication := false
var COLLECTION_ID = "khaos_stats"
var music_volume: float = 1.0  
var sfx_volume: float = 1.0
var personagem_jogador1 
var personagem_jogador2 
var mapa_atual = "mapa_1"  # Adicione esta variável para rastrear o mapa atual

var mapas_desbloqueados = {
	"mapa_1": true,
	"mapa_2": false,
	"mapa_3": false,
	"mapa_4": false
}

# Função para desbloquear o próximo mapa baseado no mapa atual
func desbloquear_proximo_mapa():
	match mapa_atual:
		"mapa_1":
			if !mapas_desbloqueados["mapa_2"]:  # Só desbloqueia se ainda não estiver desbloqueado
				mapas_desbloqueados["mapa_2"] = true
				print("Desbloqueado mapa 2")
		"mapa_2":
			if !mapas_desbloqueados["mapa_3"]:
				mapas_desbloqueados["mapa_3"] = true
				print("Desbloqueado mapa 3")
		"mapa_3":
			if !mapas_desbloqueados["mapa_4"]:
				mapas_desbloqueados["mapa_4"] = true
				print("Desbloqueado mapa 4")
	
	# Garante que os mapas anteriores permaneçam desbloqueados
	if mapa_atual == "mapa_2":
		mapas_desbloqueados["mapa_1"] = true  # Mantém o mapa 1 desbloqueado
	elif mapa_atual == "mapa_3":
		mapas_desbloqueados["mapa_1"] = true  # Mantém o mapa 1 desbloqueado
		mapas_desbloqueados["mapa_2"] = true  # Mantém o mapa 2 desbloqueado
	
	print("Estado atual dos mapas: ", mapas_desbloqueados)
	save_to_firebase()  # Salva no Firebase

# Função para definir qual mapa está sendo jogado
func set_mapa_atual(mapa: String):
	mapa_atual = mapa

func save_to_firebase():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var novos_dados = {
			"mapas_desbloqueados": mapas_desbloqueados
		}
		var update_task: FirestoreTask = collection.update(auth.localid, novos_dados)
		await update_task.task_finished
