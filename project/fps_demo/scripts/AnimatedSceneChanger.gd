extends Control

export(NodePath) var rect_fade_in_path = null

var _rect_fade_in:ColorRect = null

var _scene_path_to_load = null

export(float) var _min_scene_change_anim_time_sec = 0.5

var _time_waited = 0

var _scheduled_scene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_rect_fade_in = get_node(rect_fade_in_path)
	if true: # scope
		var err = _rect_fade_in.connect("fade_finished", self, "_on_FadeInRect_fade_finished")
		DebUtil.debCheck(!err, "logic error")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# https://github.com/search?q=%22change_scene_to%22+%22get_resource%22++language%3AGDScript&type=Code
	if _scene_path_to_load != null:
		DebUtil.debCheck(_rect_fade_in.visible, "logic error")
		var progress = game_resource_queue.get_progress(_scene_path_to_load)
		#print("loading ", _scene_path_to_load, " progress = ", progress)
		var scene = game_resource_queue.get_resource(_scene_path_to_load)
		var is_not_scheduled:bool = progress == -1
		if scene and is_not_scheduled:
			#print("loaded ", _scene_path_to_load, " progress = ", progress)
			_scheduled_scene = scene
	#
	# TODO: refactor to task queue with individual task delay
	if _scheduled_scene != null:
		_time_waited += delta
		if _time_waited > _min_scene_change_anim_time_sec:
			handle_scene_loaded(_scheduled_scene)
			_scheduled_scene = null
			_time_waited = 0
				
func handle_scene_loaded(scene):
	# TODO
	#get_tree().set_current_scene( scene.instance() )
	
	var err = get_tree().change_scene_to(scene)
	if (err != OK):
		GlobalLogger.info(self, \
			"Failure during change_scene!")
	
	DebUtil.debCheck(_rect_fade_in.visible, "logic error")
	_rect_fade_in.hide()
	#
	DebUtil.debCheck(_scene_path_to_load != null, "logic error")
	_scene_path_to_load = null
	
func _on_FadeInRect_fade_finished():
	GlobalLogger.info(self, \
		'_on_FadeInRect_fade_finished')
	
func is_loading():
	return _scene_path_to_load != null
	
func change_scene_to(scene_to_load):
	DebUtil.debCheck(scene_to_load != null, "logic error")
	#
	if _scene_path_to_load != null:
		GlobalLogger.info(self, \
			'already scheduled scene loading, skipping' + scene_to_load)
		return
	#
	GlobalLogger.info(self, \
		'scheduled scene loading ' + scene_to_load)
	DebUtil.debCheck(!_rect_fade_in.visible, "logic error")
	_rect_fade_in.show()
	_rect_fade_in.fade_in()
	#
	if scene_to_load != null:
		 game_resource_queue.queue_resource(scene_to_load)
	#
	_scene_path_to_load = scene_to_load
