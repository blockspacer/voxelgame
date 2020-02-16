# Based on Console for "The Lost Forest Project"
# ------------------------
# Implements game console.
#
# ------------------------
# Author : Dmitry "Vortex" Koteroff (edited by mintyleaf)
# Email  : krakean@outlook.com      (mintyleafdev@gmail.com)
# Date   : 29.09.2019

extends CanvasLayer

onready var console_box      = $ConsoleBox
onready var console_text     = $ConsoleBox/Container/ConsoleControl/ConsoleText
onready var console_line     = $ConsoleBox/Container/LineEdit
onready var animation_player = $ConsoleBox/AnimationPlayer

# Those are the scripts containing command and cvar code
var cmd_history          = []
var cmd_history_count    = 0
var cmd_history_up       = 0

# For tabbing commands
var entered_letters        = ""
var prev_entered_letters   = ""
var text_changed_by_player = true # text_changed_by_player needs for not changing other vals by signal "text_changed"
var is_tab_pressed         = false
var a_variant_idx          = 0

# For LogErr/LogWarn DebugOSD label
var console_warnerr_label_id = "console_warnerr_label"
var err_count  = 0
var warn_count = 0

# All recognized commands
var commands = {}

# All recognized cvars
var cvars    = {}

# Used for variable type detection
var builtin_type_names = ["nil", "bool", "int", "float", "string", "vector2", "rect2", "vector3", "maxtrix32", "plane", "quat", "aabb",  "matrix3", "transform", "color", "image", "nodepath", "rid", null, "inputevent", "dictionary", "array", "rawarray", "intarray", "realarray", "stringarray", "vector2array", "vector3array", "colorarray", "unknown"]

# Used in Log***
const COLOR_LOG_WARNING        = "#FFD56F"
const COLOR_LOG_ERROR          = "#E84D58"
# Used in messageColoredErr and in handle_command
const COLOR_MSG_ERR            = "#E84D58"
const COLOR_MSG_ERR_VAR_NAME   = "#EA92DC"
# Used in messageColoredCmdDesc
const COLOR_MSG_CMD_DESC       = "#FFD56F"
const COLOR_MSG_CMD_DESC_USAGE = "#5CCBE3"
# Used in describe_cvars
const COLOR_MSG_CVAR_DESC_CVAR   = "#9ABC65"
const COLOR_MSG_CVAR_DESC_VALUE  = "#9999ff"
const COLOR_MSG_CVAR_DESC_DEFVAL = "#EA92DC"
const COLOR_MSG_CVAR_DESC_ALLVAL = "#ffaefa"

# BUILT-IN CONSOLE COMMANDS START #

# Lists all available commands
func cmdlist():
	var cnt = 0
	for command in commands:
		cnt += 1
		_describe_command(command)
		
		# Separate visually built-in commands
		if cnt == 5:
			message('------')
	message("Use " + Helpers.getKeyFromAction("console_toggle") + " to access this nice console.")

# Enumerate history content and return it.
func history():
	var strOut = ""
	var count  = 0
	for i in range(0, cmd_history.size()-1):
		if (i == cmd_history.size()-2):
			strOut += "[color=#ffff66]" + str(count+1) + ".[/color] " + cmd_history[i]
		else:
			strOut += "[color=#ffff66]" + str(count+1) + ".[/color] " + cmd_history[i] + "\n"
		count+=1
	
	message(strOut)

func fps():
	message(Helpers.fps_to_str())
	
func version():
	message(GameGlobals.get_key_value(GameGlobals.GAME_GLOBALS.GAME_VERSION))
	
func cam_pos():
	message(Helpers.camera_pos_to_str())
	
# Lists all available cvars
func cvarlist():
	for cvar in cvars:
		_describe_cvar(cvar)

# Clear the console window
func clear():
	console_text.set_bbcode("")

# Exits the application
func quit():
	get_tree().quit()
	
# BUILT-IN CONSOLE COMMANDS END #

