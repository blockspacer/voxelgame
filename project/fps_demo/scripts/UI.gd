extends Control

signal mouse_captured
signal mouse_visible

func _on_World_mouse_captured():
	emit_signal("mouse_captured")

func _on_World_mouse_visible():
	emit_signal("mouse_visible")
