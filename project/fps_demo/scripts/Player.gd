extends KinematicBody

const 		MOUSE_SENSITIVITY:float 	= 0.1
const  		GRAVITY:float				= -9.8
const 		ACCEL:float					= 8.0
const 		DEACCEL:float				= 16.0
onready var MAX_FLOOR_ANGLE:float 		= deg2rad(60)
export var	WALK_SPEED:float 			= 20.0
export var  JUMP_SPEED:float			= 15.0
export var	jump_is_jetpack:bool		= false
var   		velocity:Vector3			= Vector3()  # Current velocity direction

const 		Bullet						= preload("Bullet.gd")
var 		firing:bool 				= false
var 		firing_type					= Bullet.BULLET_TYPE.BALL
onready var firing_tick:int				= OS.get_ticks_msec()
export var 	FIRING_DELAY				= 150

onready var	camera_pullback_tick:int 	= OS.get_ticks_msec()		# Pullback Timer
export var 	CAMERA_PULLBACK_DELAY		= 1000						# Wait this many ms before pulling back
export var 	CAMERA_POS_CLOSE:Vector3 	= Vector3(0, 0.3, 0)		# Vectors that the two settings below lerp between
export var 	CAMERA_POS_FAR:Vector3		= Vector3(0, 3.5, 7)
var			camera_max_lerp:float		= 1.0						# User set max lerp position between 0 and 1
var 	   	camera_pos_lerp:float		= 0.0						# Current lerp position between 0 and camera_max_lerp 
var SDF_VALUE:float				= 0.0

export(NodePath) var edit_cursor_sphere_path = null
export(NodePath) var edit_cursor_box_path = null
export(NodePath) var world_path = null
export(NodePath) var terrain_path = null
export(Material) var cursor_material_on_add_action = null
export(Material) var cursor_material_on_remove_action = null

var _terrain:VoxelLodTerrain = null
var edit_cursor = null
var edit_shape					= Bullet.BULLET_SHAPE.SPHERE

onready var raycaster = $CamNode/Camera/RayCast
var last_raycast_on_terrain = null

func hide_edit_cursors():
	get_node(edit_cursor_sphere_path).hide()
	get_node(edit_cursor_box_path).hide()
	

func _ready():
	_terrain = get_node(terrain_path) as VoxelLodTerrain
	hide_edit_cursors()
	edit_cursor = get_node(edit_cursor_sphere_path)


func get_pointed_voxel():
	var origin = $CamNode/Camera.global_transform.origin
	var forward = -$CamNode/Camera.get_transform().basis.z.normalized()
	var hit = _terrain.raycast(origin, forward, 10)
	return hit
	
func _physics_process(delta):
	if _terrain == null:
		return
	
	if(raycaster.enabled and raycaster.is_colliding()):
		var hit = raycaster.get_collider()
		if (hit != null and hit.get_name() == "VoxelTerrain"):
			last_raycast_on_terrain = raycaster.get_collision_point()
			var offset = Vector3(0.5,0.5,0.5)
			if(edit_shape == Bullet.BULLET_SHAPE.BOX):
				offset = Vector3(1.0,1.0,1.0)
			edit_cursor.set_translation(last_raycast_on_terrain + offset)
			edit_cursor.material_override = (cursor_material_on_add_action)
			edit_cursor.show()
		else:
			edit_cursor.hide()
	else:
		edit_cursor.hide()
		
	#### Update Player
	
	var direction = Vector3() 						# Where does the player want to move
	var facing_direction = global_transform.basis	# Get camera facing direction
	
	if Input.is_action_pressed("move_forward"):		# Fix: Can move around in the air, no momentum, so can also climb steep walls.
		direction -= facing_direction.z			

	if Input.is_action_pressed("move_backward"):
		direction += facing_direction.z

	if Input.is_action_pressed("move_left"):
		direction += -facing_direction.x

	if Input.is_action_pressed("move_right"):
		direction += +facing_direction.x

	if  Input.is_action_pressed("jump") and (jump_is_jetpack or is_on_floor()):
		velocity.y = JUMP_SPEED
	
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

	velocity = move_and_slide(velocity, Vector3(0, 1, 0), true)


	#### Continuous fire
	if firing and OS.get_ticks_msec()-firing_tick>FIRING_DELAY:
		firing_tick = OS.get_ticks_msec()
		#shoot_bullet()
		if(last_raycast_on_terrain != null and edit_cursor.is_visible()):
			Bullet.paint_shape(_terrain, last_raycast_on_terrain, get_edit_cursor_size(), firing_type, edit_shape, SDF_VALUE)
	
	#### Update Camera
	
	if camera_max_lerp>0:
		check_camera_bounds()
		


