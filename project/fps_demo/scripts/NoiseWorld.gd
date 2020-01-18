extends "WorldCommon.gd"

onready var terrain = $VoxelTerrain

#onready var skyTex = $WorldEnvironment/Sky_texture
onready var skyTex = $Sky_texture
onready var skySlider = $UI/Time_Of_Day
#onready var directionalLight = $WorldEnvironment/DirectionalLight
onready var directionalLight = $DirectionalLight

const MATERIAL = preload("res://fps_demo/materials/grass-rock2.material")

var base_night_sky_rotation = Basis(Vector3(1.0, 1.0, 1.0).normalized(), 1.2)
var horizontal_angle = 25.0

var time_of_day = 48000.0 # 0 -> 86400
var day_phase = 0.0 # -PI -> PI
var game_timescale = 1160.0 # 1.0 = realtime

func _set_sky_rotation():
	var rot = Basis(Vector3(0.0, 1.0, 0.0), deg2rad(horizontal_angle)) * Basis(Vector3(1.0, 0.0, 0.0), skySlider.value * PI / 12.0)
	rot = rot * base_night_sky_rotation;
	skyTex.set_rotate_night_sky(rot)

func _ready():
	update_noise_ui()
	# init our time of day 
	#skyTex.set_time_of_day(skySlider.value, directionalLight, deg2rad(horizontal_angle))
	
	# rotate our night sky so our milkyway isn't on our horizon
	#_set_sky_rotation()

func _on_Sky_texture_sky_updated():
	#skyTex.copy_to_environment($Player/CamNode.get_viewport().get_camera().environment)
	#skyTex.copy_to_environment($Player/CamNode/Camera.get_viewport().get_camera().environment)
	skyTex.copy_to_environment(get_viewport().get_camera().environment)
	#print('_on_Sky_texture_sky_updated')

func _on_Time_Of_Day_value_changed(value):
	skyTex.set_time_of_day(value, get_node("DirectionalLight"), deg2rad(horizontal_angle))
	_set_sky_rotation()
	#print('_on_Time_Of_Day_value_changed')
	
func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_N):
		randomize_terrain()
		
func upd_time_of_day(delta):
	time_of_day += delta * game_timescale
	
	day_phase = time_of_day / (86400.0 / (PI * 2.0))
		
	if(time_of_day > 86400.0):
		time_of_day -= 86400.0
	if(time_of_day < 0.0):
		time_of_day += 86400.0
		
func upd_sun():
	if(time_of_day > 10500 && time_of_day < 54000):
		# Am
		skySlider.set_value(time_of_day/60/60/10);
		#_on_Time_Of_Day_value_changed(16400/60/60/10);
	else:
		# Pm
		#_on_Time_Of_Day_value_changed(16400/60/60/10);
		skySlider.set_value(time_of_day/60/60/10);
		
func _process(delta):
	upd_time_of_day(delta)
	upd_sun()

func randomize_terrain():	
	get_tree().call_group("bullets", "free")
	terrain.free()
	terrain = VoxelLodTerrain.new()
	terrain.name = "VoxelTerrain"
	
	terrain.stream = VoxelStreamNoise.new()
	terrain.stream.noise = OpenSimplexNoise.new()
	terrain.stream.noise.seed = randi()								# Int (0): 		0 to 2147483647
	terrain.stream.noise.octaves = 1+randi()%5						# Int (3): 		1 - 6 
	terrain.stream.noise.period = rand_range(0.1, 256)				# Float (64): 	0.1 - 256.0 
	terrain.stream.noise.persistence = randf()						# Float (0.5): 	0.0 - 1.0
	terrain.stream.noise.lacunarity = rand_range(0.1, 4)			# Float (2): 	0.1 - 4.0
	update_noise_ui()
		
	terrain.lod_count = 8
	terrain.lod_split_scale = 3
	terrain.viewer_path = "/root/World/Player"
	terrain.set_material(MATERIAL)
	add_child(terrain)


func update_noise_ui():
	$UI_Noise/Seed.text = "Seed: " + String(terrain.stream.noise.seed)
	$UI_Noise/Octaves.text = "Octaves: " + String(terrain.stream.noise.octaves)
	$UI_Noise/Period.text = "Period: " + String(terrain.stream.noise.period).substr(0,4)
	$UI_Noise/Persistence.text = "Persistence: " + String(terrain.stream.noise.persistence).substr(0,4)
	$UI_Noise/Lacunarity.text = "Lacunarity: " + String(terrain.stream.noise.lacunarity).substr(0,4)