func _init():	
	GlobalLogger.info(self, \
		"Console initialization")
	#
	if not OS.is_debug_build():
		return
	#	
	GameGlobals.set_console(self)
		
# Console initialization.	
func _ready():
	GlobalLogger.info(self, \
		"Console ready")
	#
	if not OS.is_debug_build():
		return
	#
	#var current_root = get_tree().get_root()
	#var current_root = get_tree().get_current_scene()
	#Helpers.reparent(self, current_root)
	#
	# Allow selecting console text
	console_text.set_selection_enabled(true)
	# Follow console output (for scrolling)
	console_text.set_scroll_follow(true)
	
	# Transparency settings
	console_box.self_modulate  = Color(1, 1, 1, 0.87) # whole console transparency (container + consoletext + consoleline)
	console_line.self_modulate = Color(1, 1, 1, 1)    # transparency for console line
	
	animation_player.connect("animation_finished", self, "_on_AnimationPlayer_finished")
	console_line.connect("text_entered", self, "_on_LineEdit_text_entered")
	console_line.connect("text_changed", self, "_on_LineEdit_text_changed")
	
	animation_player.set_current_animation("fade")
	# Hide console on start
	#_set_console_opened(true)
	#console_box.hide()
	
	# By default we show quick help
	#var engiversion     = Engine.get_version_info()
#	var gameversion     = Engine.get_game_version_info()
	#var placeholder = "%s v%d.%d.%d-%s (%s) (using Godot v%s.%s.%s.%s-%s)\nType [color=#FFD56F]cmdlist[/color] to get a list of all available commands\n[color=#9ABC65]===========[/color]"
#	var outstr      = placeholder % [ProjectSettings.get_setting("application/config/name"), gameversion.major, gameversion.minor, gameversion.patch, gameversion.hash, gameversion.status, str(engiversion.major), str(engiversion.minor), str(engiversion.patch), engiversion.status, engiversion.hash]
#	message(outstr)

	# Register built-in commands
		
	register_command("cmdlist", {
		# used when printing help for a command.
		desc        = "Lists all available commands",
		# first one - actual count of arguments (used by parser), second one - used when printing help for a command, so you can write here anything - arguments name or type or some hints...
		args        = [0, ""],
		# Target script to bind a corresponding function call
		target      = self
	})
	
	register_command("cvarlist", {
		desc        = "Lists all available cvars",
		args        = [0, ""],
		target      = self
	})
	
	register_command("quit", {
		desc        = "Exits the application",
		args        = [0, ""],
		target      = self
	})
	
	register_command("version", {
		desc        = "Print app version",
		args        = [0, ""],
		target      = self
	})
	
	register_command("fps", {
		desc        = "Print fps",
		args        = [0, ""],
		target      = self
	})
	
	register_command("cam_pos", {
		desc        = "Print camera position",
		args        = [0, ""],
		target      = self
	})

	register_command("clear", {
		desc        = "Clear the console window",
		args        = [0, ""],
		target      = self
	})
	
	register_command("history", {
		desc        = "Print all previous cmd used during the session",
		args        = [0, ""],
		target      = self
	})
	
	set_process_input(true)
	
