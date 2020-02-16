tool
extends ImmediateGeometry

func _process(_delta) -> void:
	clear()
	
	begin(Mesh.PRIMITIVE_LINES)
	
	add_vertex(transform.origin + Vector3(0, 0, 0))
	add_vertex(transform.origin + Vector3(0, 0, -5))
	
	end()
