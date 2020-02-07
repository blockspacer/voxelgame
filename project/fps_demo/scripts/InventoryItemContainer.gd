extends Node

var _slots:Array = []

var _stored_items = []

enum ITEM_REPLACE_POLICY {
	keep_in_memory, # NOTE: does not delete prev item, you can re-use it and must free it manually
	queue_free
}

func is_under_cursor(_cursor_pos):
	DebUtil.check(false, "not implemented") # will be redefined
	
func generate_slot_id():
	return _slots.size()
	
func set_slot_id(slot, slot_id):
	DebUtil.debCheck(slot != null, "logic error")
	DebUtil.debCheck(!slot.has_meta("slot_id"), "logic error")
	slot.set_meta("slot_id", slot_id)
	
func get_slot_id(slot):
	DebUtil.debCheck(slot != null, "logic error")
	DebUtil.debCheck(slot.has_meta("slot_id"), "logic error")
	return slot.get_meta("slot_id")

func init_slot(slot, initial_item):
	DebUtil.debCheck(slot != null, "logic error")
	set_slot_id(slot, generate_slot_id())
	_slots.append(slot)
	_stored_items.append(initial_item)
	DebUtil.debCheck(get_slot_item(slot) == null, "logic error: slot is busy, can`t use it again")
	set_slot_item_unchecked(slot, initial_item)
	if OS.is_debug_build():
		print("added slot ", slot.name, " with id ", get_slot_id(slot))
	# NOTE: stored_items container size same as slots container size
	DebUtil.debCheck(_slots.size() == _stored_items.size(), "logic error")
	
func reparent(target, new_parent):
	DebUtil.debCheck(target != null, "logic error")
	DebUtil.debCheck(new_parent != null, "logic error")
	target.get_parent().remove_child(target)
	new_parent.add_child(target)

func has_slot_item(slot):
	return _stored_items[get_slot_id(slot)] != null
	
func get_slot_item(slot):
	return _stored_items[get_slot_id(slot)]

# NOTE: does not position item in slot, prefer replace_slot_item
func set_slot_item_unchecked(slot, item):
	_stored_items[get_slot_id(slot)] = item
	 
func position_item_in_slot(item:InventoryItemBase, slot):
	DebUtil.debCheck(item != null, "logic error")
	DebUtil.debCheck(slot != null, "logic error")
	call_deferred("reparent", item, slot)
	item.rect_position = Vector2(0.0,0.0)
	# TODO: item.z_index = 0 # make sure to reset changes in z_index
	
func delete_slot_item(slot):
	if(has_slot_item(slot)):
		DebUtil.debCheck(_stored_items[get_slot_id(slot)] != null, "logic error")
		_stored_items[get_slot_id(slot)].queue_free()
		set_slot_item_unchecked(slot, null)
		DebUtil.debCheck(_stored_items[get_slot_id(slot)] == null, "logic error")
 
func replace_and_position_slot_item(slot, item, need_del_prev_item = ITEM_REPLACE_POLICY.keep_in_memory):
	if need_del_prev_item == ITEM_REPLACE_POLICY.queue_free:
		delete_slot_item(slot)
		DebUtil.debCheck(get_slot_item(slot) == null, "logic error: slot is busy, can`t use it again")
	set_slot_item_unchecked(slot, item)
	DebUtil.debCheck(_stored_items[get_slot_id(slot)] == item, "logic error")
	if item != null:
		position_item_in_slot(item, slot)
	return true
	
func grab_item(pos):
	var slot = get_slot_under_pos(pos)
	if slot == null:
		return null
		
	var item = get_slot_item_under_pos(slot, pos)
	if item == null:
		return null
   
	set_slot_item_unchecked(slot, null)
	
	return {
		"item": item, 
		"slot": slot
	}
 
func get_slot_under_pos(pos):
	for slot in _slots:
		DebUtil.debCheck(slot != null, "logic error")
		DebUtil.debCheck(get_slot_id(slot) != null, "logic error")
		if slot.get_global_rect().has_point(pos):
			return slot
	return null
 
func get_slot_item_under_pos(slot, pos):
	DebUtil.debCheck(slot != null, "logic error")
	var item = get_slot_item(slot)
	if has_slot_item(slot) and item.get_global_rect().has_point(pos):
		DebUtil.debCheck(item != null, "logic error")
		return item
	return null

func try_insert_item_at_free_slot(item, slot):
	DebUtil.debCheck(item != null, "logic error")
	DebUtil.debCheck(slot != null, "logic error")
	DebUtil.debCheck(get_slot_id(slot) != null, "logic error")
	if not has_slot_item(slot) and replace_and_position_slot_item(slot, item, ITEM_REPLACE_POLICY.queue_free):
		return true
	return false

func swap_slot_items(slotA, slotB):
	DebUtil.debCheck(slotA != null, "logic error")
	DebUtil.debCheck(get_slot_id(slotA) != null, "logic error")
	DebUtil.debCheck(slotB != null, "logic error")
	DebUtil.debCheck(get_slot_id(slotB) != null, "logic error")

	# NOTE: copy items before swap
	var slotAItem = get_slot_item(slotA)
	var slotBItem = get_slot_item(slotB)
	
	replace_and_position_slot_item(slotB, slotAItem)
	DebUtil.debCheck(get_slot_item(slotB) == slotAItem, "logic error")
	
	replace_and_position_slot_item(slotA, slotBItem)
	DebUtil.debCheck(get_slot_item(slotA) == slotBItem, "logic error")
	
	return true

func try_insert_item_at_first_free_slot(item):
	DebUtil.debCheck(item != null, "logic error")
	for slot in _slots:
		DebUtil.debCheck(slot != null, "logic error")
		DebUtil.debCheck(get_slot_id(slot) != null, "logic error")
		if try_insert_item_at_free_slot(item, slot):
			return true
	return false