# Process keyboard input.
func _input(event):
	# Show/hide console.
	if Input.is_action_just_pressed("console_toggle"):
		# Remove the "~" from line edit on console appear.
		console_line.accept_event()

		var opened = _is_console_opened()
		if opened == 1:
			_set_console_opened(false)
		elif opened == 0:
			_set_console_opened(true)
			
	# Console input history up (oldest)
	elif Input.is_action_just_pressed("console_up"):
		if (cmd_history_up > 0 and cmd_history_up <= cmd_history.size()):
			cmd_history_up -= 1
			_set_linetext(cmd_history[cmd_history_up])
			
	# Console input history down (recent)
	elif Input.is_action_just_pressed("console_down"):
		if (cmd_history_up > -1 and cmd_history_up + 1 < cmd_history.size()):
			cmd_history_up += 1
			_set_linetext(cmd_history[cmd_history_up])
		elif (cmd_history_up > -1 and cmd_history_up + 1 == cmd_history.size()):
			cmd_history_up +=1
			_set_linetext(entered_letters)
		# no more recent, hide last recent and show empty console input line.
		else:
			cmd_history_up = cmd_history.size(); # allows easily go back to most recent by pressing Key Up.
			console_line.set_text("")
			console_line.grab_focus()
			
	# Console scroll up
	elif Input.is_action_just_pressed("console_scroll_up"):
		var vscrl = console_text.get_v_scroll();
		var linesbackward = vscrl.get_value() - vscrl.get_page() * 0.5 / 1
		vscrl.set_value(linesbackward)
		
	# Console scroll down
	elif Input.is_action_just_pressed("console_scroll_down"):
		var vscrl = console_text.get_v_scroll();
		var linesforward = vscrl.get_value() + vscrl.get_page() * 0.5 / 1
		vscrl.set_value(linesforward)
		
	# Scroll to beginning of Console quickly
	elif Input.is_action_pressed("console_scroll_to_begin"):
		console_text.scroll_to_line(0)
	
	# Scroll to end of Console quickly
	elif Input.is_action_pressed("console_scroll_to_end"):
		console_text.scroll_to_line(console_text.get_line_count()-1)
	
	# Clear Console hotkey
	elif Input.is_action_pressed("console_clear"):
		clear()

	# Handle auto-completion by Tab-key.
	if is_tab_pressed:
		is_tab_pressed = Input.is_key_pressed(KEY_TAB)
	if console_line.has_focus() and Input.is_key_pressed(KEY_TAB) and not is_tab_pressed:
		_complete()
		is_tab_pressed = true
		
	# Transfer focus to console line edit when any key pressed on console text when its focused
	if event.is_pressed() and not Input.is_key_pressed(KEY_CONTROL) and not Input.is_key_pressed(KEY_ALT) and not Input.is_key_pressed(KEY_SHIFT) and console_text.has_focus():
		console_line.grab_focus()
			
# This signal handles the hiding of the console at the end of the fade-out animation
func _on_AnimationPlayer_finished(_anim):
	if _is_console_opened():
		console_box.hide()
		
# Called when the user presses Enter in the console
func _on_LineEdit_text_entered(text):
	# used to manage cmd history
	if cmd_history.size() > 0:
		if (text != cmd_history[cmd_history_count - 1]):
			cmd_history.append(text)
			cmd_history_count+=1
	else:
		cmd_history.append(text)
		cmd_history_count+=1
	cmd_history_up = cmd_history_count
	var text_splitted = text.split(" ", true)
	# Don't do anything if the LineEdit contains only spaces
	if not text.empty() and text_splitted[0]:
		handle_command(text)
		
		# Clear input field and scroll to console end
		console_line.clear()
		console_text.scroll_to_line(console_text.get_line_count()-1)
	else:
		# Clear the LineEdit but do nothing
		console_line.clear()
		
# Called when user change text
func _on_LineEdit_text_changed(text):
	if text_changed_by_player:
		var txt = text
		
		# We do specific, for those who has Russian keyboard, thing here:
		# if you trying to write english word, but accidently have turned on cyrilic keyboard layout,
		# then we will automatically replace cyrilic letters to their english layout counterparts.
		var txt_words = txt.split(" ", true)
		if !txt.empty() and txt_words.size() == 1:
			txt = _swap_letters_ru_to_en(txt)
			console_line.set_editable(false)
			_set_linetext(txt)
			console_line.set_editable(true)
			
		entered_letters = txt
		
# Is the console fully opened?
func _is_console_opened():
	if animation_player.get_current_animation_position() == animation_player.get_current_animation_length():
		return 1
	elif animation_player.get_current_animation_position() == 0:
		return 0
	else:
		return 2
		
