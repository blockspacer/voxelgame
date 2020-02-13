extends WindowDialog

signal drop_confirm

signal drop_cancel

var _reset_position = null

var _reset_size = null

onready var _text_body = $MarginContainer/VBoxContainer/RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	_reset_position = rect_position
	_reset_size = rect_size

func set_text_body(text):
	_text_body.bbcode_text = text
	
func reset_rect():
	rect_position = _reset_position
	rect_size = _reset_size

func _on_ButtonOK_pressed():
	emit_signal("drop_confirm")

func _on_ButtonCancel_pressed():
	emit_signal("drop_cancel")
	hide()

func _on_ConfirmWindowDialog_popup_hide():
	emit_signal("drop_cancel")
	hide()
