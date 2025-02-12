# LevelManager.gd (Adicione aos autoloads do projeto)
extends Node

const FIREBASE_URL = "https://khaosdb-35541-default-rtdb.europe-west1.firebasedatabase.app/"
const API_KEY = "AIzaSyCHhH_c-pF2dyKA95nxv-BnqPu_Fmoz3kY"

var http_request: HTTPRequest
var player_progress = {
	"mapa1": {"unlocked": true, "completed": false},
	"mapa2": {"unlocked": false, "completed": false},
	"mapa3": {"unlocked": false, "completed": false},
	"mapa4": {"unlocked": false, "completed": false}
}

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	load_progress()

func load_progress():
	var url = "%s/players/progress.json?auth=%s" % [FIREBASE_URL, API_KEY]
	http_request.request(url, [], HTTPClient.METHOD_GET)

func save_progress():
	var url = "%s/players/progress.json?auth=%s" % [FIREBASE_URL, API_KEY]
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(player_progress)
	http_request.request(url, headers, HTTPClient.METHOD_PUT, body)

func _on_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json:
			player_progress = json
			emit_signal("progress_loaded")

func complete_level(level_name: String):
	if level_name in player_progress:
		player_progress[level_name]["completed"] = true
		# Desbloqueia o próximo nível
		var next_level = get_next_level(level_name)
		if next_level in player_progress:
			player_progress[next_level]["unlocked"] = true
		save_progress()

func get_next_level(current_level: String) -> String:
	match current_level:
		"mapa1": return "mapa2"
		"mapa2": return "mapa3"
		"mapa3": return "mapa4"
		_: return ""

func is_level_unlocked(level_name: String) -> bool:
	return player_progress[level_name]["unlocked"]

# LevelSelectScreen.gd (Anexe à sua cena de seleção de níveis)
extends Control

@onready var mapa1_button = $Fundo/Mapa1Sprite/botoon
@onready var mapa2_button = $Fundo/Mapa2Sprite/botoon
@onready var mapa3_button = $Fundo/Mapa3Sprite/botoon
@onready var mapa4_button = $Fundo/Mapa4Sprite/botoon

func _ready():
	update_buttons_state()
	# Conecta os botões aos seus respectivos handlers
	mapa1_button.connect("pressed", _on_mapa_1_pressed)
	mapa2_button.connect("pressed", _on_mapa_2_pressed)
	mapa3_button.connect("pressed", _on_mapa_3_pressed)
	mapa4_button.connect("pressed", _on_mapa_4_pressed)

func update_buttons_state():
	mapa1_button.disabled = !LevelManager.is_level_unlocked("mapa1")
	mapa2_button.disabled = !LevelManager.is_level_unlocked("mapa2")
	mapa3_button.disabled = !LevelManager.is_level_unlocked("mapa3")
	mapa4_button.disabled = !LevelManager.is_level_unlocked("mapa4")

func _on_mapa_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/mapa_montanhanheve.tscn")

func _on_mapa_2_pressed() -> void:
	if LevelManager.is_level_unlocked("mapa2"):
		get_tree().change_scene_to_file("res://Cenas/mapa_2.tscn")

func _on_mapa_3_pressed() -> void:
	if LevelManager.is_level_unlocked("mapa3"):
		get_tree().change_scene_to_file("res://Cenas/mapa_3.tscn")

func _on_mapa_4_pressed() -> void:
	if LevelManager.is_level_unlocked("mapa4"):
		get_tree().change_scene_to_file("res://Cenas/mapa_4.tscn")

# GameLevel.gd (Adicione este script em cada cena de nível)
extends Node2D  # ou Node3D, dependendo do seu caso

@export var level_name: String = "mapa1"  # Configure isto no inspetor para cada nível

func _ready():
	# Adicione isto onde for apropriado no seu código
	# Por exemplo, quando o jogador completa o nível
	pass

func complete_level():
	LevelManager.complete_level(level_name)
	# Adicione aqui sua lógica para quando o nível é completado
	# Por exemplo, mostrar uma tela de vitória, etc.
