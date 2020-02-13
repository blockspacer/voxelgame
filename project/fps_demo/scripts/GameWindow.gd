extends Node

var game_window_title = GameGlobals.get_key_value(GameGlobals.GAME_GLOBALS.GAME_WINDOW_TITLE)

# NOTE: used to profile only current source code file
var _is_debug_mode = null
	
# Called when the object is initialized.
func _init() -> void:
	if _is_debug_mode == null:
		_is_debug_mode = OS.is_debug_build()
	#
	OS.set_window_title(game_window_title)
	#
	if _is_debug_mode:
		print("game window title changed to ", game_window_title)
