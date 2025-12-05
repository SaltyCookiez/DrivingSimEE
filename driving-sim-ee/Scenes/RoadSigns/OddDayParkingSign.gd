extends Node3D

@export var parking_detect_time: float = 5.0
@export var parking_speed: float = 2.0

@onready var detection_area: Area3D = $DetectionArea

var _car: Node3D = null
var _car_inside := false
var _stopped_time: float = 0.0
var _already_reported: bool = false
var _car_has_parked: bool = false

func _ready() -> void:
	detection_area.body_entered.connect(body_entered)
	detection_area.body_exited.connect(body_exited)

func body_entered(body: Node3D) -> void:
	if not body.is_in_group("car"):
		return

	_car = body
	_car_inside = true
	_stopped_time = 0.0
	_already_reported = false

func body_exited(body: Node3D) -> void:
	if body != _car:
		return

	if not _car_has_parked:
		TrafficStats.odd_parking_ok += 1
		print("NO-PARKING ODD DAY: car passed without parking")

	_car_inside = false
	_car = null
	_stopped_time = 0.0
	_already_reported = false

func _physics_process(delta: float) -> void:
	if not _car_inside or _car == null:
		return

	var current_speed: float = abs(_car.speed_kmh)

	if current_speed > parking_speed:
		_stopped_time = 0.0
		return

	_stopped_time += delta

	if _stopped_time >= parking_detect_time and not _already_reported:
		_already_reported = true

		var is_odd_day_now: bool = TrafficStats.is_odd_day()

		if is_odd_day_now:
			TrafficStats.odd_parking_correct += 1
			print("NO-PARKING ODD DAY: violation (parked for ", _stopped_time, " sec)")
		else:
			TrafficStats.odd_parking_wrong += 1
			print("NO-PARKING: allowed parking today")