# Mirroring cyrilic letters to their english counterparts
func _swap_letters_ru_to_en(text):
	var letters = { 'а' : 'f',
		'в' : 'd',
		'г' : 'u',
		'д'  : 'l',
		'е'  : 't',
		'ж'  : ';',
		'з'  : 'p',
		'и'  : 'b',
		'й'  : 'q',
		'к'  : 'r',
		'л'  : 'k',
		'м'  : 'v',
		'н'  : 'y',
		'о'  : 'j',
		'п'  : 'g',
		'р'  : 'h',
		'с'  : 'c',
		'т'  : 'n',
		'у'  : 'e',
		'ф'  : 'a',
		'ц'  : 'w',
		'ч'  : 'x',
		'ш'  : 'i',
		'щ'  : 'o',
		'ы'  : 's',
		'ь'  : 'm',
		'я'  : 'z',
		}
	
	for i in range(0, text.length()):
		if letters.has(text[i]):
			text[i] = letters[text[i]]
	return text
	
# Open or close console.
func _set_console_opened(opened):
	# Close the console
	if opened == true:
		animation_player.play("fade")
		# Signal handles the hiding at the end of the animation
		yield($ConsoleBox/AnimationPlayer, "animation_finished")
		console_box.hide()
		console_line.clear()
	# Open the console
	elif opened == false:
		animation_player.play_backwards("fade")
		console_box.show()
		console_line.grab_focus()
		console_line.clear()
		
# Convert allowed values from dictionary to comma-separated string		
func _allowed_values_to_str(allowed_values):
	var av = "any"
	if (allowed_values.size() > 0):
		av = str(allowed_values[0])
		for idx in range(1, allowed_values.size()):
			av = av + ", " + str(allowed_values[idx])
			
	return av
	
# Convert milliseconds to hours/minutes/seconds/ms
func _make_time_using_ms(ms):
	var time = { hours = 0, minutes = 0, seconds = 0, msec = 0 }
	
	time.seconds   = (ms / 1000) % 60
	time.minutes   = ((ms / (1000 * 60)) % 60)
	time.hours     = ((ms / (1000 * 60 * 60)) % 24)
	time.msec      = ms
		
	return time
	
# Used to ensure that given value for console variable is correct
const _patterns = {
	# bool
	'1': '^(1|0|true|false|TRUE|FALSE|True|False)$',
	# int
	'2': '^[+-]?([0-9]*)?$',
	# float
	'3': '^[+-]?([0-9]*[\\.\\,]?[0-9]+|[0-9]+[\\.\\,]?[0-9]*)([eE][+-]?[0-9]+)?$'
}
# Used as cache	
var _compiled = {}

# Ensure that value is correct
func _check_value_by_type(variable_type):
	var str_type  = variable_type
	if (str_type > 3):
		return FAILED

	if !_compiled.has(str_type):
		var r = RegEx.new()
		r.compile(_patterns[str(str_type)])

		if r and r is RegEx:
			_compiled[str_type] = r
		else:
			return FAILED

	return _compiled[str_type]

# Is a given value within allowed range of values?
func _value_within_allowed(val, allowed_values):
	for i in range(0, allowed_values.size()):
		if str(allowed_values[i]) == str(val):
			return true
			
	return false
	
# Set console line text	
func _set_linetext(string):
	text_changed_by_player = false
	console_line.set_text(string)
	text_changed_by_player = true

	console_line.caret_position = console_line.text.length() + 1
	console_line.grab_focus()
	console_line.accept_event()
	

func _get_command_args(command, idx):
	if command in commands:
		if (commands[command].has("completer_method") and
			commands[command].has("completer_target")):
			return commands[command]["completer_target"].call(
				commands[command]["completer_method"], idx)
	return []

