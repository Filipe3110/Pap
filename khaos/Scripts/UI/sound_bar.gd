extends HSlider

var audio_bus_id
func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index("Music")
func _on_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
	Global.music_volume = value
