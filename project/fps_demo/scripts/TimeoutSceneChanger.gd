extends Control

export(float) var time_sec_to_wait = 1.0

export(String) var scene_to_load_path = null

export(NodePath) var animated_scene_changer_path = null

var _animated_scene_changer = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _ready():
	# NOTE: we can call queue_resource on same asset multiple times
	game_resource_queue.queue_resource(scene_to_load_path)
	#
	# NOTE: yield method pauses execution of code 
	yield(get_tree().create_timer(time_sec_to_wait), "timeout")
	#
	_animated_scene_changer = get_node(animated_scene_changer_path)
	_animated_scene_changer.change_scene_to(scene_to_load_path)
