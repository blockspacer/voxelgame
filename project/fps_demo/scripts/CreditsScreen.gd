extends Control

#export(NodePath) var new_game_btn_path = null
export(NodePath) var all_btn_container_path = null

export(NodePath) var animated_scene_changer_path = null

#var _new_game_btn:Button = null
var _all_btn_container = null

var _animated_scene_changer = null

var tween:Tween = null

var _node_to_remove = null

export var bg_audio_stream = preload("res://fps_demo/assets/audio/music/Magntron_melody/335571__magntron__gamemusic.wav")

var credit_id:int = 0

export(Array, String) var credits_all = \
	[ \
	"Music by FoolBoyMedia\n" \
	+ "FoolBoyMedia.co.uk" \
	, 
	"Music by Matthew Pablo\n" \
	+ "matthewpablo.com" \
	,
	"Music by Alexander Skeppstedt\n AKA lasesrcheese\n" \
	+ "soundcloud.com/laserost" \
	,
	"Music by Telaron\n" \
	+ "opengameart.org/users/telaron" \
	,
	"Music by Jamius\n" \
	+ "freesound.org/people/Jamius/" \
	,
	"Music by Nbs Dark\n" \
	+ "freesound.org/people/Nbs%20Dark/" \
	,
	"Music by CS279\n" \
	+ "freesound.org/people/CS279/" \
	,
	"Music by LloydEvans09\n" \
	+ "freesound.org/people/LloydEvans09/" \
	,
	"Music by Magntron\n" \
	+ "freesound.org/people/Magntron/" \
	,
	"Music by tyops\n" \
	+ "freesound.org/people/tyops" \
	,
	"Music by Leszek_Szary\n" \
	+ "freesound.org/people/Leszek_Szary" \
	,
	"Music by J.Zazvurek\n" \
	+ "freesound.org/people/J.Zazvurek" \
	,
	"Music by jorickhoofd\n" \
	+ "freesound.org/people/jorickhoofd" \
	,
	"Music by LiamG_SFX\n" \
	+ "freesound.org/people/LiamG_SFX" \
	,
	"Music by SoundFlakes\n" \
	+ "freesound.org/people/SoundFlakes" \
	,
	"Music by Breviceps\n" \
	+ "freesound.org/people/Breviceps" \
	]

func show_centered_text(text, offset_from_center:Vector2):
	DebUtil.debCheck(_node_to_remove == null, "logic error")
	#
	var mc = MarginContainer.new()
	mc.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	mc.anchor_right = offset_from_center.x
	mc.anchor_bottom = offset_from_center.y
	mc.margin_left = offset_from_center.x
	mc.margin_top = offset_from_center.y
	mc.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER;
	mc.set_anchors_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_CENTER)
	#mc.set_margins_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_VCENTER_WIDE)
	mc.set_clip_contents(true)
	#
	var label = Label.new()
	label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	#$VBoxContainerCenter.
	var screen_size = get_viewport().size
	#label.set_size(screen_size)
	#label.set_global_position(get_size() / 2.0)
	label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	label.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER;
	label.set_anchors_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_VCENTER_WIDE)
	label.set_margins_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_VCENTER_WIDE)
	label.set_align(Label.ALIGN_CENTER)
	label.set_valign(Label.VALIGN_CENTER)
	var font = load("res://fps_demo/assets/fonts/arial_32_dynamicfont.tres")
	#font.size = 90
	label.add_font_override("font", font)
	label.add_color_override("font_color", Color(0.9,0.9,0.99))
	label.set_text(text)
	#
	mc.add_child(label)
	add_child(mc)
	#
	#if tween.is_active():
	#	if not tween.remove_all():
	#		DebUtil.debCheck(false, "logic error")
	#	#
	#	if not tween.stop_all():
	#		DebUtil.debCheck(false, "logic error")
	#
	#if tween.is_connected("tween_completed", self, "_on_tween_complete"): # scope
	#	if true: # scope
	#		var err = tween.disconnect("tween_completed", self, "_on_tween_complete")
	#		DebUtil.debCheck(!err, "logic error")
	#
	var tween_seconds = 2.5
	if not tween.interpolate_property(mc, "modulate:a", \
					0.1, 1.0, \
					tween_seconds, \
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
		DebUtil.debCheck(false, "logic error")
	#
	if not tween.start():
		DebUtil.debCheck(false, "logic error")
	#
	_node_to_remove = mc

func _on_tween_complete(_obj, _key):
	DebUtil.debCheck(_node_to_remove.get_parent() != null, "logic error")
	if _node_to_remove.get_parent() != null: 
		_node_to_remove.get_parent().remove_child(_node_to_remove)
	_node_to_remove.queue_free()
	_node_to_remove = null
	#show_centered_text(credits_all[credit_id], Vector2(0.0,0.0))
	#print("tween_color_complete : obj = ",_obj,", key = ", _key)
	credit_id += 1;
	if credit_id >= credits_all.size():
		credit_id = 0
	#
	#if tween.is_active():
		#if not tween.remove_all():
		#	DebUtil.debCheck(false, "logic error")
		#
		#if not tween.stop_all():
		#	DebUtil.debCheck(false, "logic error")
	#
	show_centered_text(credits_all[credit_id], Vector2(0.0,0.0))
	#print("_on_tween_complete")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey and Input.is_action_pressed("ui_cancel"):
		_on_Button_pressed("res://fps_demo/scenes/ui/title_screen.tscn")

func _ready():
	tween = Tween.new()
	if true: # scope
		var err = tween.connect("tween_completed", self, "_on_tween_complete")
		DebUtil.debCheck(!err, "logic error")
	add_child(tween)
	#
	#_new_game_btn = get_node(new_game_btn_path)
	_all_btn_container = get_node(all_btn_container_path)
	#
	_animated_scene_changer = get_node(animated_scene_changer_path)
	#
	if (AudioManager.last_track_title() != "credits_screen_music"):
		AudioManager.stop_all()
		AudioManager.fade("credits_screen_music", bg_audio_stream, 0.1, 0.1)
		AudioManager._get_free_track(bg_audio_stream).player.connect("finished", self, "_onAudioFinished")
	#
	for button in _all_btn_container.get_children():
		if true: # scope
			if "scene_to_load" in button:
				DebUtil.debCheck(!_animated_scene_changer.is_loading(), "logic error")
				var err = button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
				DebUtil.debCheck(!err, "logic error")
	#
	show_centered_text(credits_all[credit_id], Vector2(0.0,0.0))
				
func _onAudioFinished():
	#AudioManager._get_free_track(bg_audio_stream).player.play()
	AudioManager.fade("credits_screen_music", bg_audio_stream, 0.1, 0.1)
		
func _on_Button_pressed(scene_to_load):
	
	if _animated_scene_changer.is_loading():
		# UI frozen
		return
	
	_animated_scene_changer.change_scene_to(scene_to_load)

func _on_UI_mouse_captured():
	hide()

func _on_UI_mouse_visible():
	show()
