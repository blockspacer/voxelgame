extends Node
 
const ICON_PATH = "res://fps_demo/textures/icons/"

enum ITEM_ID {sword, breastplate, potato, internal_error, internal_reference}

const ITEMS = {
	ITEM_ID.sword: {
		"icon": ICON_PATH + "cross_white_unique.png",
		"allowed_slot_category": "MAIN_HAND",
		"name": "cross_white_unique",
		"description": "asd asdsdfsd",
		"hit_damage": 10.1,
		"aid_hp": 2.1,
		"weight": 0.1,
		"stack_size": 1,
		"size_in_slots": [1,2,1]
	},
	ITEM_ID.breastplate: {
		"icon": ICON_PATH + "drop-of-liquid_white_unique.png",
		"allowed_slot_category": "CHEST",
		"name": "drop-of-liquid",
		"description": "sdfs dffdfd",
		"armor": 4.1,
		"weight": 10.1,
		"stack_size": 2,
		"size_in_slots": [1]
	},
	ITEM_ID.potato: {
		"icon": ICON_PATH + "food_white_unique.png",
		"allowed_slot_category": "TOOL",
		"name": "food_white_unique",
		"description": "123",
		"nutritional_value": 6.8,
		"weight": 2.1,
		"stack_size": 3,
		"size_in_slots": [2,2]
	},
	ITEM_ID.internal_error:{
		"icon": ICON_PATH + "found_error_white_unique.png",
		"allowed_slot_category": "ALL",
		"name": "found_error_white_unique",
		"description": "adas asdasd",
		"weight": 3.4,
		"stack_size": 1,
		"size_in_slots": [1]
	}
}

func get_item_data(item, key):
	if item.has_meta(key):
		# item can have custom name, last_owner, e.t.c.
		return item.get_meta(key)
	DebUtil.debCheck(item.has_meta("item_id"), "logic error")
	var item_data = ITEMS[item.get_meta("item_id")]
	DebUtil.debCheck(item_data.has(key), "logic error")
	return item_data[key]

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

func has_slot_item(slot):
	return slot.has_meta(self.name + "_stored_item") and ItemDB.get_slot_item(slot) != null
	
func get_slot_item(slot):
	if not slot.has_meta(self.name + "_stored_item"):
		return null
	return slot.get_meta(self.name + "_stored_item")

# NOTE: does not position item in slot, prefer replace_slot_item
func set_slot_item_unchecked(slot, item):
	slot.set_meta(self.name + "_stored_item", item)
