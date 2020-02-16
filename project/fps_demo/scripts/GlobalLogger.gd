extends Node
"""
	Logger Singleton Class Script
	Provides functions for logging of various levels of message
"""

enum LEVELS {INFO, WARNING, ERROR}

var log_level: int = LEVELS.INFO # Lowest level that should be logged

var enabled: bool = true # Log anything at all?

signal info_logged(message)
signal warning_logged(message)
signal error_logged(message)

func info(emitter: Object, message: String) -> void:
	if enabled and log_level <= LEVELS.INFO:
		var frame = get_stack()[1]
		var function:String = "%30s:%30s:%-4d" % [frame.source.get_file(), frame.function, frame.line]
		_log_message(LEVELS.INFO, emitter, function, message)


func warning(emitter: Object, message: String) -> void:
	if enabled and log_level <= LEVELS.WARNING:
		var frame = get_stack()[1]
		var function:String = "%30s:%30s:%-4d" % [frame.source.get_file(), frame.function, frame.line]
		_log_message(LEVELS.WARNING, emitter, function, message)


func error(emitter: Object, message: String) -> void:
	if enabled and log_level <= LEVELS.ERROR:
		var frame = get_stack()[1]
		var function:String = "%30s:%30s:%-4d" % [frame.source.get_file(), frame.function, frame.line]
		_log_message(LEVELS.ERROR, emitter, function, message)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta) -> void:
#	pass

func _get_time_string() -> String:
	var datetime: Dictionary = OS.get_datetime(true)
	var s: String = ""
	# TODO: Use format strings for vertical alignment.
	s += str(datetime.year, "-")
	s += str(datetime.month, "-")
	s += str(datetime.day, "-")
	s += str(datetime.hour, "-")
	s += str(datetime.minute, "-")
	s += str(datetime.second)
	return s

func _log_message(level: int, emitter: Object, function: String, message: String) -> void:
	var log_string: String = ""
	
	log_string += _get_time_string()
	log_string += " - "
	
	# Message level.
	match level:
		LEVELS.INFO:
			log_string += "INFO: "
		LEVELS.WARNING:
			log_string += "WARNING: "
		LEVELS.ERROR:
			log_string += "ERROR: "
	
	# Emitter Name if any.
	if emitter.has_method("get_name"):
		log_string += emitter.name
		log_string += " - "
	
	# Emitter object ID.
	log_string += str(emitter)
	log_string += " - "
	
	# Script Path.
	log_string += emitter.get_script().get_path().get_file()
	log_string += " - "
	
	# Function Name
	log_string += function
	log_string += " - "
	
	# Message
	log_string += message
	
	if not log_string.ends_with("."):
		log_string += "."
	
	match level:
		LEVELS.INFO:
			emit_signal("info_logged", log_string)
		LEVELS.WARNING:
			emit_signal("warning_logged", log_string)
		LEVELS.ERROR:
			emit_signal("error_logged", log_string)
	
	
	#if log_to_disk and _can_log_to_disk:
	#	_log_to_disk(log_string)
	print(log_string)
