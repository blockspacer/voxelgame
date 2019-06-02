extends KinematicBody

onready var Line = preload("res://tutorial/DrawLine3D.gd").new() 
var i:int = 0


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

export var follow_camera:bool		= true


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	terrain = get_node("../VoxelTerrain")
	if terrain==null: terrain=get_node("../VoxelLodTerrain")
	
	add_child(Line)
			
	
func _physics_process(delta):
		
	var direction = Vector3() 						# Where does the player want to move
	var camera_direction = get_global_transform().basis	# Get camera facing direction
	var head_position = get_translation()
	snap = -1

	#Line.DrawRay(head_position, direction*100.0, Color(1,0,0), 1)
	#Line.DrawRay(knee_position, direction*50, Color(0,1,0), 1)
	#Line.DrawRay(foot_position, direction*50, Color(0,0,1), 1)
	
	
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
		velocity.y = clamp(velocity.y, 0, 999999999999)
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

		
			
