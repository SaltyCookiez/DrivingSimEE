extends VehicleBody3D

var speed_kmh: float = 0.0

var hud = null

# Engine & Transmission
var gear_ratios = [3.2, 1.9, 1.3, 1.0, 0.85, 0.7]
var final_drive_ratio = 3.0
var current_gear = 1
var max_gears = 6

var upshift_rpm = 4800
var downshift_rpm = 1800
var shift_delay = 0.6
var shift_timer = 0.0

var idle_rpm = 800
var max_rpm = 5000
var current_rpm = idle_rpm

var engine_torque = 0.0
var base_torque = 650.0     
var engine_drag = 0.006

# Driving Dynamics
var steering_sensitivity = 0.35
var steering_lerp_speed = 3.0
var brake_force = 20.0
var acceleration_input = 0.0
var brake_input = 0.0

# Misc
var gear_mode = "D" # P, R, N, D
var debug_enabled = true

# Helper for camera sync
@onready var cam_arm: Camera3D = $CamArm/Camera3D
@onready var cam_pov: Camera3D = $POV/Camera3D

var is_pov := false

func set_hud(h):
	hud = h
	if hud:
		print("HUD Connected to Car")
	else:
		print("HUD still null")

func get_compression(wheel: VehicleWheel3D) -> float:
	return clamp(
		1.0 - wheel.get_suspension_travel() / max(wheel.suspension_travel, 0.01),
		0.0,
		1.0
	)

func _apply_anti_roll_bar():
	var k = 12000.0  # anti-roll force strength

	var wfl = $wheel_front_left
	var wfr = $wheel_front_right
	var wrl = $wheel_back_left
	var wrr = $wheel_back_right

	var c_fl = get_compression(wfl)
	var c_fr = get_compression(wfr)
	var c_rl = get_compression(wrl)
	var c_rr = get_compression(wrr)

	# Front axle anti-roll force
	var anti_roll_front = (c_fl - c_fr) * k
	if wfl.is_in_contact():
		apply_force(-global_transform.basis.y * anti_roll_front, wfl.global_transform.origin - global_transform.origin)
	if wfr.is_in_contact():
		apply_force(global_transform.basis.y * anti_roll_front, wfr.global_transform.origin - global_transform.origin)

	# Rear axle anti-roll force
	var anti_roll_rear = (c_rl - c_rr) * k
	if wrl.is_in_contact():
		apply_force(-global_transform.basis.y * anti_roll_rear, wrl.global_transform.origin - global_transform.origin)
	if wrr.is_in_contact():
		apply_force(global_transform.basis.y * anti_roll_rear, wrr.global_transform.origin - global_transform.origin)

func set_pov(enable: bool) -> void:
	is_pov = enable
	cam_arm.current = not enable
	cam_pov.current = enable

func _physics_process(delta):
	
	speed_kmh = linear_velocity.length() * 3.6
	var speed = speed_kmh
	
	if hud:
		hud.update_speed(-speed if gear_mode == "R" else speed)
		hud.update_gear(_get_display_gear())
	
	# Camera follow
	# cam_arm.position = position

	# Inputs
	acceleration_input = Input.get_action_strength("Gas")   # W
	brake_input = Input.get_action_strength("Brake")         # S
	var steering_dir = Input.get_action_strength("Left") - Input.get_action_strength("Right")

	# Manual gear mode switching
	if Input.is_action_just_pressed("ui_page_up"):
		_cycle_gear_mode()

	# Vehicle speed in km/h
	var steering_limit = clamp(1.0 - (speed / 120.0), 0.3, 1.0)

	# Auto-switch to reverse or drive when stopped
	if gear_mode == "D" and speed < 1.0 and brake_input > 0.5:
		gear_mode = "R"
	elif gear_mode == "R" and speed < 1.0 and acceleration_input > 0.5:
		gear_mode = "D"

	# Wheel data
	var wheel_rpm_left = abs($wheel_back_left.get_rpm())
	var wheel_rpm_right = abs($wheel_back_right.get_rpm())
	var wheel_rpm = (wheel_rpm_left + wheel_rpm_right) / 2.0

	# Aerodynamic downforce (single, modest)
	var downforce_factor = 3.0
	apply_central_force(-transform.basis.y * linear_velocity.length() * downforce_factor)

	# Engine and transmission
	_update_engine_rpm(wheel_rpm, delta)
	if gear_mode == "D":
		_handle_automatic_shifting()

	engine_torque = _calculate_engine_torque(current_rpm)
	var torque_output = _calculate_engine_force(engine_torque)

	# Engine force and braking behavior
	if gear_mode == "D":
		engine_force = torque_output * acceleration_input

		# Apply braking when S pressed
		if acceleration_input == 0 and brake_input > 0:
			brake = brake_force * brake_input
		else:
			brake = 0.0

	elif gear_mode == "R":
		# S = reverse throttle, W = forward brake
		engine_force = -torque_output * brake_input

		if brake_input == 0 and acceleration_input > 0:
			brake = brake_force * acceleration_input
		else:
			brake = 0.0

	else:
		engine_force = 0.0
		brake = 0.0

	# Steering
	steering = lerp(
		steering,
		steering_dir * steering_sensitivity * steering_limit,
		steering_lerp_speed * delta
	)

	# Engine drag
	_apply_engine_drag(delta)

	# Anti-roll bar
	_apply_anti_roll_bar()

	# Debug info
	#if debug_enabled:
		#_print_debug(speed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_switch"):
		set_pov(not is_pov)

