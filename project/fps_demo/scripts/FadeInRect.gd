extends ColorRect

signal fade_finished

export(NodePath) var anim_player_path = null

var _anim_player:AnimationPlayer = null

func _ready():
	_anim_player = get_node(anim_player_path)
	if true: # scope
		var err = _anim_player.connect("animation_finished", self, "_on_FadeInAnimation_animation_finished")
		DebUtil.debCheck(!err, "logic error")
	hide()
	
func fade_in():
	#show()
	var anim_name = "fade_in";
	#print('animation started: ', anim_name)
	_anim_player.play(anim_name)

func _on_FadeInAnimation_animation_finished(_anim_name):
	#print('animation finished: ', anim_name)
	emit_signal("fade_finished")
	#hide()