# If follow camera is on, and hits the terrain, pull it in closer to the player 
func check_camera_bounds():
	var space_state = get_world().direct_space_state
	var pos = $CamNode/Camera.global_transform.origin

	# Raycast two unit around camera for rudimentary collision detection. (Maybe switch Camera parent to physicsbody?)
	var result0 = space_state.intersect_ray(pos, pos + 2*$CamNode/Camera.global_transform.basis.z, [self])  # Behind
	var result1 = space_state.intersect_ray(pos, pos - 2*$CamNode/Camera.global_transform.basis.z, [self])  # Front
	var result2 = space_state.intersect_ray(pos, pos + 2*$CamNode/Camera.global_transform.basis.x, [self])	# Right
	var result3 = space_state.intersect_ray(pos, pos - 2*$CamNode/Camera.global_transform.basis.x, [self])	# Left
	var result4 = space_state.intersect_ray(pos, pos + 2*$CamNode/Camera.global_transform.basis.y, [self])	# Above
	var result5 = space_state.intersect_ray(pos, pos - 2*$CamNode/Camera.global_transform.basis.y, [self])	# Below

	if result0 or result1 or result2 or result3 or result4 or result5:
		camera_pos_lerp -= .025
		camera_pos_lerp = clamp(camera_pos_lerp, 0, camera_max_lerp)
		camera_pullback_tick = OS.get_ticks_msec()
		move_camera(camera_pos_lerp)

	else:
		if OS.get_ticks_msec() - camera_pullback_tick > CAMERA_PULLBACK_DELAY:
			camera_pos_lerp += .01
			camera_pos_lerp = clamp(camera_pos_lerp, 0, camera_max_lerp)
			move_camera(camera_pos_lerp)


func move_camera(lerp_val:float) -> void:
	var t = $CamNode/Camera.get_transform()
	var offset = CAMERA_POS_CLOSE.linear_interpolate(CAMERA_POS_FAR, lerp_val)
	t.origin = CAMERA_POS_CLOSE + offset
	$CamNode/Camera.set_transform(t)


func shoot_bullet():
	if _terrain == null:
		return
		
	$AudioStreamPlayer.play()

	var bullet = preload("res://fps_demo/scenes/bullet.tscn").instance()
	var start_pos = $Body/Shoulder/Gun.global_transform.translated(Vector3(0,-1.15,0))
	bullet.set_transform(start_pos)
	bullet.scale = Vector3(.3,.3,.3)
		
	if Input.is_key_pressed(KEY_CONTROL):
		bullet._type = Bullet.BULLET_TYPE.BALL
	else:
		bullet._type = firing_type

	bullet.set_linear_velocity(velocity - $Body/Shoulder/Gun.global_transform.basis.y * 30)
	#if true: # scope
	#	var err = bullet.connect("painting", self, "_on_terrain_addition")
	#	DebUtil.debCheck(!err, "logic error")
	bullet.add_to_group("bullets")
	get_parent().add_child(bullet)

func inc_edit_cursor_size(size:float) -> void:
	var max_size = 5.0
	if(edit_shape == Bullet.BULLET_SHAPE.SPHERE):
		max_size = 10.0
	if((edit_cursor.scale.x + size) > 0.0 and (edit_cursor.scale.x + size) < max_size):
		edit_cursor.scale += Vector3(size,size,size)
	edit_cursor.get_child(0).omni_range = edit_cursor.scale.x + 0.5
		
func get_edit_cursor_size() -> Vector3:
	if(edit_shape == Bullet.BULLET_SHAPE.SPHERE):
		return Vector3(edit_cursor.get_transformed_aabb().size.x/2.0,edit_cursor.get_transformed_aabb().size.y/2.0,edit_cursor.get_transformed_aabb().size.z/2.0)
	return edit_cursor.get_transformed_aabb().size
	