# Command/cvar completion (by Tab, for example)
func _complete():
	var split = entered_letters.split(" ")
	split.invert()
	for _i in range(split.size()):
		if split.size() > 1:
			if split[0] == "" and split[1] == "":
				split.remove(0)
				entered_letters = entered_letters.left(entered_letters.length() - 1)
	split.invert()
	_set_linetext(entered_letters)
	var command_idx = split.size() - 1
	var a_variants  = []
	if prev_entered_letters != entered_letters:
		prev_entered_letters = entered_letters
		a_variant_idx = 0
	
	if command_idx < 1: # autocomplete command
		for command in commands:
			if command.begins_with(entered_letters):
				a_variants.append(command)
		
		if a_variants.size() > 0:
			_set_linetext(a_variants[a_variant_idx])
			a_variant_idx += 1
			if a_variant_idx > a_variants.size() - 1:
				a_variant_idx = 0
		
	else:
		var args = _get_command_args(split[0], command_idx - 1)
		for arg in args:
			if arg.begins_with(split[command_idx]):
				a_variants.append(arg)
		
		if a_variants.size() > 0:
			entered_letters = ""
			for i in range(command_idx):
				entered_letters += split[i] + " "
			_set_linetext(entered_letters + a_variants[a_variant_idx])
			a_variant_idx += 1
			if a_variant_idx > a_variants.size() - 1:
				a_variant_idx = 0

# Prints message to console
func message(bbcode, print_time = false):
	var time = "";
	if (print_time == true):
		var ms = OS.get_ticks_msec()
		var t = _make_time_using_ms(ms)
		var placeholder = "[%02d:%02d:%02d] "
		time = placeholder % [t.hours, t.minutes, t.seconds]
	console_text.set_bbcode(console_text.get_bbcode() + time + bbcode + "\n")
		
# Colorized error message, like: cannot register ... param name ... (error desc)
func messageColoredErr(msg_error_general, msg_error_param = "", msg_error_desc = ""):
	if (msg_error_param == "" and msg_error_desc == ""):
		message("[i][color=" + COLOR_MSG_ERR + "]" + msg_error_general + "[/color][/i]")
	elif (msg_error_desc == ""):
		message("[i][color=" + COLOR_MSG_ERR + "]" + msg_error_general + "[/color][/i] [u][color=" + COLOR_MSG_ERR_VAR_NAME + "]" + msg_error_param + "[/color][/u]")
	else:
		message("[i][color=" + COLOR_MSG_ERR + "]" + msg_error_general + "[/color][/i] [u][color=" + COLOR_MSG_ERR_VAR_NAME + "]" + msg_error_param + "[/color][/u] (" + msg_error_desc + ")")
	
# Colorized console cmd description
func messageColoredCmdDesc(msg_cmd, msg_cmd_desc, msg_cmd_desc_usage):
	message("[color=" + COLOR_MSG_CMD_DESC + "]" + msg_cmd + ":[/color] " + msg_cmd_desc + " (usage: [color=" + COLOR_MSG_CMD_DESC_USAGE + "]" + msg_cmd_desc_usage + "[/color])")
	
func Log(bbcode):
	message(bbcode, true)
	
func LogWarn(bbcode):
	message("[color=" + COLOR_LOG_WARNING + "]" + bbcode + "[/color]", true)
	warn_count += 1
		
	#var placeholder = "Warnings: [color=%s]%d[/color], Errors: [color=%s]%d[/color]. See console for details"
	#var outstr      = placeholder % [COLOR_LOG_WARNING, warn_count, COLOR_LOG_ERROR, err_count]
		
#	# First warning, so add message
#	if (warn_count == 1):
#		DebugOSD.add_ex(outstr, Vector2(0, 5), console_warnerr_label_id)
#	# Then we have to update message
#	else:
#		DebugOSD.update_ex(console_warnerr_label_id, outstr)
	
func LogErr(bbcode, _ignore_debugosd = false):
	message("[color=" + COLOR_LOG_ERROR + "]" + bbcode + "[/color]", true)
	err_count += 1
	
