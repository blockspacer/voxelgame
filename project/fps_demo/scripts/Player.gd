extends KinematicBody

onready var Line = preload("res://fps_demo/scripts/DrawLine3D.gd").new() 


var   	velocity:Vector3			= Vector3()  # Current velocity direction
var   	snap:int					= -1

const 	MOUSE_SENSITIVITY:float 	= 0.1
var   	GRAVITY:float				= -9.8
const 	ACCEL:float					= 8.0
const 	DEACCEL:float				= 16.0
const 	WALK_SPEED:float 			= 10.0 #5.0
const 	JUMP_SPEED:float			= 7.0
const	PLAYER_HEIGHT:float			= 2.0

onready var MAX_FLOOR_ANGLE:float 	= deg2rad(50)


var 	terrain 					= null
var 	box_mover 					= VoxelBoxMover.new()
var 	aabb 						= AABB(Vector3(-0.4, -0.9, -0.4), Vector3(0.8, 1.8, 0.8))
var		on_ground:bool 				= false

export var follow_camera:bool		= false

var i:int = 0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_child(Line)
	#Line.DrawCube(Vector3(0, 55, -14), 1, Color(0.8,0.52,0.25, 1), 1) 
	
	#terrain = get_node("/root/Spatial").terrain 
	terrain = get_node("../VoxelTerrain")
	assert terrain!=null


#if event is InputEventKey and Input.is_key_pressed(KEY_P):		
	var s = get_node("../Poly Ground/Sphere")
	print ("Node: ", s.name)
	print ("Surfaces: ", s.get_surface_material_count())
	var sm = s.get_surface_material(0)
	print ("Resource name: ", sm.resource_name)
	print ("Tex channel: ", sm.ao_texture_channel)
	print ("Tex width: ", sm.ao_texture.get_width())
	print ("Tex light affect: ", sm.ao_light_affect)


func draw_ground_box(center_pos):
	var purple = Color(1,0,1,1)
	var left_front  = Vector3(-1.5, 1,-1.5)
	var left_back   = Vector3(-1.5, 1, 1.5)
	var right_front = Vector3( 1.5, 1,-1.5)
	var right_back  = Vector3( 1.5, 1, 1.5)
	var DOWN = Vector3(0, -1, 0)
	
	var points = [] # [center, left_front, right_front, left_back, right_back ]
	
	var hit = center_pos+Vector3(0, -2.25, 0)
	points.append(hit)
	#terrain.raycast(center_pos, DOWN, 10)
	#if(hit):	points.append(hit.prev_position)
	hit = terrain.raycast(center_pos + left_front, DOWN, 40)
	if(hit):	points.append(hit.prev_position)
	hit = terrain.raycast(center_pos + right_front, DOWN, 40)
	if(hit):	points.append(hit.prev_position)
	hit = terrain.raycast(center_pos + left_back, DOWN, 40)
	if(hit):	points.append(hit.prev_position)
	hit = terrain.raycast(center_pos + right_back, DOWN, 40)
	if(hit):	points.append(hit.prev_position)

	var c = points.size()
	if(c>1):
		Line.DrawLine(points[1], points[0], purple, 0.0167)
	if(c>2): 
		Line.DrawLine(points[2], points[0], purple, 0.0167)
		Line.DrawLine(points[1], points[2], purple, 0.0167)
	if(c>3): 
		Line.DrawLine(points[3], points[0], purple, 0.0167)
		Line.DrawLine(points[1], points[3], purple, 0.0167)
	if(c>4): 
		Line.DrawLine(points[4], points[0], purple, 0.0167)
		Line.DrawLine(points[4], points[2], purple, 0.0167)
		Line.DrawLine(points[4], points[3], purple, 0.0167)



	
func _physics_process(delta):
		
	var direction = Vector3() 						# Where does the player want to move
	var camera_direction = get_global_transform().basis	# Get camera facing direction
	var head_position = get_translation()
	snap = -1


	$"../UI/VBox/FPS".text = "FPS: " + String(Engine.get_frames_per_second())	
	$"../UI/VBox/Position".text = "Position: " + String(head_position)	
	#Line.DrawCube(head_position+Vector3(0,-1.25,0), 2, Color(0,0,0, 1), 0.0167) 
	
	#draw_ground_box(head_position)		# Do something with this slope information
	
	


	
	
	if Input.is_action_pressed("move_forward"):		# Fix: Can move around in the air, no momentum, so can also climb steep walls.
		direction += test_and_move(head_position, -camera_direction[2])			
	if Input.is_action_pressed("move_backward"):
		direction += test_and_move(head_position, camera_direction[2])
	if Input.is_action_pressed("move_left"):
		direction += test_and_move(head_position, -camera_direction[0])
	if Input.is_action_pressed("move_right"):
		direction += test_and_move(head_position, +camera_direction[0])
	if  Input.is_action_pressed("jump"): #(on_ground || is_on_floor()) and
		velocity.y = JUMP_SPEED
		on_ground=false
		snap = 0
	
	#direction.y = 0
	direction = direction.normalized()
	
	# Apply gravity to downward velocity
	velocity.y += delta*GRAVITY
	# But clamp it if we hit the ground
	if terrain.raycast(head_position, Vector3(0,-1,0), 1.75): #PLAYER_HEIGHT): # At <=1.5 ride gets very bumpy
		velocity.y = clamp(velocity.y, 0, 999999999)
		on_ground = true 

	var hvelocity = velocity				# Apply desired direction to horizontal velocity
	hvelocity.y = 0
	
	var target = direction*WALK_SPEED
	var accel
	if (direction.dot(hvelocity) > 0):
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvelocity = hvelocity.linear_interpolate(target, accel*delta)
	
	velocity.x = hvelocity.x
	velocity.z = hvelocity.z

	# Polygon Collision	
	velocity = move_and_slide_with_snap(velocity, Vector3(0, snap, 0), Vector3(0, 1, 0), true, 4, MAX_FLOOR_ANGLE)

	# Blocky Terrain Collision (Blocky)
	"""
	var motion = velocity * delta
	motion = box_mover.get_motion(get_translation(), motion, aabb, terrain)
	global_translate(motion)
	velocity = motion / delta
	"""
	

# Raycast collision (Smooth)	
func test_and_move(pos, dir) -> Vector3:
	#return dir
	# If raycast hits at feet level (-1.5)
	if terrain.raycast(Vector3(pos.x, pos.y-1.5, pos.z), dir, 1):
	
		# Then test at eye level and move up a little if clear
		if !terrain.raycast(pos, dir, 1) :
			translate(Vector3(0,.15,0))
			return dir
		
		# Both hit, can't move	
		return Vector3(0,0,0)
	
	# Otherwise, free to move	
	else:
		return dir

	
	
func _input(event):
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Camera.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
		var rotation = $Camera.rotation_degrees
		rotation.x = clamp(rotation.x, -80, 80)
		$Camera.rotation_degrees = rotation
		
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))


	if event is InputEventKey and Input.is_action_pressed("follow"):
		if ! follow_camera:
			var t = $Camera.get_transform()
			t.origin = Vector3(0, 3.5, 8)
			$Camera.set_transform(t)
			follow_camera = true
			$BodyMesh.visible = true
		else:
			var t = $Camera.get_transform()
			t.origin = Vector3(0, 0, 0)
			$Camera.set_transform(t)
			follow_camera = false
			$BodyMesh.visible = false


	if event is InputEventKey and Input.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



			
