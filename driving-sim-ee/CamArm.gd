extends SpringArm3D

var MouseSensitivity = 0.1
var auto_turn_speed := 5.0
var car = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_as_top_level(true)
	car = get_parent()

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * MouseSensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, -10.0)

		rotation_degrees.y -= event.relative.x * MouseSensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

func _process(delta):
	if car == null:
		return
	
	var vel = car.linear_velocity
	
	if vel.length() > 0.1:
		var target_yaw = atan2(-vel.x, -vel.z) * 180.0 / PI
		rotation_degrees.y = lerp_angle(rotation_degrees.y, target_yaw, auto_turn_speed * delta)