#	if ignore_debugosd:
#		return
#
#	var placeholder = "Warnings: [color=%s]%d[/color], Errors: [color=%s]%d[/color]. See console for details"
#	var outstr      = placeholder % [COLOR_LOG_WARNING, warn_count, COLOR_LOG_ERROR, err_count]
		
#	# First warning, so add message
#	if (err_count == 1):
#		DebugOSD.add_ex(outstr, Vector2(0, 5), console_warnerr_label_id)
#	# Then we have to update message
#	else:
#		DebugOSD.update_ex(console_warnerr_label_id, outstr)
		
# Registers a new console command
func register_command(cmd_name, args):
	if args.has("target") and args.target != null and args.has("desc") and args.has("args"):
		if args.target.has_method(cmd_name):
			commands[cmd_name] = args
		else:
			messageColoredErr("Cannot register command:", cmd_name, "the target script has no corresponding function")
	else:
		messageColoredErr("Cannot register command:", cmd_name, "wrong arguments")

# Registers a new cvar (console variable)
func register_cvar(cmd_name, args):
	if args.has("target") and args.target != null and args.has("desc") and args.has("type"):
		if (args.type != TYPE_STRING and args.type != TYPE_INT and args.type != TYPE_REAL and args.type != TYPE_BOOL):
			messageColoredErr("Cannot register cvar:", cmd_name, "wrong cvar type: [u]" + builtin_type_names[args.type] + "[/u], expected: int, float, string or boolean")
			return
		
		var hasMMVals = args.has("minmax_values") and args.minmax_values.size() > 0
		var hasALVals = args.has("allowed_values") and args.allowed_values.size() > 0
		if args.type == TYPE_INT or args.type == TYPE_REAL:
			if (not hasMMVals and not hasALVals) or (hasMMVals and hasALVals):
				messageColoredErr("Cannot register cvar:", cmd_name, "the integer/float parameters should have either minmax_values or allowed_values argument, nor none nor both")
				return

		var firstvalue = args.target.get(cmd_name)
		if firstvalue != null:
			# Check whether default value is within allowed/minmax values range, if not then enforce a programmer to fix this possible issue.
			if (hasALVals):
				if not _value_within_allowed(firstvalue, args.allowed_values):
					messageColoredErr("Cannot register cvar:", cmd_name, "default value and allowed values mismatch")
					return
			elif (hasMMVals):
				if (firstvalue < args.minmax_values[0] or firstvalue > args.minmax_values[1]):
					messageColoredErr("Cannot register cvar:", cmd_name, "default value and minmax values mismatch")
					return
			
			args.default_value = firstvalue
			cvars[cmd_name] = args
		else:
			messageColoredErr("Cannot register cvar:", cmd_name, "the target script has no getter and/or setter function")
	else:
		messageColoredErr("Cannot register command:", cmd_name, "wrong arguments")

# Describes a command, used by the "cmdlist" command and when the user enters a command name without any arguments (if it requires at least 1 argument)
func _describe_command(cmd):
	var command     = commands[cmd]
	var description = command.desc
	var args        = command.args
	
	if args.size() >= 1 and args[0] >= 1:
		messageColoredCmdDesc(cmd, description, cmd + " " + args[1])
	else:
		messageColoredCmdDesc(cmd, description, cmd)

