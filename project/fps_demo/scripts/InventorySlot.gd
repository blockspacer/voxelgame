extends Control

signal slot_changed_selection 
signal slot_changed_hover

func change_selection(_is_selected:bool, force_change:bool = false):
	DebUtil.check(false, "not implemented") # will be redefined

func change_hover(_is_hovered:bool, force_change:bool = false):
	DebUtil.check(false, "not implemented") # will be redefined
