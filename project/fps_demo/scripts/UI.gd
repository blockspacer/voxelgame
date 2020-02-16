extends Control

signal mouse_captured
signal mouse_visible

func _ready():
	if true: # scope
		var err = get_tree().get_root().connect("size_changed", self, "_on_size_changed")
		DebUtil.debCheck(!err, "logic error")
		
func _on_size_changed():
	GlobalLogger.info(self, \
		"Resizied viewport to: " + str(get_viewport_rect().size))
	#
	GlobalLogger.info(self, \
		"Resizied window_size to: " + str(OS.window_size))

func _on_World_mouse_captured():
	emit_signal("mouse_captured")

func _on_World_mouse_visible():
	emit_signal("mouse_visible")
