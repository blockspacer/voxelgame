extends Spatial

const MyStream = preload ("MyStream.gd")

const MATERIAL = preload("res://dmc_terrain/dmc_terrain_material.tres")
const HEIGHT_MAP = preload("res://blocky_terrain/noise_distorted.png")

var terrain = VoxelTerrain.new()

func _ready():
	terrain.stream = MyStream.new()
	#terrain.stream = VoxelStreamTest.new()
	#terrain.stream = VoxelStreamImage.new() 	
	#terrain.stream.image = HEIGHT_MAP
		
	terrain.voxel_library = VoxelLibrary.new()
	
	terrain.view_distance = 256	
	terrain.viewer_path = "/root/Spatial/Player"
	#terrain.set_material(0, MATERIAL)
	add_child(terrain)
	
