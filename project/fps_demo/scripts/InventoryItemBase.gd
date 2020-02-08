extends Node

var _item_bg:ColorRect = null

var _item_texture:TextureRect = null

var _item_durability:VBoxContainer = null

# Called when the node enters the scene tree for the first time.
func prepare(item_bg_path, item_texture_path, item_durability_path):
	_item_bg = get_node(item_bg_path) as ColorRect
	_item_texture = get_node(item_texture_path) as TextureRect
	_item_durability = get_node(item_durability_path) as VBoxContainer

func set_texture(texture:Texture):
	DebUtil.debCheck(texture != null, "logic error")

	if _item_texture == null:
		print('failed to set item texture')
		DebUtil.debCheck(false, "logic error")
		
	_item_texture.texture = texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
