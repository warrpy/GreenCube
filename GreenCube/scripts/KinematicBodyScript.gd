extends KinematicBody

# ------------------------------------------------------------
# Use 'W', 'S' keys for move.
# For enter/exit view mode press 'Tab'.
# Script author: Warrpy
# -------------------------------------------------------------

var velocity = Vector3()
var direction = Vector3()
var speed = 0
var gravity = -14
var define_direction = false
var initial_speed = 0
var forward = false
var backward = false
var slowly = 0

# variables that can be edited in the Inspector tab.
export var acceleration = 0.01
export var deceleration = 0.05
export var max_speed = 5
export var angle_ease = 5
var view_mode = false
# this node is needed in order to get camera axis rotation.
onready var axis = get_parent().get_node("Axis")

func _physics_process(delta):
	direction = Vector3()
	if Input.is_action_pressed("forward"):
		direction.z = -1
		define_direction = true
		forward = true
	else:
		forward = false
	if Input.is_action_pressed("backward"):
		direction.z = 1
		define_direction = false
		backward = true
	else:
		backward = false
	if Input.is_action_just_pressed("view_mode"):
		if view_mode:
			view_mode = false
		else:
			view_mode = true
		
	if forward or backward:
		
		if not view_mode:
			# smoothly rotates from one rotation to another.
			slowly = lerp_angle(rotation.y, axis.rotation.y, deg2rad(angle_ease))
			rotation.y = slowly
		# acceleration.
		initial_speed = lerp(speed, max_speed, acceleration)
		speed = initial_speed
		
	else:
		# determines where the movement was directed last,
		# forward or backward.
		if define_direction:
			direction.z = -1
		else:
			direction.z = 1
		# deceleration
		initial_speed = lerp(speed, 0, deceleration)
		speed = initial_speed
		
	direction = direction.normalized()
	
	# rotates the direction of movement depending on the rotation.
	# easier, body moves where it is directed/faced.
	direction = direction.rotated(Vector3(0, 1, 0), rotation.y)
	
	direction *= speed
	
	velocity.x = direction.x
	velocity.z = direction.z
	velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	if is_on_floor() and Input.is_action_pressed("jump"):
		velocity.y = 10
