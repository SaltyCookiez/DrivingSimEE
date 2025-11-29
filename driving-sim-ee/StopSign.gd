extends Node3D

@export var required_stop_time: float = 1.0
@export var stop_speed_threshold_kmh: float = 1.0

@onready var detection_area: Area3D = $DetectionArea

var _car: Node3D = null
var _car_inside := false
var _stopped_time: float = 0.0

func body_entered(body: Node3D) -> void:
	if not body.is_in_group("car"):
		return

	_car = body
	_car_inside = true
	_stopped_time = 0.0

func body_exited(body: Node3D) -> void:
	if not body.is_in_group("car"):
		return

	_car_inside = false

	if _stopped_time >= required_stop_time:
		TrafficStats.stop_correct += 1
		print("STOP: Õige, peatus", _stopped_time, "seconds")
	else:
		TrafficStats.stop_wrong += 1
		print("STOP: Vale, peatus", _stopped_time, "seconds")

	_car = null

func _ready() -> void:
	detection_area.body_entered.connect(body_entered)
	detection_area.body_exited.connect(body_exited)

func _physics_process(delta: float) -> void:
	if not _car_inside or _car == null:
		return

	if not _car.has_variable("speed_kmh"):
		return

	var current_speed = _car.speed_kmh

	if abs(current_speed) <= stop_speed_threshold_kmh:
		_stopped_time += delta
