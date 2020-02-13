#
# Saves settings in human readable format, 
# so end user will be able to modify settings file in any text editor
#
# NOTE: most errors during settings file loading treat as not fatal,
# so game will be able to play and fallback to defaults
#
extends Node

var settings = {}

var default_settings = {}

var settings_dir = GameGlobals.get_key_value(GameGlobals.GAME_GLOBALS.GAME_SETTINGS_DIR_PATH)

var settings_path = GameGlobals.get_key_value(GameGlobals.GAME_GLOBALS.GAME_SETTINGS_FILE_PATH)

# NOTE: used to profile only current source code file
var _is_debug_mode = null

func set_defaults():
	print("Trying to set default settings")
	default_settings["audio"] = {
		"music_percent": 100,
		"sound_effects_percent": 50,
		"voice_percent":50,
		"server_ip":"127.0.0.1"
	}
	
# Called when the object is initialized.
func _init() -> void:
	print("Trying to init settings")
	if _is_debug_mode == null:
		_is_debug_mode = OS.is_debug_build()
		print("game settings initialized")
	#
	set_defaults()
	reset_settings_to_defaults()
	load_settings_file()
	save_settings_file()

func load_settings_file():
	if _is_debug_mode:
		print("Trying to load client settings file:  ", settings_path)
	#
	var directory := Directory.new()
	prepare_settings_dirs(directory)
	#
	if directory.dir_exists(settings_path):
		print("WARNING: ", settings_path, " must be file, not dir")
		return
	#
	var file = ConfigFile.new()
	if true: # scope
		var err = file.load(settings_path)
		if err != OK:
			print("WARNING: failed file.load for ", settings_path)
			return
	#	
	for section in file.get_sections():
		if(!settings.has(section)):
			settings[section] = {}
		for key in file.get_section_keys(section):
			settings[section][key] = file.get_value(section, key)

func prepare_settings_dirs(directory:Directory):
	if not directory.dir_exists(settings_dir):
		var err = directory.make_dir_recursive(settings_dir)
		if err != OK:
			print("WARNING: failed make_dir_recursive for ", settings_dir)
			return

func save_settings_file():
	if _is_debug_mode:
		print("Trying to save client settings file:  ", settings_path)
	#
	var directory := Directory.new()
	prepare_settings_dirs(directory)
	#
	if directory.dir_exists(settings_path):
		print("WARNING: ", settings_path, " must be file, not dir")
		return
	#
	var file = ConfigFile.new()
	#
	for section in settings:
		for key in settings[section]:
			file.set_value(section, key, settings[section][key])
	#
	if true: # scope
		var err = file.save(settings_path)
		if err != OK:
			print("WARNING: failed file.save for ", settings_path)
			return

func reset_settings_to_defaults():
	print("Trying to reset settings to defaults")
	settings = {}
	for section in default_settings:
		settings[section] = {}
		for key in default_settings[section]:
			settings[section][key] = default_settings[section][key]

func get_setting(section, key):
	if(settings.has(section) and settings[section].has(key)):
		return settings[section][key]
	else:
		return null

func set_setting(section, key, value):
	print("Trying to set setting", key)
	if(!settings.has(section)):
		settings[section] = {}
	settings[section][key] = value
