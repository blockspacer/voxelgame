extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func check(condition, text):
	if not condition:
		var frame = get_stack()[1]
		var msg = "%30s:%30s:%-4d %s" % [frame.source.get_file(), frame.function, frame.line, text]
		push_error( msg )
		assert(condition, msg)
		
func debCheck(condition, text):
	if OS.is_debug_build() and not condition:
		var frame = get_stack()[1]
		var msg = "%30s:%30s:%-4d %s" % [frame.source.get_file(), frame.function, frame.line, text]
		push_error( msg )
		assert(condition, msg)

