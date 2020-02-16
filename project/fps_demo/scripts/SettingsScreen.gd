extends Control

#export(NodePath) var new_game_btn_path = null
export(NodePath) var all_btn_container_path = null

export(NodePath) var animated_scene_changer_path = null

#var _new_game_btn:Button = null
var _all_btn_container = null

var _animated_scene_changer = null

var previous_width = null

var previous_height = null

func load_fullscreen():
	self.find_node("FullscreenCheckButton").pressed = OS.window_fullscreen

func load_resolution():
	if previous_width == null:
		previous_width = str(OS.window_size.x)
	#
	if previous_height == null:
		previous_height = str(OS.window_size.y)
	#
	var resolution_width = find_node("WidthLineEdit")
	var resolution_height = find_node("HeightLineEdit")
	resolution_width.text = str(OS.get_screen_size().x)
	resolution_height.text = str(OS.get_screen_size().y)

func load_vsync():
	self.find_node("VSyncCheckButton").pressed = OS.vsync_enabled 

func load_msaa():
	var msaa_setting = find_node("MsaaOptionButton")
	msaa_setting.selected = get_viewport().msaa
	
func load_current_settings():
	load_fullscreen()
	load_resolution()
	load_vsync()
	load_msaa()
	
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
				
	load_current_settings()

func _apply_fullscreen():
	var fullscreen = self.find_node("FullscreenCheckButton").pressed
	OS.window_fullscreen = fullscreen
	_on_Fullscreen_toggled(fullscreen)

func _apply_resolution():
	var width = self.find_node("WidthLineEdit").text
	width = int(width)
	
	var height = self.find_node("HeightLineEdit").text
	height = int(height)

	OS.window_size = Vector2(width, height)

func _apply_vsync():
	OS.vsync_enabled = self.find_node("VSyncCheckButton").pressed

func _apply_msaa():
	var msaa_setting = find_node("MsaaOptionButton")
	get_viewport().msaa = msaa_setting.selected
	pass
	
func _input(event):
	if event is InputEventKey and Input.is_action_pressed("ui_cancel"):
		# TODO: show confirmation dialog "do you want to save changes?"
		_on_Button_pressed("res://fps_demo/scenes/ui/title_screen.tscn")

func _on_Fullscreen_toggled(button_pressed):
	var resolution_width = find_node("WidthLineEdit")
	var resolution_height = find_node("HeightLineEdit")
	
	resolution_width.deselect()
	resolution_height.deselect()
	
	# Disable if fullscreen
	resolution_width.editable = !button_pressed
	resolution_height.editable = !button_pressed
	
	# Can't set resolution if fullscreen, so monitor's resolution is used
	if button_pressed:
		self.previous_width = resolution_width.text
		self.previous_height = resolution_height.text
		
		resolution_width.text = str(OS.get_screen_size().x)
		resolution_height.text = str(OS.get_screen_size().y)#
	else:
		resolution_width.text = self.previous_width
		resolution_height.text = self.previous_height
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
		
func _on_Button_pressed(scene_to_load):
	if _animated_scene_changer.is_loading():
		# UI frozen
		return
	
	_animated_scene_changer.change_scene_to(scene_to_load)

func _on_UI_mouse_captured():
	hide()

func _on_UI_mouse_visible():
	show()

func _on_GraphicsApplyBtn_pressed():
	self._apply_fullscreen()
	self._apply_resolution()
	self._apply_vsync()
	#self._apply_fps_counter() # TODO
	#self._apply_antistropic() # TODO
	self._apply_msaa()
