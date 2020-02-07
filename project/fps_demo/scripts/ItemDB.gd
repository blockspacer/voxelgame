extends Node
 
const ICON_PATH = "res://fps_demo/textures/icons/"

enum ITEM_ID {sword, breastplate, potato, error}

const ITEMS = {
	ITEM_ID.sword: {
		"icon": ICON_PATH + "cross_white_unique.png",
		"allowed_slot_category": "MAIN_HAND"
	},
	ITEM_ID.breastplate: {
		"icon": ICON_PATH + "drop-of-liquid_white_unique.png",
		"allowed_slot_category": "CHEST"
	},
	ITEM_ID.potato: {
		"icon": ICON_PATH + "food_white_unique.png",
		"allowed_slot_category": "ALL"
	},
	ITEM_ID.error:{
		"icon": ICON_PATH + "found_error_white_unique.png",
		"allowed_slot_category": "ALL"
	}
}

func create_item(parent, item_base, item_id):
	var item:InventoryItemBase = item_base.instance() as InventoryItemBase
	parent.add_child(item) # must call _ready before everything else
	item.set_meta("item_id", item_id)
	#print("create_item for item_id = ", item.get_meta("item_id"))
	var item_icon = load(get_item(item_id)["icon"]) as Texture
	item.set_texture(item_icon)
	return item

func get_item(item_id):
	if item_id in ITEMS:
		return ITEMS[item_id]
	else:
		return ITEMS["error"]
