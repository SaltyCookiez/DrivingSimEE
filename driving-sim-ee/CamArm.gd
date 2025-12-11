extends SpringArm3D

@export var car: VehicleBody3D
@export var height: float = 2.0
@export var distance: float = 6.0
@export var yaw_offset_degrees: float = 0.0

var mouse_sensitivity: float = 0.1
var pitch_deg: float = -10.0

func _ready():
	if not get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Camera3D.current = true
	spring_length = 0.0

	if car == null and get_parent() is VehicleBody3D:
		car = get_parent() as VehicleBody3D

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		pitch_deg -= event.relative.y * mouse_sensitivity
		pitch_deg = clamp(pitch_deg, -30.0, 10.0)

func _physics_process(_delta):
	if car == null:
		push_warning("Camera has no 'car' assigned!")
		return

	var car_transform: Transform3D = car.global_transform
	var car_pos: Vector3 = car_transform.origin

	var base_pos: Vector3 = car_pos + Vector3.UP * height

	var back_dir: Vector3 = -car_transform.basis.z
	back_dir.y = 0.0
	if back_dir.length() == 0.0:
		back_dir = Vector3.FORWARD
	back_dir = back_dir.normalized()

	var yaw_offset: float = deg_to_rad(yaw_offset_degrees)
	var yaw_rot := Basis(Vector3.UP, yaw_offset)
	back_dir = yaw_rot * back_dir

	global_position = base_pos - back_dir * distance

	var look_target: Vector3 = car_pos
	var forward_dir: Vector3 = (look_target - global_position).normalized()
	var yaw: float = atan2(forward_dir.x, forward_dir.z)

	var basis := Basis(Vector3.UP, yaw)
	basis = basis.rotated(basis.x, deg_to_rad(pitch_deg))
	global_transform.basis = basis
