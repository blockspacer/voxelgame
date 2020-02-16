extends Node

var INPUT_ACTIONS : Array = []

var config_section = "input_map"

export(Array, String) var modifiable_action_names \
	= [
		"move_left", 
		"move_right", 
		"move_forward",
		"move_backward"
		#"move_up",
		#"move_down"
	]
	
func _ready() -> void:
	GlobalLogger.info(self, "input mapping ready")
	update_input_settings()
	#load_config()

# TODO: INDEV
func load_from_config() -> void:
	GlobalLogger.info(self, "loading input mapping from config")
	for actions in InputMap.get_actions():
		if actions is InputEventKey:
			INPUT_ACTIONS.append(actions)
	if settings.get_setting(config_section, 'test') == null:
		for action_name in INPUT_ACTIONS:
			var action_list = InputMap.get_action_list(action_name)
			# There could be multiple actions in the list, but we save the first one by default
			var scancode = OS.get_scancode_string(action_list[0].scancode)
			map_key_input(config_section, action_name, scancode)
			#settings.set_setting(config_section, action_name, scancode)
			#settings.save_settings_file()
	else: # ConfigFile was properly loaded, initialize InputMap
		for action_name in INPUT_ACTIONS:
			# Get the key scancode corresponding to the saved human-readable string
			var scancode = settings.get_setting(config_section, action_name)
			# Create a new event object based on the saved scancode
			var event = InputEventKey.new()
			event.scancode = scancode
			# Replace old action (key) events by the new one
			for old_event in InputMap.get_action_list(action_name):
				if old_event is InputEventKey:
					InputMap.action_erase_event(action_name, old_event)
			InputMap.action_add_event(action_name, event)

func save_to_config_file(section: String, key: String, value: int) -> void:
	"""Helper function to redefine a parameter in the settings file"""
	map_key_input(section, key, value)
	settings.save_settings_file()

func erase_action_events(action_name):
	var input_events = InputMap.get_action_list(action_name)
	for event in input_events:
		InputMap.action_erase_event(action_name, event)

# TODO: support not only InputEventKey
# TODO: support multiple InputEventKey per action
func map_key_input(section: String, key : String, scancode:int) -> void:
	if InputMapping.modifiable_action_names.find(str(key)) == -1:
		return
	#
	var Event = InputEventKey.new()
	Event.scancode = scancode
	erase_action_events(str(key))
	#var action_list = InputMap.get_action_list(str(key))[0]
	#InputMap.action_erase_event (str(key), action_list)
	InputMap.action_add_event (str(key), Event)
	settings.set_setting(section, str(key), str(scancode))
	#print("map_key_input: ", str(key), " to ", str(scancode))

func update_input_settings() -> void:
	for action in InputMap.get_actions():
		for member in InputMap.get_action_list(action):
			if member is InputEventKey:
					map_key_input(config_section, action, member.scancode)
					#print("set_setting: input", action, InputMap.get_action_list(action)[member].scancode)
					#save_to_config_file("input", action, InputMap.get_action_list(action)[member].scancode)
