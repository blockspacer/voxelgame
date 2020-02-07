extends InventoryItemBase

export(NodePath) var _item_bg_path = null

export(NodePath) var _item_texture_path = null

export(NodePath) var _item_durability_path = null

# Called when the node enters the scene tree for the first time.
func _ready():
	prepare(_item_bg_path, _item_texture_path, _item_durability_path)
