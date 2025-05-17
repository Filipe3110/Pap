extends Node

var mapas_desbloqueados = [true, false, false, false]

func desbloquear_um_nivel() -> int:
	for i in range(mapas_desbloqueados.size()):
		if not mapas_desbloqueados[i]:
			mapas_desbloqueados[i] = true
			print("Desbloqueado mapa:", i + 1)
			return i  # retorna o índice desbloqueado
	print("Todos os mapas já estão desbloqueados")
	return -1
