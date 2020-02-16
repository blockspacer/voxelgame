extends Spatial

signal mouse_captured
signal mouse_visible

func _init():
	VisualServer.set_debug_generate_wireframes(true)

func _ready():
	randomize()
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("mouse_captured")


func _physics_process(_delta):
	
	#### Update HUD
	$UI/VBox/FPS.text = "FPS: " + String(Engine.get_frames_per_second())	
	$UI/VBox/Position.text = "Position: " + String($Player.global_transform.origin)	


func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 4


	elif event is InputEventKey and Input.is_key_pressed(KEY_F):
		OS.window_fullscreen = ! OS.window_fullscreen


	elif event is InputEventKey and Input.is_key_pressed(KEY_TAB):
		#$UI.visible = !$UI.visible
		if $UI_Noise:
			$UI_Noise.visible = !$UI_Noise.visible


	elif event is InputEventKey and Input.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			emit_signal("mouse_captured")
		else:
			if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			emit_signal("mouse_visible")

