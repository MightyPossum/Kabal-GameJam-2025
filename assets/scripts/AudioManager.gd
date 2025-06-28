extends Node

signal music_track_changed(track_name : String)
signal sound_played(sound_name : String)
signal volume_changed (bus: String, value : float)

const CONFIG_PATH := "user://audio_settings.cfg"

var _current_music: AudioStreamPlayer


func play_sound(sound : AudioStream, volume_db : float = 0.0) -> void:
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound
	player.volume_db = volume_db
	player.play()
	player.finished.connect(player.queue_free)
	sound_played.emit(sound.resource_path.get_file())
	
func stop_music() -> void:
	if _current_music:
		_current_music.stop()
		_current_music.queue_free()
		
func set_bus_volume(bus_name: String, percent: float) -> void:
	var bus_index = AudioServer.get_bus_index(bus_name)
	var linear_volume = db_to_linear(lerp(-30, 0, percent))
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))
	volume_changed.emit(bus_name, percent)
	
func save_settings() -> void:
	var config := ConfigFile.new()
	for bus in ["Master", "SFX", "Music"]:
		var vol = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))
		config.set_value("Audio", bus, vol)
	config.save(CONFIG_PATH)
	
func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		for bus in ["Master", "SFX", "Music"]:
			var vol = config.get_value("Audio", bus, 0.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus),vol)
			
func _on_music_finished() -> void:
	_current_music.play()
