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
	$CamArm.position = position
	
	var gear = "D"
	var speed = linear_velocity.length() * 3.6
	var dir = Input.get_action_strength("Gas") - Input.get_action_strength("Brake")
	var steering_dir = Input.get_action_strength("Left") - Input.get_action_strength("Right")
	
	var RPM_left = abs($wheel_back_left.get_rpm())
	var RPM_right = abs($wheel_back_right.get_rpm())
	var RPM = (RPM_left + RPM_right) / 2.0
	
	var torque = dir * max_torque * (1.0 - RPM / max_RPM)
	
	engine_force = torque
	steering = lerp(steering, steering_dir * turn_amount, turn_speed * delta)
	
	hud.update_speed(speed)
	hud.update_gear(gear)
	
	if dir == 0:
		brake = 2
