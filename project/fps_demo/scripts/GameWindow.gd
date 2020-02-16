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
	#if true: # scope
	#	var err = OS.set_thread_name(game_window_title + "_thread")
	#	DebUtil.debCheck(!err, "logic error")
	#
	if _is_debug_mode:
		GlobalLogger.info(self, \
			"game window title changed to " + game_window_title)
	
	Helpers.print_client_info()
