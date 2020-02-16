extends InventorySlot

export (PackedScene) var _tooltip_hovered_PackedScene = null

var _tooltip_hovered = null

export(NodePath) var _tooltip_area_NodePath = null

var _tooltip_area = null

export(NodePath) var _bg_NodePath = null

var bg_node:ColorRect = null

export(NodePath) var _tween_scale_NodePath  = null

var _tween_scale:Tween = null

export(NodePath) var _tween_color_NodePath  = null

var _tween_color:Tween = null

export var _is_hovered:bool = false

export var _is_selected:bool = false

export(Vector2) var hovered_scale = Vector2(1.2,1.2)

export(Vector2) var hovered_pivot = Vector2(0.0,0.0)

export(float) var hovered_tween_seconds = 0.1

export(Color) var default_bg_color = Color(0.7, 0.7, 0.8, 0.35)

export(Color) var selected_bg_color = Color(0.6, 0.6, 0.8, 0.35)

export(float) var selected_tween_seconds = 0.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(_delta):
	var cursor_pos = get_global_mouse_position()
	#if cursor_pos.distance_to(_last_cursor_pos) > FLOAT_DELTHA:
	change_hover(self.get_global_rect().has_point(cursor_pos))
	
func _ready():
	if _tooltip_area_NodePath != null:
		_tooltip_area = get_node(_tooltip_area_NodePath)
		
	if _tooltip_hovered_PackedScene != null:	
		_tooltip_hovered = _tooltip_hovered_PackedScene.instance()
		_tooltip_hovered.set_display_area(_tooltip_area)
		
	bg_node = get_node(_bg_NodePath) as ColorRect
	
	_tween_scale = get_node(_tween_scale_NodePath) as Tween # Tween.new()
	#_tween_scale.connect("tween_completed", self, "tween_scale_complete")

	if true: # scope
		var err = _tween_scale.connect("tween_completed", self, "_on_tween_scale_complete")
		DebUtil.debCheck(!err, "logic error")
		
	_tween_color = get_node(_tween_color_NodePath) as Tween # Tween.new()
	#_tween_color.connect("tween_completed", self, "tween_color_complete")
	
	if true: # scope
		var err = _tween_color.connect("tween_completed", self, "_on_tween_color_complete")
		DebUtil.debCheck(!err, "logic error")
	
	# NOTE: make sure everything is properly configured before using Tween`s
	change_selection(_is_selected, true)
	change_hover(_is_hovered, true)
	
func _on_tween_scale_complete(_obj, _key):
	#print("tween_scale_complete : obj = ",_obj,", key = ", _key)
	if _tooltip_hovered != null:
		toggle_tooltip(_tooltip_hovered, _is_hovered)
	
func _on_tween_color_complete(_obj, _key):
	#print("tween_color_complete : obj = ",_obj,", key = ", _key)
	pass
	
func toggle_tooltip(tooltip, need_show):
	if not need_show:
		tooltip.hide()
		return

	if _tooltip_area != null:
		Helpers.reparent(tooltip, _tooltip_area)
		#if not _tooltip_area.has_child(tooltip):
		#	_tooltip_area.add_child(tooltip) # must call _ready before everything else
	else:
		#var current_root = get_tree().get_current_scene().get_root()
		var current_root = get_tree().get_root()
		Helpers.reparent(tooltip, current_root)
		#if not current_root.has_child(tooltip):
		#	current_root.add_child(tooltip) # must call _ready before everything else

	tooltip.set_follow_mouse(false)
	
	var slot_item = ItemDB.get_slot_item(self)
	if slot_item == null:
		tooltip.hide()
		return
		
	tooltip.set_tip_title(tr(ItemDB.get_item_data(slot_item, "name")))
	tooltip.set_tip_body(tr(ItemDB.get_item_data(slot_item, "description")))
	# NOTE: fully configure tooltip before moving it anywhere
	tooltip.move_to(self.rect_global_position)
	tooltip.show()

func change_selection(is_selected:bool, force_change:bool = false):
	if _is_selected != is_selected or force_change:
		#emit_signal("slot_changed_selection", is_selected, self)
		var color_from = bg_node.color
		var color_to = default_bg_color
		if is_selected:
			color_to = selected_bg_color
		#bg_node.color = color_to
		DebUtil.debCheck("color" in bg_node, "logic error")
		
		if _tween_color.is_active():
			if not _tween_color.remove_all():
				DebUtil.debCheck(false, "logic error")
				
			if not _tween_color.stop_all():
				DebUtil.debCheck(false, "logic error")

		if not _tween_color.interpolate_property(bg_node, "color", \
						color_from, color_to, \
						selected_tween_seconds, \
						Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
			DebUtil.debCheck(false, "logic error")
			
		if not _tween_color.start():
			DebUtil.debCheck(false, "logic error")
	_is_selected = is_selected
	
func change_hover(is_hovered:bool, force_change:bool = false):
	if _is_hovered != is_hovered or force_change:
		#emit_signal("slot_changed_hover", is_hovered, self)
		var scale_from = self.rect_scale
		var pivot_from = self.rect_pivot_offset
		var scale_to = Vector2(1.0,1.0)
		# NOTE: When you change its rect_scale, it will scale around this pivot. 
		# Set to rect_size / 2 to center the pivot in the node's rectangle.
		var pivot_to = self.rect_size / 2.0
		
		if is_hovered:
			scale_to = hovered_scale
			
		if _tween_scale.is_active():
			if not _tween_scale.remove_all():
				DebUtil.debCheck(false, "logic error")
			
			if not _tween_scale.stop_all():
				DebUtil.debCheck(false, "logic error")
			
		DebUtil.debCheck("rect_pivot_offset" in self, "logic error")
		if not _tween_scale.interpolate_property(self, "rect_pivot_offset", \
						pivot_from, pivot_to, \
						hovered_tween_seconds, \
						Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
			DebUtil.debCheck(false, "logic error")
			
		DebUtil.debCheck("rect_scale" in self, "logic error")
		if not _tween_scale.interpolate_property(self, "rect_scale", \
						scale_from, scale_to, \
						hovered_tween_seconds, \
						Tween.TRANS_LINEAR, Tween.EASE_IN_OUT):
			DebUtil.debCheck(false, "logic error")
			
		if not _tween_scale.start():
			DebUtil.debCheck(false, "logic error")
	_is_hovered = is_hovered