func _input(event):
	var is_menu_overlay_visible = Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE
	if not is_menu_overlay_visible:
		if Input.is_action_pressed("throw_grenade"):		# Fix: Can move around in the air, no momentum, so can also climb steep walls.
			shoot_bullet()

		if Input.is_action_pressed("toggle_weapon_spotlight"):		# Fix: Can move around in the air, no momentum, so can also climb steep walls.
			$CamNode/Camera/SpotLight.visible = !$CamNode/Camera/SpotLight.visible
		
		if event is InputEventKey and event.pressed:
			if Input.is_action_pressed("sdf_add"):
				SDF_VALUE+=5.0;
				GlobalLogger.info(self, \
					'SDF_VALUE' + str(SDF_VALUE))

			if Input.is_action_pressed("sdf_del"):
				SDF_VALUE-=5.0;
				GlobalLogger.info(self, \
					'SDF_VALUE' + str(SDF_VALUE))

			if event.scancode == KEY_1:
				edit_shape = Bullet.BULLET_SHAPE.POINT
				hide_edit_cursors()
				edit_cursor = get_node(edit_cursor_sphere_path)
				GlobalLogger.info(self, \
					"firing_shape = 0 (do_point)")

			if event.scancode == KEY_2:
				edit_shape = Bullet.BULLET_SHAPE.SPHERE
				hide_edit_cursors()
				edit_cursor = get_node(edit_cursor_sphere_path)
				GlobalLogger.info(self, \
					"firing_shape = 1 (do_sphere)")

			if event.scancode == KEY_3:
				edit_shape = Bullet.BULLET_SHAPE.BOX
				hide_edit_cursors()
				edit_cursor = get_node(edit_cursor_box_path)
				GlobalLogger.info(self, \
					"firing_shape = 2 (do_box)")
				
		if event is InputEventMouseButton and Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
			#camera_max_lerp -= .1
			#camera_max_lerp = clamp(camera_max_lerp, 0, 1)
			inc_edit_cursor_size(1)
	
		elif event is InputEventMouseButton and Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):
			#camera_max_lerp += .1
			#camera_max_lerp = clamp(camera_max_lerp, 0, 1)
			inc_edit_cursor_size(-1)
			
			
		elif event is InputEventMouseMotion: 
			
			# Rotate the camera around the player vertically
			$CamNode.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY * 0.90625))
			var rot = $CamNode.rotation_degrees
			rot.x = clamp(rot.x, -60, 85)
			$CamNode.rotation_degrees = rot
	
			# Rotate the gun up and down aligned with the player 
			$Body/Shoulder.rotate_x(deg2rad(-event.relative.y * MOUSE_SENSITIVITY))
			rot = $Body/Shoulder.rotation_degrees
			rot.x = clamp(rot.x, -80, 80)
			$Body/Shoulder.rotation_degrees = rot
			$GunCollisionShape.global_transform = $Body/Shoulder/Gun.global_transform
			
			# Rotate Player left and right
			self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
	
	
		elif event is InputEventMouseButton and _terrain != null :
			if Input.is_action_pressed("shoot_add"):
				firing_type = Bullet.BULLET_TYPE.ADD
				firing = true
				firing_tick = OS.get_ticks_msec()
				#shoot_bullet()
				if(last_raycast_on_terrain != null and edit_cursor.is_visible()):
					Bullet.paint_shape(_terrain, last_raycast_on_terrain, get_edit_cursor_size(), firing_type, edit_shape, SDF_VALUE)
			
			elif Input.is_action_pressed("shoot_del") and _terrain != null :
				firing_type = Bullet.BULLET_TYPE.DELETE
				firing = true
				firing_tick = OS.get_ticks_msec()
				#shoot_bullet()
				if(last_raycast_on_terrain != null and edit_cursor.is_visible()):
					Bullet.paint_shape(_terrain, last_raycast_on_terrain, get_edit_cursor_size(), firing_type, edit_shape, SDF_VALUE)
			
			elif Input.is_action_just_released("shoot_add") or Input.is_action_just_released("shoot_del"):
				firing = false