# Describes a cvar, used by the "cvarlist" command and when the user enters a cvar name without any arguments
func _describe_cvar(cvar):
	var cvariable      = cvars[cvar]
	var description    = cvariable.desc
	var type           = cvariable.type
	var default_value  = cvariable.default_value
	var value          = cvariable.target.get(cvar)
	var allowed_values = []
	if cvariable.has("allowed_values"):
		allowed_values = cvariable.allowed_values

	# Gather allowed values.	
	var av = _allowed_values_to_str(allowed_values)
			
	# Setup output string template + colors
	var colors_scheme = {
		"CVAR"   : COLOR_MSG_CVAR_DESC_CVAR,
		"VALUE"  : COLOR_MSG_CVAR_DESC_VALUE,
		"DEFVAL" : COLOR_MSG_CVAR_DESC_DEFVAL,
		"ALLVAL" : COLOR_MSG_CVAR_DESC_ALLVAL,
	}

	var placeholder = "[color=%s]%s:[/color] [color=%s]%s[/color] %s ([u]%s[/u], [i]default:[/i] [color=%s]%s[/color], [i]allowed values:[/i] [color=%s]%s[/color])"
	var outstr = ""
	
	# Now, depending on type, show proper cvar description.
	if (type == TYPE_STRING || type == TYPE_BOOL):
		if (type == TYPE_BOOL):
			av = "true..false"
			outstr = placeholder % [colors_scheme["CVAR"], str(cvar), colors_scheme["VALUE"], str(value).to_lower(), str(description), builtin_type_names[type], colors_scheme["DEFVAL"], str(default_value).to_lower(), colors_scheme["ALLVAL"], str(av)]
		else:
			outstr = placeholder % [colors_scheme["CVAR"], str(cvar), colors_scheme["VALUE"], str(value), str(description), builtin_type_names[type], colors_scheme["DEFVAL"], str(default_value), colors_scheme["ALLVAL"], str(av)]
	elif (type == TYPE_INT || type == TYPE_REAL):
		if (av != "any"):
			outstr = placeholder % [colors_scheme["CVAR"], str(cvar), colors_scheme["VALUE"], str(value), str(description), builtin_type_names[type], colors_scheme["DEFVAL"], str(default_value), colors_scheme["ALLVAL"], str(av)]
		else:
			av = str(cvariable.minmax_values[0]) + ".." + str(cvariable.minmax_values[1])
			outstr = placeholder % [colors_scheme["CVAR"], str(cvar), colors_scheme["VALUE"], str(value), str(description), builtin_type_names[type], colors_scheme["DEFVAL"], str(default_value), colors_scheme["ALLVAL"], str(av)]
	
	# Output formatted string to console.
	message(outstr)

# Process the console command.
func handle_command(text):
	# The current console text, splitted by spaces (for arguments)
	var cmd = text.split(" ", true)
	message("[b]> " + text + "[/b]")
	
	# Remove empty args that produced by split in case when empty space between [ccom/cvar] and [arg]
	var cmd_clean = []
	var cmd_temp  = range(cmd.size())
	if cmd.size() > 1:
		for i in range(cmd.size()):
			if not cmd[i].empty():
				cmd_clean.append(cmd[cmd_temp[i]])
				
		cmd = cmd_clean

	# Check if the first word is a valid command
	if commands.has(cmd[0]):
		var command = commands[cmd[0]]

		# If no argument is supplied, then show command description and usage, but only if command has at least 1 argument required
#		if (cmd.size() == 1) and command.args.size() >= 1 and command.args[0] >= 1:
#			_describe_command(cmd[0])
#		else:
		if command.args.size() == 0 or command.args[0] == 0: # If there are no arguments, don't pass any to the other script.
			command.target.call(cmd[0].replace(".", ""))
		else:
			var args = []
			# Major flaw of this approach: no type checking for given command arguments
			for i in range(1, cmd.size()):
				args.append(cmd[i])
				
