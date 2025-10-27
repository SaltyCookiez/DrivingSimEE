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
