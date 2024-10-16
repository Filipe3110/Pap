extends Node

func _ready() -> void:
	# Ativa o modo de tela cheia ao iniciar
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _process(delta: float) -> void:
	pass