#				if args.size() != int(command.args[0]):
#					messageColoredErr("Console command got incorrect amount of arguments:", str(args.size()), "expected: " + str(command.args[0]))
#				else:
			command.target.callv(cmd[0].replace(".", ""), args)
				
	# Check if the first word is a valid cvar
	elif cvars.has(cmd[0]):
		var cvar = cvars[cmd[0]]
		
		# If no argument is supplied, then show cvar description and usage
		if cmd.size() == 1:
			_describe_cvar(cmd[0])
		else:
			var value_passed     = false
			var baserematch      = null
			var rematch          = null
		
			var _bad_allowed_vals = false
			var _bad_minmax_vals  = false
			
			# We do not support regex for strings since they can contain anything
			if (cvar.type != TYPE_STRING):
				baserematch      = _check_value_by_type(cvar.type)
				rematch          = baserematch.search(cmd[1])
			var val              = ""
			
			# String cvar
			if cvar.type == TYPE_STRING:
				val = str(cmd[1])
			
				# Check whether given value is contains at least one of allowed_values.
				if cvar.has("allowed_values") and cvar.allowed_values.size() > 0:
					_bad_allowed_vals = true
					if _value_within_allowed(val, cvar.allowed_values):
						value_passed     = true
						_bad_allowed_vals = false
				else:
					value_passed = true
				
				if value_passed:
					for word in range(1, cmd.size()):
						if word == 1:
							cvar.value = str(cmd[word])
						else:
							cvar.value += str(" " + cmd[word])
					
			# Integer cvar
			elif cvar.type == TYPE_INT:
				if not rematch or !(rematch is RegExMatch):
					messageColoredErr("CVar got value of incorrect type while expecting [u]integer[/u]")
					return
					
				val = int(rematch.get_string())
				
				# If no allowed_values given, make sure given value is within min/max value range
				if not cvar.has("allowed_values") or cvar.allowed_values.size() == 0:
					# Is it within range?
					if (val < int(cvar.minmax_values[0]) or val > int(cvar.minmax_values[1])):
						_bad_minmax_vals = true
					else:
						value_passed    = true
						
					if value_passed:
						cvar.value = clamp(val, int(cvar.minmax_values[0]), int(cvar.minmax_values[1]))
				else:
					# Check whether given value is contains at least one of allowed_values.
					_bad_allowed_vals = true
					if _value_within_allowed(val, cvar.allowed_values):
						value_passed     = true
						_bad_allowed_vals = false
							
					if value_passed:
						cvar.value = val
						
			# Float cvar
			elif cvar.type == TYPE_REAL:
				if not rematch or !(rematch is RegExMatch):
					messageColoredErr("CVar got value of incorrect type while expecting [u]float[/u]")
					return
					
				# Fix case when we receive float like 0,5 not 0.5
				val = float(rematch.get_string().replace(',', '.'))
				
				# If no allowed_values given, make sure given value is within min/max value range
				if not cvar.has("allowed_values") or cvar.allowed_values.size() == 0:
					# Is it within range?
					if (val < float(cvar.minmax_values[0]) or val > float(cvar.minmax_values[1])):
						_bad_minmax_vals = true
					else:
						value_passed = true
						cvar.value   = clamp(val, float(cvar.minmax_values[0]), float(cvar.minmax_values[1]))
				else:
					# Check whether given value is contains at least one of allowed_values.
					_bad_allowed_vals = true
					if _value_within_allowed(val, cvar.allowed_values):
						value_passed     = true
						_bad_allowed_vals = false
						
					# Everything is fine.
					if value_passed:
						cvar.value = val
									
			# Bool cvar
			elif cvar.type == TYPE_BOOL:
				if not rematch or !(rematch is RegExMatch):
					messageColoredErr("CVar got value of either [u]out of range[/u] or incorrect type while expecting [u]boolean[/u]")
					return
				
				value_passed = true
				if (rematch.get_strings()[0].to_lower() == "true" || rematch.get_strings()[0] == "1"):
					cvar.value = true
				else:
					cvar.value = false
					
#			if not value_passed and bad_allowed_vals:
#				messageColoredErr("CVar got value that is out of allowed values:", str(val), "excepted: " + AllowedValuesToStr(cvar.allowed_values))
#			elif not value_passed and bad_minmax_vals:
#				messageColoredErr("CVar got value that is out of range:", str(val), "excepted: " + str(cvar.minmax_values[0]) + ".." + str(cvar.minmax_values[1]))

			# Call setter code
			if value_passed == true:
				cvar.target.set(cmd[0], cvar.value)
	else:
		messageColoredErr("Unknown command or cvar:", cmd[0])
