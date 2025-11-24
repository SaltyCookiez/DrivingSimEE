extends Area3D

# Supposed speed for the car stop
@export var stop_speed_threshold: float = 0.5

# Supposed time the car needs to stand still before the STOP sign
@export var required_stop_time: float = 1.0

var car: Node3D = null
var time_below_threshold: float = 0.0
var car_has_stopped: bool = false
