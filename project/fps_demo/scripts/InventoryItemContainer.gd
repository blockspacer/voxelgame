extends Node

var _slots2D:Array = []

var _selected_slots:Array = []

enum ITEM_REPLACE_POLICY {
	keep_in_memory, # NOTE: does not delete prev item, you can re-use it and must free it manually
	queue_free
}

func change_slots_selection(_slots1D:Array, _is_selected:bool):
	DebUtil.check(false, "not implemented") # will be redefined

func change_all_slots_selection(_is_selected:bool):
	DebUtil.check(false, "not implemented") # will be redefined

func is_under_cursor(_cursor_pos):
	DebUtil.check(false, "not implemented") # will be redefined

func set_slot_draggable_from(slot, flag:bool):
	slot.set_meta(self.name + "_is_draggable_from", flag)

func set_slot_droppable_in(slot, flag:bool):
	slot.set_meta(self.name + "_is_droppable_in", flag)

func is_slot_draggable_from(slot):
	DebUtil.debCheck(slot.has_meta(self.name + "_is_draggable_from"), "logic error")
	return slot.get_meta(self.name + "_is_draggable_from")

func is_slot_droppable_in(slot):
	DebUtil.debCheck(slot.has_meta(self.name + "_is_droppable_in"), "logic error")
	return slot.get_meta(self.name + "_is_droppable_in")
	
func set_slot_id(slot, row_idx, col_idx):
	DebUtil.debCheck(slot != null, "logic error")
	DebUtil.debCheck(!slot.has_meta("row_idx"), "logic error")
	DebUtil.debCheck(!slot.has_meta("col_idx"), "logic error")
	DebUtil.debCheck(!slot.has_meta("container_name"), "logic error")
	slot.set_meta("row_idx", row_idx)
	slot.set_meta("col_idx", col_idx)
	#slot.set_meta("container_name", self.name)
	
func get_slot_row(slot):
	DebUtil.debCheck(slot != null, "logic error")
	DebUtil.debCheck(slot.has_meta("row_idx"), "logic error")
	DebUtil.debCheck(slot.has_meta("col_idx"), "logic error")
	return slot.get_meta("row_idx")

func get_slot_column(slot):
	DebUtil.debCheck(slot != null, "logic error")
	DebUtil.debCheck(slot.has_meta("col_idx"), "logic error")
	return slot.get_meta("col_idx")

func set_slots2DArray(slots:Array):
	_slots2D = slots

func resize_row_in_slots2DArray(row_idx:int, column_num_in_row:int):
	if _slots2D.size() < row_idx + 1:
		_slots2D.resize(row_idx + 1)

	_slots2D[row_idx] = []

	for _num in range(column_num_in_row):
		_slots2D[row_idx].append(null)

func init_slot(row_idx, column_idx, slot, initial_item):
	DebUtil.debCheck(_slots2D.size() > row_idx, "logic error")
	DebUtil.debCheck(_slots2D[row_idx].size() > column_idx, "logic error")
	DebUtil.debCheck(slot != null, "logic error")
	set_slot_id(slot, row_idx, column_idx)
	_slots2D[row_idx][column_idx] = slot
	DebUtil.debCheck(ItemDB.get_slot_item(slot) == null, "logic error: slot is busy, can`t use it again")
	ItemDB.set_slot_item_unchecked(slot, initial_item)
	if OS.is_debug_build():
		print("added slot ", slot.name, " with id ", get_slot_row(slot), "x", get_slot_column(slot))
	 
func position_item_in_slot(item:InventoryItemBase, slot):
	DebUtil.debCheck(item != null, "logic error")
	DebUtil.debCheck(slot != null, "logic error")
	Helpers.call_deferred("reparent", item, slot)
	item.rect_position = Vector2(0.0,0.0)
	# TODO: item.z_index = 0 # make sure to reset changes in z_index
	
func delete_slot_item(slot):
	if(ItemDB.has_slot_item(slot)):
		DebUtil.debCheck(ItemDB.get_slot_item(slot) != null, "logic error")
		ItemDB.get_slot_item(slot).queue_free()
		ItemDB.set_slot_item_unchecked(slot, null)
		DebUtil.debCheck(ItemDB.get_slot_item(slot) == null, "logic error")
 
func replace_and_position_slot_item(slot, item, need_del_prev_item = ITEM_REPLACE_POLICY.keep_in_memory):
	if need_del_prev_item == ITEM_REPLACE_POLICY.queue_free:
		delete_slot_item(slot)
		DebUtil.debCheck(ItemDB.get_slot_item(slot) == null, "logic error: slot is busy, can`t use it again")

	ItemDB.set_slot_item_unchecked(slot, item)

	DebUtil.debCheck(ItemDB.get_slot_item(slot) == item, "logic error")

	if item != null:
		position_item_in_slot(item, slot)

	return true
	
func grab_item(pos):
	var slot = get_slot_under_pos(pos)

	if slot == null:
		return null
		
	if not is_slot_draggable_from(slot):
		return null

	var item = get_slot_item_under_pos(slot, pos)

	if item == null:
		return null
   
	ItemDB.set_slot_item_unchecked(slot, null)
	
	return {
		"item": item, 
		"slot": slot
	}
 
func get_slot_under_pos(pos):
	for row in _slots2D:
		for slot in row:
			DebUtil.debCheck(slot != null, "logic error")
			if slot.get_global_rect().has_point(pos):
				return slot

	return null
 
func get_slot_item_under_pos(slot, pos):
	DebUtil.debCheck(slot != null, "logic error")
	var item = ItemDB.get_slot_item(slot)
	if ItemDB.has_slot_item(slot) and item.get_global_rect().has_point(pos):
		DebUtil.debCheck(item != null, "logic error")
		return item

	return null

func try_insert_item_at_free_slot(item, slot):
	DebUtil.debCheck(item != null, "logic error")
	DebUtil.debCheck(slot != null, "logic error")
	if not ItemDB.has_slot_item(slot) and replace_and_position_slot_item(slot, item, ITEM_REPLACE_POLICY.queue_free):
		return true

	return false

func swap_slot_items(slotA, slotB):
	DebUtil.debCheck(slotA != null, "logic error")
	DebUtil.debCheck(slotB != null, "logic error")

	# NOTE: copy items before swap
	var slotAItem = ItemDB.get_slot_item(slotA)
	var slotBItem = ItemDB.get_slot_item(slotB)
	
	replace_and_position_slot_item(slotB, slotAItem)
	DebUtil.debCheck(ItemDB.get_slot_item(slotB) == slotAItem, "logic error")
	
	replace_and_position_slot_item(slotA, slotBItem)
	DebUtil.debCheck(ItemDB.get_slot_item(slotA) == slotBItem, "logic error")
	
	return true

func try_insert_item_at_first_free_slot(item):
	DebUtil.debCheck(item != null, "logic error")
	for row in _slots2D:
		for slot in row:
			DebUtil.debCheck(slot != null, "logic error")
			if try_insert_item_at_free_slot(item, slot):
				return true
				
	return false
