extends InventoryItemContainer

# "rows":[
# 	{"columns": [{"node_path":...}, {"node_path":...}, ...]},
# 	{"columns": [{"node_path":...}, {"node_path":...}, ...]},
# 	{"columns": [{"node_path":...}, {"node_path":...}, ...]},
# ]
export(Dictionary) var _slots_dict = {}

export(Array, NodePath) var _bounding_areas_NodePaths = null

export(NetworkIDs.NETWORK_CONTAINER_ID) var _network_cointainer_id = null

var _bounding_areas:Array = []
 
func change_slots_selection(slots1D:Array, is_selected:bool):
	DebUtil.check(slots1D.size() > 0, "logic error")
	for slot in slots1D:
		slot.change_selection(is_selected)

func change_all_slots_selection(is_selected:bool):
	for row1D in _slots2D:
		change_slots_selection(row1D, is_selected)

func is_under_cursor(cursor_pos):
	for area in _bounding_areas:
		if area.get_global_rect().has_point(cursor_pos):
			return true
	return false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	for path in _bounding_areas_NodePaths:
		var node = get_node(path)
		DebUtil.debCheck(node != null, "logic error")
		_bounding_areas.append(node)
		
	DebUtil.debCheck(_slots_dict.has("rows"), "logic error")
	var _rows_data = _slots_dict.get("rows")
	DebUtil.debCheck(_rows_data.size() > 0, "logic error")
	var row_idx:int = 0
	for row_data in _rows_data:
		DebUtil.debCheck(row_data.has("columns"), "logic error")
		DebUtil.debCheck(row_data.get("columns").size() > 0, "logic error")
		resize_row_in_slots2DArray(row_idx, row_data.get("columns").size())
		var column_idx:int = 0
		for column in row_data.get("columns"):
			DebUtil.debCheck(column.has("node_path"), "logic error")
			var slot = get_node(column.get("node_path"))
			DebUtil.debCheck(slot != null, "logic error")
			init_slot(row_idx, column_idx, slot, null) 
			if column.has("is_draggable_from"):
				set_slot_draggable_from(slot, column.get("is_draggable_from") as bool)
			else:
				set_slot_draggable_from(slot, true)
			if column.has("is_droppable_in"):
				set_slot_droppable_in(slot, column.get("is_droppable_in") as bool)
			else:
				set_slot_droppable_in(slot, true)
			column_idx+=1
		row_idx+=1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
