extends InventoryItemContainer

export(NodePath) var _slots_path = null

var _slots_container = null

func is_under_cursor(cursor_pos):
	#print('_container.get_global_rect()', _slots_container.get_global_rect())
	#print('cursor_pos', cursor_pos)
	return _slots_container.get_global_rect().has_point(cursor_pos)
  
func prepare(slots_path):
	_slots_container = get_node(slots_path)
	for slot in _slots_container.get_children():
		init_slot(slot, null)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	prepare(_slots_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
