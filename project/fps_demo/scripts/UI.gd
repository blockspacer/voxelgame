extends Control

signal mouse_captured
signal mouse_visible

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")
	
func _on_size_changed():
	print("Resizied viewport to: ", get_viewport_rect().size)
	print("Resizied window_size to: ", OS.window_size)

func _on_World_mouse_captured():
	emit_signal("mouse_captured")

func _on_World_mouse_visible():
	emit_signal("mouse_visible")
