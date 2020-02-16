extends ColorRect

onready var spectrum = AudioServer.get_bus_effect_instance(0, 0)

var definition = 20
var total_w = 400
var total_h = 200
var min_freq = 20
var max_freq = 20000

var max_db = 0
var min_db = -40

var accel = 20
var histogram = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse = get_global_mouse_position();
	var screen = get_viewport().size
	#mouse.x /= screen.x
	#mouse.y /= screen.y
	get_material().set_shader_param("mouse_position", mouse)
	var mag = spectrum.get_magnitude_for_frequency_range(20.0, 20000.0)
	mag = linear2db(mag.length())
	mag = (mag - min_db) / (max_db - min_db)
	
	#mag += 0.3 * (freq - min_freq) / (max_freq - min_freq)
	mag = clamp(mag, 0.05, 1)
	get_material().set_shader_param("audio", mag)
	#get_material().set_shader_param("u_time", OS.get)
