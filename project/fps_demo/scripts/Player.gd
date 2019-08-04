extends KinematicBody

var   	velocity:Vector3			= Vector3()  # Current velocity direction
var   	snap:int					= -1

const 	MOUSE_SENSITIVITY:float 	= 0.1
var   	GRAVITY:float				= -9.8
const 	ACCEL:float					= 8.0
const 	DEACCEL:float				= 16.0
const 	WALK_SPEED:float 			= 10.0
const 	JUMP_SPEED:float			= 7.0
const	PLAYER_HEIGHT:float			= 2.0

onready var MAX_FLOOR_ANGLE:float 	= deg2rad(50)

var		on_ground:bool 				= false

export var enable_follow_camera:bool		= false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
func _physics_process(delta):
		
	var direction = Vector3() 						# Where does the player want to move
	var camera_direction = get_global_transform().basis	# Get camera facing direction
	var head_position = get_translation()
	snap = -1


	$"../UI/VBox/FPS".text = "FPS: " + String(Engine.get_frames_per_second())	
	$"../UI/VBox/Position".text = "Position: " + String(head_position)	
	
	
	if Input.is_action_pressed("move_forward"):		# Fix: Can move around in the air, no momentum, so can also climb steep walls.
		direction += -camera_direction[2]			
	if Input.is_action_pressed("move_backward"):
		direction += camera_direction[2]
	if Input.is_action_pressed("move_left"):
		direction += -camera_direction[0]
	if Input.is_action_pressed("move_right"):
		direction += +camera_direction[0]
	if  Input.is_action_pressed("jump"): #(on_ground || is_on_floor()) and
		velocity.y = JUMP_SPEED
		on_ground=false
		snap = 0
	
	#direction.y = 0
	direction = direction.normalized()
	
	# Apply gravity to downward velocity
	velocity.y += delta*GRAVITY
	

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

	# Polygon enable_collision	
	velocity = move_and_slide_with_snap(velocity, Vector3(0, snap, 0), Vector3(0, 1, 0), true, 4, MAX_FLOOR_ANGLE)


func _input(event):
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Camera.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
		var rotation = $Camera.rotation_degrees
		rotation.x = clamp(rotation.x, -80, 80)
		$Camera.rotation_degrees = rotation
		
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))


	if event is InputEventKey and Input.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


	if event is InputEventKey and Input.is_action_pressed("follow"):
		if ! enable_follow_camera:
			var t = $Camera.get_transform()
			t.origin = Vector3(0, 3.5, 8)
			$Camera.set_transform(t)
			enable_follow_camera = true
			$BodyMesh.visible = true
		else:
			var t = $Camera.get_transform()
			t.origin = Vector3(0, 0, 0)
			$Camera.set_transform(t)
			enable_follow_camera = false
			$BodyMesh.visible = false

