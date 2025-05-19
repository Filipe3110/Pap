extends HSlider

var sfxaudio_bus_id
func _ready() -> void:
	sfxaudio_bus_id = AudioServer.get_bus_index("SFX")
func _on_value_changed(value: float) -> void:
	var sfxdb = linear_to_db(value)
	AudioServer.set_bus_volume_db(sfxaudio_bus_id, sfxdb)
	Global.sfx_volume = value
