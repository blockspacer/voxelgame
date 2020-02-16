extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	LevelLoader.start_loading("res://fps_demo/noise_smooth_lod.tscn")
