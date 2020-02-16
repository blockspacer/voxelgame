#
# NOTE:
# `GameGlobals` used to store global game variables (without filesystem storage)
# If you want to store changes, than use `settings`
#
# USAGE:
# 	GameGlobals.set_key_value(GameGlobals.GAME_GLOBALS..SOUND_VALUE, {
#		"volume": 50,
#		"asd": "fgdfd"
#	})
#
#   GameGlobals.get_key_value(GameGlobals.GAME_GLOBALS..SOUND_VALUE)
#
extends Node

signal game_globals_changed(previous, new)

# NOTE: used to profile only current source code file
var _is_debug_mode = null

enum GAME_GLOBALS {
	GAME_WINDOW_TITLE,
	USER_HOME_DIR,
	USER_DATA_DIR,
	GAME_DIR_NAME,
	GAME_DIR_PATH,
	GAME_SETTINGS_DIR_PATH,
	GAME_SETTINGS_FILE_PATH,
	GAME_VERSION
}

var _game_globals_values = {}

var _console = null

func set_console(console):
	_console = console

func console():
	return _console

func get_key_name(key:int):
	return GAME_GLOBALS.keys()[key] as String
	
func valid_key(key:int):
	return key >= 0 and key < GAME_GLOBALS.keys().size()

func set_defaults():
	set_key_value(GAME_GLOBALS.GAME_WINDOW_TITLE, 
		"Nova Matter"
	)
	#
	set_key_value(GAME_GLOBALS.USER_HOME_DIR, 
		"user://"
	)
	#
	set_key_value(GAME_GLOBALS.USER_DATA_DIR, 
		OS.get_user_data_dir() + "/"
	)
	#
	set_key_value(GAME_GLOBALS.GAME_DIR_NAME, 
		"nova_matter"
	)
	#
	set_key_value(GAME_GLOBALS.GAME_DIR_PATH, 
		get_key_value(GAME_GLOBALS.USER_DATA_DIR) + get_key_value(GAME_GLOBALS.GAME_DIR_NAME) + "/"
	)
	#
	set_key_value(GAME_GLOBALS.GAME_SETTINGS_DIR_PATH, 
		get_key_value(GAME_GLOBALS.GAME_DIR_PATH)
	)
	#
	set_key_value(GAME_GLOBALS.GAME_SETTINGS_FILE_PATH, 
		get_key_value(GAME_GLOBALS.GAME_SETTINGS_DIR_PATH) + "settings.ini"
	)
	#
	var version = "1.0.0"
	if OS.is_debug_build():
		version += "d"
	set_key_value(GAME_GLOBALS.GAME_VERSION, 
		version
	)

# Called when the object is initialized.
func _init() -> void:
	if _is_debug_mode == null:
		_is_debug_mode = OS.is_debug_build()
		GlobalLogger.info(self, "game globals initialized")
	#
	if true: # scope
		var err = connect("game_globals_changed", self, "_on_game_globals_changed")
		DebUtil.debCheck(!err, "logic error")
	#
	set_defaults()

func _ready():
	GlobalLogger.info(self, "game globals ready")
	#
	if not _is_debug_mode:
		return
	#
	var Console = preload("res://fps_demo/scenes/bullet.tscn").instance()
	#load("res://fps_demo/tools/Console/Console.tscn").instance()
	var current_root = get_tree().get_root()
	#var current_root = get_tree().get_current_scene()
	DebUtil.debCheck(Console != null, "logic error")
	DebUtil.debCheck(current_root != null, "logic error")
	Helpers.call_deferred("reparent", Console, current_root)

func get_key_value(key:int):
	DebUtil.debCheck(valid_key(key), "logic error")
	if not _game_globals_values.has(key):
		return null
	return _game_globals_values[key]
		
func set_key_value(key:int, value) -> void:
	DebUtil.debCheck(valid_key(key), "logic error")
	var previous = get_key_value(key)
	_game_globals_values[key] = value
	emit_signal("game_globals_changed", key, previous, value)
	
func _on_game_globals_changed(key:int, previous, new):
	DebUtil.debCheck(valid_key(key), "logic error")
	if _is_debug_mode:
		GlobalLogger.info(self, "game_globals_changed " \
			+ get_key_name(key) \
			+ " from " \
			+ str(previous) \
			+ " to " \
			+ str(new))
