extends Control

# 
# Used to:
# * drag'n'drop items between containers 
# * grab items with mouse
# 
# Make sure that node covers full screen to handle item drag'n'drop between containers
#

export(Array, NodePath) var _allowed_container_paths = null


enum DRAG_ON_SLOT_BEHAVIOR {swap_existing_item, keep_existing_item}

export(DRAG_ON_SLOT_BEHAVIOR) var _drag_on_slot_behavior = DRAG_ON_SLOT_BEHAVIOR.keep_existing_item

# can drag'n'drop items between connected containers
var _allowed_containers:Array = []

# trash areas are optional
# item dropped into trash area will be deleted
export(Array, NodePath) var _allowed_trash_area_paths = null

var _allowed_trash_areas:Array = []
  
export (PackedScene) var _item_base = null

# currently grabbed item
var _item_held:InventoryItemBase = null
var _item_held_slot = null
var _item_offset:Vector2 = Vector2()
var _last_grabbed_container = null
var _last_item_pos_before_grab:Vector2 = Vector2()
var _last_cursor_pos:Vector2 = Vector2()

const FLOAT_DELTHA = 0.0000001

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: self.z_index = 99 # make sure that dragged node in front

	if _allowed_trash_area_paths != null:
		for path in _allowed_trash_area_paths:
			DebUtil.debCheck(get_node(path) != null, "logic error")
			var trash_area = get_node(path)
			_allowed_trash_areas.append(trash_area)

	DebUtil.debCheck(_allowed_container_paths != null, "logic error")
	for path in _allowed_container_paths:
		DebUtil.debCheck(get_node(path) != null, "logic error")
		var container = get_node(path) as InventoryItemContainer
		DebUtil.debCheck(container != null, "logic error")
		_allowed_containers.append(container)
		pickup_item(ItemDB.ITEM_ID.sword, container) 
		pickup_item(ItemDB.ITEM_ID.potato, container)
		pickup_item(ItemDB.ITEM_ID.potato, container)
		pickup_item(ItemDB.ITEM_ID.sword, container)
		pickup_item(ItemDB.ITEM_ID.breastplate, container)
		pickup_item(ItemDB.ITEM_ID.breastplate, container) 
		#pickup_item(ItemDB.ITEM_ID.khfdd, container)