# Engine and Transmission
func _calculate_engine_torque(rpm: float) -> float:
	var mid_rpm = max_rpm * 0.65
	var torque_factor = 1.0 - pow((rpm - mid_rpm) / (mid_rpm * 1.5), 2)
	torque_factor = clamp(torque_factor, 0.0, 1.0)
	var min_torque = 120.0   # stronger low RPM torque
	return base_torque * torque_factor + min_torque

func _calculate_engine_force(torque: float) -> float:
	var gear_ratio = gear_ratios[current_gear - 1] if current_gear > 0 else 0
	var total_ratio = gear_ratio * final_drive_ratio
	var wheel_torque = torque * total_ratio
	# Tuned for realistic acceleration and top speed
	return wheel_torque / 13.0

func _update_engine_rpm(wheel_rpm: float, delta: float):
	var rpm_scale = 10.0       # controls gear speed span
	var rpm_smooth_up = 2.5
	var rpm_smooth_down = 1.2

	var target_rpm: float = float(idle_rpm)

	if gear_mode == "N":
		target_rpm = float(idle_rpm)
	elif gear_mode == "R":
		target_rpm = float(idle_rpm) + float(wheel_rpm * rpm_scale * 0.1)
	elif gear_mode == "D":
		var gear_ratio = gear_ratios[current_gear - 1]
		target_rpm = float(wheel_rpm * gear_ratio * final_drive_ratio * rpm_scale)
		target_rpm = clamp(target_rpm, float(idle_rpm), float(max_rpm))
	else:
		target_rpm = float(idle_rpm)

	# Simulate realistic engine inertia
	if target_rpm > current_rpm:
		current_rpm = lerp(float(current_rpm), float(target_rpm), delta * rpm_smooth_up)
	else:
		current_rpm = lerp(float(current_rpm), float(target_rpm), delta * rpm_smooth_down)

func _handle_automatic_shifting():
	if gear_mode != "D":
		return

	if shift_timer > 0:
		shift_timer -= get_physics_process_delta_time()
		return

	# Speed thresholds per gear (in km/h)
	var shift_speeds = [22.0, 42.0, 62.0, 82.0, 102.0]

	# Get current speed
	var speed = linear_velocity.length() * 3.6

	# Upshift logic
	if current_gear < max_gears and speed > shift_speeds[current_gear - 1]:
		current_gear += 1
		current_rpm *= 0.6
		shift_timer = shift_delay

	# Downshift logic
	elif current_gear > 1 and speed < (shift_speeds[current_gear - 2] - 5.0):
		current_gear -= 1
		current_rpm = clamp(current_rpm * 1.2, idle_rpm, max_rpm)
		shift_timer = shift_delay

func _apply_engine_drag(_delta: float):
	if acceleration_input == 0 and gear_mode == "D":
		var drag = engine_drag * linear_velocity.length()
		apply_central_force(-linear_velocity.normalized() * drag)

# Gear management
func _cycle_gear_mode():
	match gear_mode:
		"P":
			gear_mode = "R"
		"R":
			gear_mode = "N"
		"N":
			gear_mode = "D"
		"D":
			gear_mode = "P"

func _get_display_gear() -> String:
	if gear_mode == "D":
		return "D" + str(current_gear)
	else:
		return gear_mode

func _ready():
	set_pov(false)

# Debugging
#func _print_debug(speed):
	#print("-------------------------------")
	#print("Speed: ", snapped(speed, 0.1), " km/h")
	#print("Gear Mode: ", gear_mode)
	#print("Current Gear: ", current_gear)
	#print("RPM: ", int(current_rpm))
	#print("Torque: ", snapped(engine_torque, 0.1))
	#print("-------------------------------")
