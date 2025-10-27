extends VehicleBody3D

@onready var hud = get_node("/root/World/HUD")

# Engine & Transmission
var gear_ratios = [2.97, 2.07, 1.43, 1.00, 0.84, 0.56]
var final_drive_ratio = 3.42
var current_gear = 1
var max_gears = 6

var upshift_rpm = 4000
var downshift_rpm = 2000
var shift_delay = 0.5
var shift_timer = 0.0

var idle_rpm = 800
var max_rpm = 5000
var current_rpm = idle_rpm

var engine_torque = 0.0
var base_torque = 500.0
var engine_drag = 0.015

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
@onready var cam_arm = $CamArm


# Anti-roll system
func _apply_anti_roll_bar():
	var anti_roll_strength = 8000.0

	# Front suspension travel
	var travel_fl = 1.0 - $wheel_front_left.get_suspension_travel() / $wheel_front_left.suspension_travel
	var travel_fr = 1.0 - $wheel_front_right.get_suspension_travel() / $wheel_front_right.suspension_travel

	# Back suspension travel
	var travel_rl = 1.0 - $wheel_back_left.get_suspension_travel() / $wheel_back_left.suspension_travel
	var travel_rr = 1.0 - $wheel_back_right.get_suspension_travel() / $wheel_back_right.suspension_travel

	# Front anti-roll
	var anti_roll_front = (travel_fl - travel_fr) * anti_roll_strength
	if $wheel_front_left.is_in_contact():
		apply_central_force($wheel_front_left.global_transform.basis.y * -anti_roll_front)
	if $wheel_front_right.is_in_contact():
		apply_central_force($wheel_front_right.global_transform.basis.y * anti_roll_front)

	# Rear anti-roll
	var anti_roll_rear = (travel_rl - travel_rr) * anti_roll_strength
	if $wheel_back_left.is_in_contact():
		apply_central_force($wheel_back_left.global_transform.basis.y * -anti_roll_rear)
	if $wheel_back_right.is_in_contact():
		apply_central_force($wheel_back_right.global_transform.basis.y * anti_roll_rear)


func _physics_process(delta):
	# Camera follow
	cam_arm.position = position

	# Inputs
	acceleration_input = Input.get_action_strength("Gas")   # W
	brake_input = Input.get_action_strength("Brake")         # S
	var steering_dir = Input.get_action_strength("Left") - Input.get_action_strength("Right")

	# Manual gear mode switching
	if Input.is_action_just_pressed("ui_page_up"):
		_cycle_gear_mode()

	# Vehicle speed in km/h
	var speed = linear_velocity.length() * 3.6
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

	# Aerodynamic downforce
	var downforce = linear_velocity.length() * 2.5
	apply_central_force(-transform.basis.y * downforce)

	# Engine and transmission
	_update_engine_rpm(wheel_rpm, delta)
	if gear_mode == "D":
		_handle_automatic_shifting()

	engine_torque = _calculate_engine_torque(current_rpm)
	var torque_output = _calculate_engine_force(engine_torque)

	# Engine force and braking behavior
	if gear_mode == "D":
		# Normal forward driving
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
			# When holding W in reverse, apply braking torque
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

	# Extra downforce for high-speed stability
	var downforce_factor = 10.0
	apply_central_force(-transform.basis.y * linear_velocity.length() * downforce_factor)

	# Engine drag
	_apply_engine_drag(delta)

	# HUD updates (negative speed when reversing)
	if gear_mode == "R":
		hud.update_speed(-speed)
	else:
		hud.update_speed(speed)
	hud.update_gear(_get_display_gear())

	# Anti-roll bar
	_apply_anti_roll_bar()

	# Debug info
	if debug_enabled:
		_print_debug(speed)

# Engine and Transmission
func _calculate_engine_torque(rpm: float) -> float:
	var mid_rpm = max_rpm * 0.55
	var torque_factor = 1.0 - pow((rpm - mid_rpm) / (mid_rpm * 1.5), 2)
	torque_factor = clamp(torque_factor, 0.0, 1.0)
	var min_torque = 5.0
	return base_torque * torque_factor + min_torque


func _calculate_engine_force(torque: float) -> float:
	var gear_ratio = gear_ratios[current_gear - 1] if current_gear > 0 else 0
	var total_ratio = gear_ratio * final_drive_ratio
	var wheel_torque = torque * total_ratio
	return wheel_torque / 5.0


func _update_engine_rpm(wheel_rpm: float, delta: float):
	var rpm_scale = 80.0
	
	if gear_mode == "N":
		current_rpm = lerp(float(current_rpm), float(idle_rpm), delta * 3.0)
	elif gear_mode == "R":
		current_rpm = float(idle_rpm) + (wheel_rpm * rpm_scale * 0.1)
	elif gear_mode == "D":
		var gear_ratio = gear_ratios[current_gear - 1]
		var target_rpm: float = wheel_rpm * gear_ratio * final_drive_ratio * rpm_scale
		current_rpm = clamp(
			lerp(float(current_rpm), target_rpm, delta * 5.0),
			float(idle_rpm),
			float(max_rpm)
		)
	else:
		current_rpm = float(idle_rpm)


func _handle_automatic_shifting():
	if gear_mode != "D":
		return

	if shift_timer > 0:
		shift_timer -= get_physics_process_delta_time()
		return

	if current_rpm > upshift_rpm and current_gear < max_gears:
		current_gear += 1
		current_rpm *= 0.6
		shift_timer = shift_delay
	elif current_rpm < downshift_rpm and current_gear > 1:
		current_gear -= 1
		current_rpm = clamp(current_rpm * 1.3, idle_rpm, max_rpm)
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


# Debugging
func _print_debug(speed):
	print("-------------------------------")
	print("Speed: ", snapped(speed, 0.1), " km/h")
	print("Gear Mode: ", gear_mode)
	print("Current Gear: ", current_gear)
	print("RPM: ", int(current_rpm))
	print("Torque: ", snapped(engine_torque, 0.1))
	print("-------------------------------")
