extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse = get_global_mouse_position();
	var screen = get_viewport().size
	mouse.x = -mouse.x
	#mouse.x /= screen.x
	#mouse.y /= screen.y
	get_material().set_shader_param("mouse_position", mouse)
	#get_material().set_shader_param("u_time", OS.get)
