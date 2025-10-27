extends VehicleBody3D

@onready var hud = get_node("/root/World/HUD")

# Engine & Transmission
var gear_ratios = [2.97, 2.07, 1.43, 1.00, 0.84, 0.56]
var final_drive_ratio = 3.42
var current_gear = 1
var max_gears = 6

var upshift_rpm = 4200
var downshift_rpm = 1700

var idle_rpm = 800
var max_rpm = 1700
var current_rpm = idle_rpm

var engine_torque = 0.0
var base_torque = 350.0
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

#
# Main Process
#

func _physics_process(delta):
	
	# Sync camera position
	cam_arm.position = position
	
	# Get inputs
	acceleration_input = Input.get_action_strength("Gas")
	brake_input = Input.get_action_strength("Brake")
	var steering_dir = Input.get_action_strength("Left") - Input.get_action_strength("Right")
	
	# Detect if reverse or neutral gear
	if Input.is_action_just_pressed("ui_page_up"):
		_cycle_gear_mode()
	
	# Calculate speed
	var speed = linear_velocity.length() * 3.6
	
	# Compute wheel RPMs and average for engine
	var wheel_rpm_left = abs($wheel_back_left.get_rpm())
	var wheel_rpm_right = abs($wheel_back_right.get_rpm())
	var wheel_rpm = (wheel_rpm_left + wheel_rpm_right) / 2.0
	
	# Update engine RPM based on wheel RPM
	_update_engine_rpm(wheel_rpm, delta)
	
	# Automatic transmission shifting
	if gear_mode == "D":
		_handle_automatic_shifting()
		
	# Calculate torque and apply
	engine_torque = _calculate_engine_torque(current_rpm)
	var torque_output = _calculate_engine_force(engine_torque)
	
	engine_force = torque_output * acceleration_input
	steering = lerp(steering, steering_dir * steering_sensitivity, steering_lerp_speed * delta)
	
	# Basic braking logic
	if acceleration_input == 0 and brake_input > 0:
		brake = brake_force * brake_input
	else:
		brake = 0.0
	
	# Apply engine drag
	_apply_engine_drag(delta)
	
	# Update HUD
	hud.update_speed(speed)
	hud.update_gear(_get_display_gear())
	
	# Debug
	if debug_enabled:
		_print_debug(speed)

#
# Engine and Transmission
#

func _calculate_engine_torque(rpm: float) -> float:
	# Simulate torque
	var mid_rpm = max_rpm * 0.5
	var torque_factor = 1.0 - pow((rpm - mid_rpm) / mid_rpm, 2)
	torque_factor = clamp(torque_factor, 0.0, 1.0)
	return base_torque * torque_factor

func _calculate_engine_force(torque: float) -> float:
	# Calculate wheel torque
	var gear_ratio = gear_ratios[current_gear - 1] if current_gear > 0 else 0
	var total_ratio = gear_ratio * final_drive_ratio
	var wheel_torque = torque * total_ratio
	return wheel_torque / 100.0 # Scale factor

func _update_engine_rpm(wheel_rpm: float, delta: float):
	if gear_mode == "N":
		current_rpm = lerp(current_gear, idle_rpm, delta * 3)
	elif gear_mode == "R":
		current_rpm = idle_rpm + (wheel_rpm * 0.1)
	elif gear_mode == "D":
		var gear_ratio = gear_ratios[current_gear - 1]
		var target_rpm = wheel_rpm * gear_ratio * final_drive_ratio
		current_rpm = clamp(lerp(current_rpm, target_rpm, delta * 5), idle_rpm, max_rpm)
	else:
		current_rpm = idle_rpm

func _handle_automatic_shifting():
	if current_rpm > upshift_rpm and current_gear < max_gears:
		current_gear += 1
	elif current_rpm < downshift_rpm and current_gear > 1:
		current_gear -= 1

func _apply_engine_drag(delta: float):
	# Applies a small deceleration when throttle is released
	if acceleration_input == 0 and gear_mode == "D":
		var drag = engine_drag * linear_velocity.length()
		apply_central_force(-linear_velocity.normalized() * drag)

#
# Gear managment
#

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
