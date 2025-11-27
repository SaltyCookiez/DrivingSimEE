extends SpringArm3D

@export var car: VehicleBody3D

var MouseSensitivity = 0.1
var pitch_deg := -10.0
@export var yaw_offset_degrees := -90.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# set_as_top_level(true)
	var cam := get_node_or_null("Camera3D")
	if cam:
		cam.make_current()
	if car == null and get_parent() is VehicleBody3D:
		car = get_parent() as VehicleBody3D

func _input(event):
	if event is InputEventMouseMotion:
		pitch_deg -= event.relative.y * MouseSensitivity
		pitch_deg = clamp(pitch_deg, -15.0, 10.0)
		rotation_degrees.x = pitch_deg

func _process(_delta):
	if car == null:
		return

	global_position = car.global_transform.origin

	var car_euler: Vector3 = car.global_transform.basis.get_euler()
	var yaw := car_euler.y + deg_to_rad(yaw_offset_degrees)

	rotation = Vector3(deg_to_rad(pitch_deg), yaw, 0.0)
