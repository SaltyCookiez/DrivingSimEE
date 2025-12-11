extends Node3D

signal stop_evaluated(correct: bool, stopped_time: float)

@export var required_stop_time: float = 1.0
@export var stop_speed: float = 1.0

@onready var detection_area: Area3D = $DetectionArea

var _car: Node3D = null
var _car_inside := false
var _stopped_time: float = 0.0

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("car"):
		return

	_car = body
	_car_inside = true
	_stopped_time = 0.0

func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("car"):
		return

	_car_inside = false

	var correct := _stopped_time >= required_stop_time
	if correct:
		TrafficStats.stop_correct += 1
		print("STOP: Õige, peatus ", _stopped_time, "s")
	else:
		TrafficStats.stop_wrong += 1
		print("STOP: Vale, peatus ", _stopped_time, "s")

	stop_evaluated.emit(correct, _stopped_time)
	_car = null

func _physics_process(delta: float) -> void:
	if not _car_inside or _car == null:
		return

	var current_speed := 999999.0
	if _car.has_method("get_speed_kmh"):
		current_speed = float(_car.call("get_speed_kmh"))
	elif "speed_kmh" in _car:
		current_speed = float(_car.speed_kmh)

	if abs(current_speed) <= stop_speed:
		_stopped_time += delta