func handle_mouse_drag(cursor_pos):
	var is_menu_overlay_visible = Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
	if is_menu_overlay_visible:
		if Input.is_action_just_pressed("inv_grab"):
			grab(cursor_pos)
		if Input.is_action_just_released("inv_grab"):
			release(cursor_pos)
		update_item_held_pos(cursor_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var cursor_pos = get_global_mouse_position()
	#if cursor_pos.distance_to(_last_cursor_pos) > FLOAT_DELTHA:
	handle_mouse_drag(cursor_pos)
	_last_cursor_pos = cursor_pos
		
func update_item_held_pos(cursor_pos):
	if _item_held != null:
		DebUtil.debCheck(_item_held_slot != null, "logic error")
		# move item based on cursor pos
		_item_held.rect_global_position = cursor_pos + _item_offset
		# TODO: _item_held.z_index = 99 # make sure that dragged node in front

func reparent(target, new_parent):
	DebUtil.debCheck(target != null, "logic error")
	DebUtil.debCheck(new_parent != null, "logic error")
	target.get_parent().remove_child(target)
	new_parent.add_child(target)
	
func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		var grab_result = c.grab_item(cursor_pos)
		if grab_result != null:
			set_held_item_data(grab_result.item, grab_result.slot)
			if _item_held != null:
				DebUtil.debCheck(_item_held_slot != null, "logic error")
				_last_grabbed_container = c
				_last_item_pos_before_grab = _item_held.rect_global_position
				_item_offset = _item_held.rect_global_position - cursor_pos
 
func set_held_item_data(item, slot):
	_item_held = item
	_item_held_slot = slot

func is_in_trash_area(cursor_pos):
	for c in _allowed_trash_areas:
		if c.get_global_rect().has_point(cursor_pos):
			return c

func release(cursor_pos):
	if _item_held == null:
		return

	DebUtil.debCheck(_item_held_slot != null, "logic error")

	var pointed_container = get_container_under_cursor(cursor_pos)
	if pointed_container == null and is_in_trash_area(cursor_pos):
		delete_held_item()
		return

	if pointed_container == null:
		# dragged item into unknown area (not trash or container)
		return_held_item_to_container()
		return

	var slot_under_pos = pointed_container.get_slot_under_pos(cursor_pos)
	if slot_under_pos == null: 
		return_held_item_to_container()
		return  

	if _drag_on_slot_behavior == DRAG_ON_SLOT_BEHAVIOR.keep_existing_item:
		# will replace slot item only if slot not busy
		if pointed_container.try_insert_item_at_free_slot(_item_held, slot_under_pos):
			set_held_item_data(null, null)
			return
		else:
			return_held_item_to_container()
			return
	elif _drag_on_slot_behavior == DRAG_ON_SLOT_BEHAVIOR.swap_existing_item:
		# will swap slot items
		var prev_held_slot = _item_held_slot
		DebUtil.debCheck(not _last_grabbed_container.has_slot_item(_item_held_slot), "logic error")
		return_held_item_to_container()
		DebUtil.debCheck(_last_grabbed_container.has_slot_item(prev_held_slot), "logic error")
		if swap_slot_items_between_containers(_last_grabbed_container, prev_held_slot, pointed_container, slot_under_pos):
			set_held_item_data(null, null)
			return
		else:
			return_held_item_to_container()
			return
	else:
		DebUtil.check(false, "not implemented")

func get_container_under_cursor(cursor_pos):
	for c in _allowed_containers:
		if c.is_under_cursor(cursor_pos):
			return c
	return null

func delete_held_item():
	DebUtil.debCheck(_item_held != null, "logic error")
	DebUtil.debCheck(_item_held_slot != null, "logic error")
	_item_held.queue_free()
	set_held_item_data(null, null)

func return_held_item_to_container():
	DebUtil.debCheck(_item_held != null, "logic error")
	DebUtil.debCheck(_item_held_slot != null, "logic error")
	_item_held.rect_global_position = _last_item_pos_before_grab
	DebUtil.debCheck(_last_grabbed_container.get_slot_id(_item_held_slot) != null, "logic error")
	DebUtil.debCheck(not _last_grabbed_container.has_slot_item(_item_held_slot), "logic error")
	var success = _last_grabbed_container.try_insert_item_at_free_slot(_item_held, _item_held_slot)
	DebUtil.debCheck(_last_grabbed_container.get_slot_item(_item_held_slot) == _item_held, "logic error")
	if not success:
		DebUtil.debCheck(false, "logic error")
		# unexpected error, but try to fix it in release mode
		_last_grabbed_container.try_insert_item_at_first_free_slot(_item_held)
	set_held_item_data(null, null)

func swap_slot_items_between_containers(containerA:InventoryItemContainer, slotA, containerB:InventoryItemContainer, slotB): 
	DebUtil.debCheck(slotA != null, "logic error")
	DebUtil.debCheck(containerA.get_slot_id(slotA) != null, "logic error")
	DebUtil.debCheck(slotB != null, "logic error")
	DebUtil.debCheck(containerB.get_slot_id(slotB) != null, "logic error")

	# NOTE: copy items before swap
	var slotAItem = containerA.get_slot_item(slotA)
	var slotBItem = containerB.get_slot_item(slotB)

	containerB.replace_and_position_slot_item(slotB, slotAItem)
	DebUtil.debCheck(containerB.get_slot_item(slotB) == slotAItem, "logic error")
	
	containerA.replace_and_position_slot_item(slotA, slotBItem)
	DebUtil.debCheck(containerA.get_slot_item(slotA) == slotBItem, "logic error")

	return true

func pickup_item(item_id, container:InventoryItemContainer): 
	var item = ItemDB.create_item(container, _item_base, item_id);
	DebUtil.debCheck(item != null, "logic error")
	if !container.try_insert_item_at_first_free_slot(item):
		item.queue_free()
		return false
	return true

