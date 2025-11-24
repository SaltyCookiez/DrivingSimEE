extends Area3D

# Supposed speed for the car stop
@export var stop_speed_threshold: float = 0.5

# Supposed time the car needs to stand still before the STOP sign
@export var required_stop_time: float = 1.0

var car: Node3D = null
var time_below_threshold: float = 0.0
var car_has_stopped: bool = false

func _body_entered(body: Node3D) -> void:
	# Check if the body is car
	if body.is_in_group("car"):
		car = body
		time_below_threshold = 0.0
		car_has_stopped = false
		# Print debug for testing rn
		print("Car is at the stop sign")

func _body_exited(body: Node3D) -> void:
	# Adding additional debug for testing
	if body == car:
		print("Car stopped in front of stop sign")
	else:
		print("Car ignored the stop sign and didn't stop")
	car = null
