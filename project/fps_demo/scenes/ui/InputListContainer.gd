extends HBoxContainer

export(NodePath) var PopupControlPath = null

var PopupControl = null

signal key_selected

var changing_action_name = null

onready var Col1Data = $Col1Container/Col1Data
onready var Col2Data = $Col2Container/Col2Data
onready var Col3Data = $Col3Container/Col3Data

func clear():
	for child in Col1Data.get_children():
		Col1Data.remove_child(child)
		child.free()
	#
	for child in Col2Data.get_children():
		Col2Data.remove_child(child)
		child.free()
	#
	for child in Col3Data.get_children():
		Col3Data.remove_child(child)
		child.free()

func add_input_line(action_name, scancode):
	var scancode_as_str = OS.get_scancode_string(scancode)
	if true: # scope
		var label = Label.new()
		label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		#label.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER;
		#label.set_anchors_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_VCENTER_WIDE)
		#label.set_margins_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_VCENTER_WIDE)
		#label.set_align(Label.ALIGN_CENTER)
		#label.set_valign(Label.VALIGN_CENTER)
		var font = load("res://fps_demo/assets/fonts/arial_32_dynamicfont.tres")
		#font.size = 90
		label.add_font_override("font", font)
		label.add_color_override("font_color", Color(0.0,0.0,0.0))
		label.set_text(action_name.capitalize())
		Col1Data.add_child(label)
	if true: # scope
		var label = Label.new()
		label.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		#label.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER;
		#label.set_anchors_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_VCENTER_WIDE)
		#label.set_margins_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_VCENTER_WIDE)
		#label.set_align(Label.ALIGN_CENTER)
		#label.set_valign(Label.VALIGN_CENTER)
		var font = load("res://fps_demo/assets/fonts/arial_32_dynamicfont.tres")
		#font.size = 90
		label.add_font_override("font", font)
		label.add_color_override("font_color", Color(0.0,0.0,0.0))
		label.set_text(scancode_as_str)
		Col2Data.add_child(label)
	if true: # scope
		var btn = Button.new()
		btn.set_mouse_filter(Control.MOUSE_FILTER_STOP)
		btn.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER;
		#btn.set_anchors_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_VCENTER_WIDE)
		#btn.set_margins_preset(Control.PRESET_HCENTER_WIDE | Control.PRESET_VCENTER_WIDE)
		#btn.set_align(Label.ALIGN_CENTER)
		#btn.set_valign(Label.VALIGN_CENTER)
		var font = load("res://fps_demo/assets/fonts/arial_32_dynamicfont.tres")
		#font.size = 90
		btn.add_font_override("font", font)
		btn.add_color_override("font_color", Color(0.0,0.0,0.0))
		btn.set_text("change")
		btn.set_focus_mode(Control.FOCUS_CLICK)
		btn.connect('pressed', self, \
				'_on_InputLine_change_button_pressed', [action_name, scancode])
		Col3Data.add_child(btn)

func _on_InputLine_change_button_pressed(action_name, _scancode):
	PopupControl.show()
	changing_action_name = action_name
	#
	if self.is_connected("key_selected", self, "_on_key_selected"): # scope
		if true: # scope
			# If you try to disconnect a connection that does not exist, 
			# the method will throw an error. 
			self.disconnect("key_selected", self, "_on_key_selected")
	#
	if true: # scope
		var err = self.connect("key_selected", self, "_on_key_selected")
		DebUtil.debCheck(!err, "logic error")

func _on_key_selected(key_scancode):
	GlobalLogger.info(self, \
		"_on_key_selected changing_action_name " \
		+ str(changing_action_name) \
		+ " key_scancode " \
		+ str(key_scancode))
	#
	InputMapping.map_key_input(InputMapping.config_section, changing_action_name, key_scancode)
	#
	PopupControl.hide()
	#
	self.call_deferred("rebuild")
	changing_action_name = null
	
func _input(event):
	if not event.is_pressed():
		return
	if changing_action_name == null:
		return
	if event is InputEventKey:
		emit_signal("key_selected", event.scancode)
		# Stop the event from spreading during "input key" dialog
		get_tree().set_input_as_handled()

func _InputMap_filter_conditional(element) -> bool:
	return InputMapping.modifiable_action_names.find(element) != -1

func rebuild():
	GlobalLogger.info(self, \
		"rebuilding action list...")
	clear()
	# TODO: sort and filter actions 
	var critera = funcref(self, "_InputMap_filter_conditional")
	var filteredActions = \
		Helpers.filter(InputMap.get_actions(), critera)
	filteredActions.sort()
	
	for action in filteredActions:
		for member in InputMap.get_action_list(action):
			if member is InputEventKey:
				var inkey = member as InputEventKey
				add_input_line(action, inkey.scancode)
				
# Called when the node enters the scene tree for the first time.
func _ready():
	PopupControl = get_node(PopupControlPath)
	PopupControl.hide()
	rebuild()
	pass # Replace with function body.
