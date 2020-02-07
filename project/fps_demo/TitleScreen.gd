extends Control

var scene_path_to_load

export(NodePath) var new_game_btn_path = null
export(NodePath) var all_btn_container_path = null
export(NodePath) var rect_fade_in_path = null

var _new_game_btn:Button = null
var _all_btn_container = null
var _rect_fade_in:ColorRect = null

func _ready():
	_new_game_btn = get_node(new_game_btn_path)
	_all_btn_container = get_node(all_btn_container_path)
	_rect_fade_in = get_node(rect_fade_in_path)
	if true: # scope
		var err = _rect_fade_in.connect("fade_finished", self, "_on_FadeInRect_fade_finished")
		DebUtil.debCheck(!err, "logic error")
		
	for button in _all_btn_container.get_children():
		if true: # scope
			var err = button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
			DebUtil.debCheck(!err, "logic error")

func _on_Button_pressed(scene_to_load):
	_rect_fade_in.show()
	_rect_fade_in.fade_in()
	scene_path_to_load = scene_to_load
	print('scheduled scene loading ', scene_path_to_load)


func _on_FadeInRect_fade_finished():
	print('_on_FadeInRect_fade_finished')
	_rect_fade_in.hide()
	var err = get_tree().change_scene(scene_path_to_load)
	if (err != OK):
		print("Failure during change_scene!")

func _on_UI_mouse_captured():
	hide()

func _on_UI_mouse_visible():
	show()
