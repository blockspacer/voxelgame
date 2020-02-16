extends Control

signal chat_msg_entered()

export(bool) var player_can_use_chat = true

export(bool) var offline_mode = true

export(bool) var auto_hide = false

const INPUT_LINE_SIZE	= 20
const INPUT_MAX_LINES	= 6
const INPUT_MAX_LINE_CH	= 36
const INPUT_MAX_CH		= 150
const CHAT_TIMEOUT		= 5.0

const OPEN_TAGS			= ["[b]", "[i]", "[u]", "[s]", "[code]", "[center]", "[right]", "[fill]", "[indent]", "[url]", "[img]", "[url=", "[font=", "[color="]
const CLOSE_TAGS		= ["[/b]", "[/i]", "[/u]", "[/s]", "[/code]", "[/center]", "[/right]", "[/fill]", "[/indent]", "[/url]", "[/img]", "[/url]", "[/font]", "[/color]"]

onready var all_msgs		= $ChatRect/MarginContainer/VBoxContainer/AllMsgsRichTextLabel
onready var who_channel		= $ChatRect/MarginContainer/VBoxContainer/HBoxContainer/SelectChannelBtn
onready var input	= $ChatRect/MarginContainer/VBoxContainer/HBoxContainer/InputMsg
onready var send	= $ChatRect/MarginContainer/VBoxContainer/HBoxContainer/SendBtn
onready var anim	= $AnimationPlayer

#var who_send		= true # true - all, false - team

var chat_visible	= false
var chat_focused	= false

var chat_timer		= 0.0

func _ready() -> void:
	set_process(false)
	#
	chat_exit()
	#
	if not player_can_use_chat:
		return
	#
	input.connect("text_changed", self, "_on_input_text_changed")
	input.connect("mouse_entered", self, "_on_input_mouse_entered")
	input.connect("mouse_exited", self, "_on_input_mouse_exited")
	if(offline_mode):
		if true: # scope
			var err = self.connect("chat_msg_entered", self, "_on_chat_msg_entered")
			DebUtil.debCheck(!err, "logic error")
	#
	set_process(true)

func is_reached_max_limit(text:String) -> bool:
	return text.length() >= INPUT_MAX_CH + 2
	
func is_msg_empty(text:String) -> bool:
	return text.length() <= 0 \
		or text == "\n"

func _input(_event) -> void:
	#print("_input() 1")
	if (chat_visible and Input.is_action_just_pressed("chat_newline")):
		# Stop the event from spreading
		get_tree().set_input_as_handled()
		GlobalLogger.info(self, \
			"is_action_just_pressed() chat_newline")
		# TODO: TextEdit inserts newline on shift+enter even if TextEdit shortcuts are disabled
		#	if chat_visible and chat_focused:
		#		if not is_reached_max_limit(input.text):
		#			var begin = input.get_selection_from_line()
		#			var finish = input.get_selection_to_line()
		#			input.cursor_set_line(max(0,input.cursor_get_line()))
		#			input.cursor_set_column(max(0,input.cursor_get_column()))
		#			input.insert_text_at_cursor("")
	elif (Input.is_action_just_pressed("chat_enter")):
		GlobalLogger.info(self, \
			"is_action_just_pressed() chat_enter")
		#and !Input.is_action_pressed("chat_shift") and !$"../Console/ConsoleBox".visible):
		if chat_focused:
			_on_input_mouse_exited()
			# NOTE: do proper input filtering server-side, but prevent client from spamming with invalid messages
			if not is_msg_empty(input.text) and not is_reached_max_limit(input.text):
				GlobalLogger.info(self, \
					"input.text = " + str(input.text))
				emit_signal("chat_msg_entered", input.text)
			input.text = ""
			_on_input_text_changed() 
		else:
			_on_input_mouse_entered()
			if !chat_visible:
				chat_visible = true
				anim.play("show")
				# Stop the event from spreading
				get_tree().set_input_as_handled()
			chat_timer = CHAT_TIMEOUT
	
	if chat_visible:
		
		if Input.is_action_just_pressed("chat_esc"):
			chat_exit()
		
		#if (Input.is_action_just_pressed("chat_who")
		#and Input.is_action_pressed("chat_shift")):
		#	if who_send:
		#		who_send = false
		#		who.text = "TEAM:"
		#	else:
		#		who_send = true
		#		who.text = "ALL:"
	
	if input.text.length() > INPUT_MAX_CH:
		var c_column = input.cursor_get_column()
		var c_line = input.cursor_get_line()
		input.text = input.text.left(INPUT_MAX_CH)
		input.cursor_set_column(c_column)
		input.cursor_set_line(c_line)

func _process(delta) -> void:
	if chat_visible:
		if auto_hide and chat_timer > 0.0 and !input.has_focus():
			chat_timer -= delta
			if chat_timer < 0:
				chat_exit()
	
func _on_chat_msg_entered(message):
	GlobalLogger.info(self, \
		"_on_chat_msg_entered " \
		+ str(message))
	add_msg(message, "main_channel", "player_id")

func add_msg(message, _channel_id, player_id):
	#var pl = G.World.players.get_node_or_null(str(id))
	#var my_pl = G.my_player
	#if pl == null or my_pl == null: return
	#if !to_all and pl.team != my_pl.team:
	#	return
	
	#if message == "F":
	#	emit_signal("oof")
	
	var cooked = "[color="
	
	cooked += "#" + Color(1.0,1.0,1.0,1.0).to_html(false)
	#if pl.team == G.TEAM_1:
	#	if to_all:
	#		cooked += "#" + $"..".TEAM_1_COLOR.to_html(false)
	#	else:
	#		cooked += "#" + $"..".TEAM_1_COLOR.darkened(0.25).to_html(false)
	#else:
	#	if to_all:
	#		cooked += "#" + $"..".TEAM_2_COLOR.to_html(false)
	#	else:
	#		cooked += "#" + $"..".TEAM_2_COLOR.darkened(0.25).to_html(false)
	cooked += "]"
	
	#if to_all:
	#	cooked += "[ALL] "
	#else:
	#	cooked += "[TEAM] "
	
	#cooked += pl.caption + "[/color]: "
	cooked += player_id + "[/color]: "
	cooked += message
	
	var how_much_pop = 0
	
	for i in range(OPEN_TAGS.size()):
		how_much_pop += message.count(OPEN_TAGS[i]) - message.count(CLOSE_TAGS[i])
	
	all_msgs.append_bbcode(cooked + "\n")
	for _i in range(how_much_pop):
		all_msgs.pop()
	
	if !chat_visible:
		chat_visible = true
		anim.play("show")
	chat_timer = CHAT_TIMEOUT


func chat_exit():
	chat_timer = 0.0
	_on_input_mouse_exited()
	chat_visible = false
	anim.play("hide")


func _on_input_mouse_entered():
	input.grab_focus()
	chat_focused = true

func _on_input_mouse_exited():
	input.release_focus()
	chat_focused = false


func _on_input_text_changed():
	chat_timer = CHAT_TIMEOUT
	var real_lines = input.get_line_count()
	#var lines_splitted = input.get_text().split("\n", true)
	for i in range(real_lines):
		#real_lines += lines_splitted[i].length() / INPUT_MAX_LINE_CH
		real_lines += input.get_line(i).length() / INPUT_MAX_LINE_CH
	if (real_lines * INPUT_LINE_SIZE
		and real_lines < INPUT_MAX_LINES):
		input.rect_min_size.y = real_lines * INPUT_LINE_SIZE
