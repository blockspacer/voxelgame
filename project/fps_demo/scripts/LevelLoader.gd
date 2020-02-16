extends Node

var path_current : String = ""
var error : int = OK
var loader : ResourceInteractiveLoader = null
var thread : Thread = Thread.new()
var new_scene : Resource = null
var progress : float = 0.0
var loading_screen_resource : PackedScene = preload("res://fps_demo/scenes/ui/FadeInRect.tscn")
var loading_screen : Node = null

signal loading_progress

func reset() -> void:
	path_current = ""
	error = OK
	loader = null
	new_scene = null
	progress = 0.0

func start_loading(var path_in: String) -> void:
	reset()
	#Switch to the LoadingScreen before starting the Thread that loads the new level.
	loading_screen = loading_screen_resource.instance()
	call_deferred("change_current_scene", loading_screen)
	path_current = path_in
	if not thread.is_active():
		var err = thread.start(self, "thread_start_loading", path_current)
		DebUtil.debCheck(!err, "logic error")

func change_current_scene(var scene) -> void:
	get_tree().get_root().add_child(scene)
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	get_tree().current_scene = scene

func thread_start_loading(path_in : String) -> int:
	loader = ResourceLoader.load_interactive(path_in)
	if loader == null:
		call_deferred('background_loading_done')
		return ERR_CANT_ACQUIRE_RESOURCE
	return thread_loading()
	
func thread_loading() -> int:
	while true:
		if check_loading():
			call_deferred('background_loading_done')
			return error
	return 1

func background_loading_done() -> void:
	var result : bool = thread.wait_to_finish()
	loading_screen.queue_free()
	loading_done(result)

func loading_done(_result) -> void:
	# TODO: check _result
	var result_instance = new_scene.instance()
	call_deferred("change_current_scene", result_instance)

func check_loading() -> bool:
	error = loader.poll()
	if error == ERR_FILE_EOF or error == OK:
		progress = loader.get_stage() / max(1.0, (loader.get_stage_count() - 1)) * 100.0
		emit_signal("loading_progress", progress)
		if error == ERR_FILE_EOF:
			new_scene = loader.get_resource()
			return true
	else:
		return true
	return false
