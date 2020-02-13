extends Control


export(NodePath) var _tip_title_NodePath = null

export(NodePath) var _tip_body_NodePath = null

export(bool) var _debug_mode = false

export(NodePath) var _debug_display_area_NodePath = null

var _debug_display_area:ColorRect = null

var _tip_title:Label = null

var _tip_body:RichTextLabel = null

var _display_area = null

var _is_following_mouse:bool = true

onready var tooltip_rect = $tooltip_rect

onready var _debug_display_area_center = $debug_display_area_center

func set_display_area(display_area):
	_display_area = display_area

func get_display_area() -> Rect2:
	if _display_area == null:
		return Rect2(0.0, 0.0, OS.window_size.x, OS.window_size.y)

	return Rect2(_display_area.rect_global_position.x, _display_area.rect_global_position.y, _display_area.rect_size.x, _display_area.rect_size.y)
	
func set_follow_mouse(need_follow:bool) -> void:
	_is_following_mouse = need_follow
	
func is_following_mouse() -> bool:
	return _is_following_mouse

func get_Rect2_center(rect:Rect2) -> Vector2:
	var display_area:Rect2 = rect
	var display_area_top_left:Vector2 = display_area.position
	var display_area_bottom_right:Vector2 = display_area.end
	return display_area_top_left + (display_area_bottom_right - display_area_top_left) / 2.0
		
func get_tooltip_area() -> Rect2:
	return Rect2(tooltip_rect.rect_global_position.x, tooltip_rect.rect_global_position.y, tooltip_rect.rect_size.x, tooltip_rect.rect_size.y)
	
func get_cursor_size() -> Vector2:
	return Vector2(10, 20)
	
# NOTE: fully configure tooltip before moving it anywhere
func move_to(anchor:Vector2):
	var display_area:Rect2 = get_display_area()
	var display_area_top_left:Vector2 = display_area.position
	var display_area_bottom_right:Vector2 = display_area.end
	var display_area_center:Vector2 = get_Rect2_center(display_area)
	var aboveCenter:bool = anchor.y > display_area_center.y 
	var belowCenter:bool = !aboveCenter
	var leftToCenter:bool = anchor.x <= display_area_center.x
	var rightToCenter:bool = !leftToCenter
	var move_tooltip_center_to_anchor:Vector2 \
		= anchor - get_tooltip_area().size / 2.0
	var new_pos = move_tooltip_center_to_anchor
	
	# prevent parts of tooltip to be outside display area 
	if leftToCenter:
		new_pos.x += tooltip_rect.rect_size.x / 2.0

	if rightToCenter:
		new_pos.x  -= tooltip_rect.rect_size.x / 2.0

	if belowCenter:
		new_pos.y += tooltip_rect.rect_size.y / 2.0

	if aboveCenter:
		new_pos.y -= tooltip_rect.rect_size.y / 2.0
		
	# mouse cursor must not overlap or hide tooltip
	if is_following_mouse():

		if new_pos.y >= anchor.y:
			 new_pos.y += get_cursor_size().y

		if new_pos.x >= anchor.x:
			 new_pos.x += get_cursor_size().x
	
	# clamp pos inside display area
	if new_pos.x < display_area_top_left.x:
		new_pos.x = display_area_top_left.x

	if new_pos.y < display_area_top_left.y:
		new_pos.y = display_area_top_left.y

	if new_pos.x > display_area_bottom_right.x - tooltip_rect.rect_size.x:
		new_pos.x = display_area_bottom_right.x - tooltip_rect.rect_size.x

	if new_pos.y > display_area_bottom_right.y - tooltip_rect.rect_size.y:
		new_pos.y = display_area_bottom_right.y - tooltip_rect.rect_size.y

	tooltip_rect.rect_global_position = new_pos
	
# Called when the node enters the scene tree for the first time.
func _ready():
	_tip_title = get_node(_tip_title_NodePath)
	_tip_body = get_node(_tip_body_NodePath)
	self.rect_global_position = Vector2(0, 0)
	tooltip_rect.rect_size = Vector2(150, 250)
	tooltip_rect.rect_min_size = tooltip_rect.rect_size
	if _debug_mode:
		DebUtil.debCheck(_debug_display_area_NodePath != null, "logic error")
		_debug_display_area = get_node(_debug_display_area_NodePath)
		_debug_display_area.show()
		_debug_display_area.rect_position = get_display_area().position
		_debug_display_area.rect_size = get_display_area().size
		DebUtil.debCheck(_debug_display_area_center != null, "logic error")
		_debug_display_area_center.show()
		_debug_display_area_center.rect_position = get_Rect2_center(get_display_area())
		_debug_display_area_center.rect_size = Vector2(50, 50)

func _input(_delta):
	if is_following_mouse():
		var cursor_pos = get_global_mouse_position()
		move_to(cursor_pos)
	
func set_tip_title(text):
	_tip_title.text = text
	
func set_tip_body(text):
	_tip_body.bbcode_text = text
