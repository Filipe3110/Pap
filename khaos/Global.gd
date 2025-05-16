extends Node
# Este script serve apenas como ponte para a função no modo história
func desbloquear_proximo_nivel():
	var modo_historia = get_tree().root.get_node("ModoHistoria")
	if modo_historia and modo_historia.has_method("desbloquear_nivel_atual"):
		modo_historia.desbloquear_nivel_atual()
