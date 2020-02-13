extends Control

#export(NodePath) var new_game_btn_path = null
export(NodePath) var all_btn_container_path = null

export(NodePath) var animated_scene_changer_path = null

#var _new_game_btn:Button = null
var _all_btn_container = null

var _animated_scene_changer = null

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
		
func _on_Button_pressed(scene_to_load):
	if _animated_scene_changer.is_loading():
		# UI frozen
		return
	
	_animated_scene_changer.change_scene_to(scene_to_load)

func _on_UI_mouse_captured():
	hide()

func _on_UI_mouse_visible():
	show()
