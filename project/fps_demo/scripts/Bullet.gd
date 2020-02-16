extends RigidBody

enum BULLET_TYPE {
	BALL = -1,                      # Bouncy ball
	ADD = 0,                        # Add terrain
	DELETE = 1                      # Delete terrain
}

enum BULLET_SHAPE {
	POINT = -1,
	SPHERE = 0,
	BOX = 1
}

var _terrain
var _type 						= BULLET_TYPE.BALL
var edit_shape					= BULLET_SHAPE.SPHERE
var GROWTH_SPEED:Vector3 		= Vector3(0.01,0.01,0.01)
var EDIT_SIZE:float				= 3.5
var SDF_VALUE:float				= 0.0
onready var MIN_DISTANCE:float	= EDIT_SIZE*.75
var LIFE_TIME:int				= 60
var growth_ticker:int			= 0
var sound_played:bool 			= false


func _ready():	
	if(_type != BULLET_TYPE.BALL):
		_terrain = get_node("../VoxelTerrain")
	
	#bounce = 2.0 # deprecated
	
	# Enable bullet collision detection
	contact_monitor = true
	contacts_reported = 1
	var result = connect("body_entered", self, "_on_bullet_hit")
	DebUtil.debCheck(result != null, "logic error")

	var mat = SpatialMaterial.new()
	if(_type == BULLET_TYPE.ADD):
		mat.albedo_color = Color(1,1,1,1)
	elif _type == BULLET_TYPE.DELETE:
		mat.albedo_color = Color(0,0,0,1)
	else:
		mat.albedo_color = Color( rand_range(0,1), rand_range(0,1), rand_range(0,1), 1 )
	$Mesh.set_surface_material(0, mat)

	var death_timer = Timer.new()
	add_child(death_timer)
	if true: # scope
		var err = death_timer.connect("timeout", self, "_on_life_timeout")
		DebUtil.debCheck(!err, "logic error")
	death_timer.start(LIFE_TIME)


func _on_bullet_hit(body):
	if not sound_played and body.name != "Player":
		$AudioStreamPlayer3D.play()
		sound_played = true
		
	if _type == BULLET_TYPE.BALL and OS.get_ticks_msec() - growth_ticker > 100:
		scale += GROWTH_SPEED
		mass += GROWTH_SPEED.x
		growth_ticker = OS.get_ticks_msec()
	if _type != BULLET_TYPE.BALL and body.name == "VoxelTerrain":
		paint_shape(_terrain, global_transform.origin, Vector3(EDIT_SIZE, EDIT_SIZE, EDIT_SIZE), _type, edit_shape, SDF_VALUE)
		queue_free()

			

func _on_life_timeout():
	queue_free()


static func paint_shape(terrain, origin, size, type, shape, sdf_value):
	
	# Creates a new VoxelTool each call, so if you want to retain data, put it in a global function (not in Bullet since it gets destroyed)
	var vt = terrain.get_voxel_tool()
	
	# Return if trying to add a block within MIN_DISTANCE of the player
	#if type == BULLET_TYPE.ADD and (center - $"../Player".global_transform.origin).length() <= fradius+MIN_DISTANCE:
	#	return
	
	if "smooth_meshing_enabled" in terrain and terrain.smooth_meshing_enabled:
		vt.channel = VoxelBuffer.CHANNEL_SDF
	
	if(type == BULLET_TYPE.ADD):
		vt.mode = VoxelTool.MODE_ADD
		vt.value = 1
	elif(type == BULLET_TYPE.DELETE):
		vt.mode = VoxelTool.MODE_REMOVE
		vt.value = 0
	
	if(shape == BULLET_SHAPE.POINT):
		vt.do_point(origin, sdf_value)
	
	if(shape == BULLET_SHAPE.SPHERE):
		vt.do_sphere(origin, size.x, sdf_value)
	
	if(shape == BULLET_SHAPE.BOX):
		vt.do_box(origin, origin + size, sdf_value)
