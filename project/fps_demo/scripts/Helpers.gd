extends Node

func reparent(target, new_parent):
	DebUtil.debCheck(target != null, "logic error")
	DebUtil.debCheck(new_parent != null, "logic error")
	if target.get_parent() != null: 
		target.get_parent().remove_child(target)
	new_parent.add_child(target)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
