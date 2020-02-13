extends "WorldCommon.gd"

onready var terrain = $VoxelTerrain

const MATERIAL = preload("res://fps_demo/materials/grass-rock2.material")

export (NodePath) var UI_Noise # Directional light for the sun

func _ready():
	UI_Noise = get_node(UI_Noise)
	update_noise_ui()
	
func _input(event):
	if event is InputEventKey and OS.is_debug_build() and Input.is_key_pressed(KEY_N):
		randomize_terrain()
	

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

static func _format_memory(m):
	var mb = m / 1000000
	var mbr = m % 1000000
	return str(mb, ".", mbr, " Mb")

func _process(_delta):
	var dm = OS.get_dynamic_memory_usage()
	var sm = OS.get_static_memory_usage()
	UI_Noise.get_child(5).text = "Dynamic memory: " + _format_memory(dm)
	UI_Noise.get_child(6).text = "Static memory: " + _format_memory(sm)
	
func update_noise_ui():
	UI_Noise.get_child(0).text = "Seed: " + String(terrain.stream.noise.seed)
	UI_Noise.get_child(1).text = "Octaves: " + String(terrain.stream.noise.octaves)
	UI_Noise.get_child(2).text = "Period: " + String(terrain.stream.noise.period).substr(0,4)
	UI_Noise.get_child(3).text = "Persistence: " + String(terrain.stream.noise.persistence).substr(0,4)
	UI_Noise.get_child(4).text = "Lacunarity: " + String(terrain.stream.noise.lacunarity).substr(0,4)
