extends Spatial

const MyStream = preload ("MyStream.gd")

const MATERIAL = preload("res://fps_demo/materials/grass-rock2.material")
const HEIGHT_MAP = preload("res://blocky_terrain/noise_distorted.png")

#onready var terrain = get_node("VoxelTerrain") 
var terrain:VoxelTerrain

func _ready():
	create_terrain()
	
func _input(event):
	
	if event is InputEventKey and Input.is_key_pressed(KEY_DELETE):
		terrain.free()
		
	if event is InputEventKey and Input.is_key_pressed(KEY_N):
		create_terrain()		

	
func create_terrain():
	terrain = VoxelTerrain.new()
	terrain.stream = MyStream.new()
	#terrain.stream = VoxelStreamTest.new()
	#terrain.stream = VoxelStreamImage.new()
	#terrain.stream.image = HEIGHT_MAP
		
	terrain.voxel_library = VoxelLibrary.new()
	#terrain.lod_count = 8
	#terrain.lod_split_scale = 3
	terrain.view_distance = 256	
	terrain.viewer_path = "/root/Spatial/Player"
	#terrain.set_material(MATERIAL)
	terrain.set("material/0", MATERIAL)
	add_child(terrain)
	
