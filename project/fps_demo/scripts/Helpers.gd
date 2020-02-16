extends Node

var run_time = 0 setget ,get_run_time
var debug_mode = false setget _private_set,get_debug

func _private_set(__throwaway__):
	if debug_mode:
		GlobalLogger.info(self, \
			'Private variable.')

func _process(delta):
	run_time += delta
	
func get_run_time():
	return run_time

func get_debug():
	return debug_mode

func set_debug(value : bool):
	debug_mode = value

func reparent(target, new_parent):
	DebUtil.debCheck(target != null, "logic error")
	DebUtil.debCheck(new_parent != null, "logic error")
	if target.get_parent() != null: 
		target.get_parent().remove_child(target)
	new_parent.add_child(target)

func getKeyFromAction(action):
	var r = ""

	#var actions:Array = InputMap.get_actions()
	
	for a in InputMap.get_action_list(action):
		r += OS.get_scancode_string(a.scancode)

	return r

func get_datetime_string():
	var datestamp	= OS.get_datetime()
	var hour		= str( datestamp.hour )
	if hour.length() < 2:
		hour = "0" + hour
	var minute		= str( datestamp.minute )
	if minute.length() < 2:
		minute = "0" + minute
	var second		= str( datestamp.second )
	if second.length() < 2:
		second = "0" + second
	var day			= str( datestamp.day )
	if day.length() < 2:
		day = "0" + day
	var month		= str( datestamp.month )
	if month.length() < 2:
		month = "0" + month
	var year		= str( datestamp.year )
	return hour + minute + second + "_" + day + month + year

func get_time_string(value): # get the time cost in a string
	var time = get_months(value)
	if time > 11:
		time = get_years(value)
		if time == 1:
			return String(time) + " year"
		else:
			return String(time) + " years"
	else:
		if time == 1:
			return String(time) + " month"
		else:
			return String(time) + " months"
			
func save_memory_dump_to_dir(dir):
	var path = dir + "/mem_" + get_datetime_string() + ".txt" 
	OS.dump_memory_to_file(path)
	GlobalLogger.info(self, \
		"dump_memory_to_file: saved to path " + path)

func save_res_dump_to_dir(dir):
	var path = dir + "/res_" + get_datetime_string() + ".txt"
	OS.dump_resources_to_file(path)
	GlobalLogger.info(self, \
		"dump_resources_to_file: saved to path " + path)

# TODO: compare with Engine.get_frames_per_second()
func fps_to_str():
	# Update infolabel
	var s = str(Performance.get_monitor(Performance.TIME_FPS))
	return s
	
func camera_pos_to_str():
	DebUtil.debCheck(get_viewport(), "logic error")
	DebUtil.debCheck(get_viewport().get_camera(), "logic error")
	var pos = get_viewport().get_camera().global_transform.origin
	var s = str("X: %.1f" % pos.x, "\n")
	s = str(s, "Y: %.1f" % pos.y, "\n")
	s = str(s, "Z: %.1f" % pos.z, "\n")
	return s

func print_client_info():
	var local_time = OS.get_time(false)
	var utc_time = OS.get_time(true)

	GlobalLogger.info(self, \
		"================================================================================")
	GlobalLogger.info(self, "")
	GlobalLogger.info(self, \
		GameGlobals.get_key_value(GameGlobals.GAME_GLOBALS.GAME_WINDOW_TITLE))
	GlobalLogger.info(self, "")
	GlobalLogger.info(self, \
		" Version:    \t%s" % GameGlobals.get_key_value(GameGlobals.GAME_GLOBALS.GAME_VERSION))
	GlobalLogger.info(self, \
		" Platform:   \t%s" % OS.get_name())
	GlobalLogger.info(self, \
		" Locale:     \t%s" % OS.get_locale())
	GlobalLogger.info(self, \
		" Process id: \t%s" % OS.get_process_id())
	GlobalLogger.info(self, \
		" Local time: \t%s" % self.format_time(local_time))
	GlobalLogger.info(self, \
		" UTC time:   \t%s" % self.format_time(utc_time))
	GlobalLogger.info(self, \
		" Exec path:  \t%s" % OS.get_executable_path())
	GlobalLogger.info(self, \
		" User path:  \t%s" % OS.get_user_data_dir())
	GlobalLogger.info(self, \
		" Debug build:\t%s" % OS.is_debug_build())
	GlobalLogger.info(self, "")
	GlobalLogger.info(self, "================================================================================")
	GlobalLogger.info(self, "")

# Prints text with an UTC time prefix
func log_utc(text):
	var utc_time = OS.get_time(true)
	GlobalLogger.info(self, \
		" %s\t%s" % [self.format_time(utc_time), text])

func format_time(time):
	return "%s:%s:%s" % [
		str(time.hour).pad_zeros(2),
		str(time.minute).pad_zeros(2),
		str(time.second).pad_zeros(2)
	]
	
func _init():
	pass # Replace with function body.
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

###
# Various helper functions
###

# Filter an array by a funcref.
func array_filter(arr, function):
	var ret = []
	for ent in arr:
		if function.call_func(ent) == true:
			ret.push_back(ent)
	return ret

# Find an array item by a funcref
func array_find(arr, function):
	for ent in arr:
		if function.call_func(ent) == true:
			return ent
	return null

func get_months(value): # convert to months
	return value / 10

func get_years(value): # convert to years
	return value / 120

# Get the node's original name before Godot made it unique.
func get_node_original_name(node):
	var node_name_array = node.name.split('@')
	return node_name_array[1] if node_name_array.size() > 1 else node_name_array[0]
	
func randfl(minimum, maximum):
	randomize()
	return randf() * (maximum - minimum) + minimum

func rand(minimum, maximum = null):
	randomize()
	if maximum == null:
		maximum = minimum
		minimum = 0
	return floor(randf() * (maximum - minimum + 1)) + minimum

func randOneIn(maximum = 2):
	return rand(0, maximum) == 0

func randOneFrom(items):
	return items[rand(items.size() - 1)]
	
func filter(list: Array, matches_criteria: FuncRef) -> Array:
	# Usually better to add filtered elements to new array
	# because removing elements while iterating over a list
	# causes weird behaviour
	var filtered: Array = []
	for element in list:
		if matches_criteria.call_func(element):
			filtered.append(element)
	return filtered
