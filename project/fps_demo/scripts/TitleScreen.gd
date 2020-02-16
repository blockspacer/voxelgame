extends Control

#export(NodePath) var new_game_btn_path = null
export(NodePath) var all_btn_container_path = null

export(NodePath) var animated_scene_changer_path = null

#var _new_game_btn:Button = null
var _all_btn_container = null

var _animated_scene_changer = null

export var bg_audio_stream = preload("res://fps_demo/assets/audio/music/Loopable_cinematic_background/463542__tyops__ambient-documentary-cinematic-background.wav")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _ready():
	#_new_game_btn = get_node(new_game_btn_path)
	_all_btn_container = get_node(all_btn_container_path)
		
	_animated_scene_changer = get_node(animated_scene_changer_path)
		
	for button in _all_btn_container.get_children():
		if true: # scope
			if "scene_to_load" in button:
				DebUtil.debCheck(!_animated_scene_changer.is_loading(), "logic error")
				var err = button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
				DebUtil.debCheck(!err, "logic error")
	#
	if (AudioManager.last_track_title() != "title_screen_music"):
		AudioManager.stop_all()
		AudioManager.fade("title_screen_music", bg_audio_stream, 0.1, 0.1)
		AudioManager._get_free_track(bg_audio_stream).player.connect("finished", self, "_onAudioFinished")

func _onAudioFinished():
	#AudioManager._get_free_track(bg_audio_stream).player.play()
	AudioManager.fade("title_screen_music",bg_audio_stream, 0.1, 0.1)
	
func _on_Button_pressed(scene_to_load):
	if _animated_scene_changer.is_loading():
		# UI frozen
		return
	
	_animated_scene_changer.change_scene_to(scene_to_load)

func _on_UI_mouse_captured():
	hide()

func _on_UI_mouse_visible():
	show()
