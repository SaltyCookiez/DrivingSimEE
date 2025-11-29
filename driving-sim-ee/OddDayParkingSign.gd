extends Node3D

# Attach to sign later

@export var parking_detect_time: float = 5.0
@export var parking_speed: float = 2.0

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

	var was_parking := _stopped_time >= parking_detect_time
	var is_odd_day_now := TrafficStats.is_odd_day()

	if was_parking:
		if is_odd_day_now:
			TrafficStats.odd_parking_violation += 1
			print("Odd-day NO-PARKING: violation, parked for", _stopped_time, "seconds")
		else:
			TrafficStats.odd_parking_ok += 1
			print("Odd-day NO-PARKING: parked but day is allowed")
	else:
		# Car passed through without parking
		TrafficStats.odd_parking_ok += 1
		print("Odd-day NO-PARKING: did not park")

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

	if abs(current_speed) <= parking_speed:
		_stopped_time += delta
	else:
		# Reset if car moves again
		_stopped_time = 0.0
