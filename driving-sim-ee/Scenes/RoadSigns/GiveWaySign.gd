extends Node3D

# Attach to sign later

@export var slow_down: float = 10
@onready var detection_area: Area3D = $DetectionArea

var _car: Node3D = null
var _car_inside := false
var _min_speed_in_area: float = 9999

func body_entered(body: Node3D) -> void:
	if not body.is_in_group("car"):
		return
	
	_car = body
	_car_inside = true
	_min_speed_in_area = 9999
	
func body_exited(body: Node3D) -> void:
	if not body.is_in_group("car"):
		return
		
	_car_inside = false
	
	# Check
	if _min_speed_in_area <= slow_down:
		TrafficStats.give_way_correct += 1
		print("Anna teed: Õige, min kiirus:", _min_speed_in_area)
	else:
		TrafficStats.give_way_wrong += 1
		print("Anna teed: Vale, min kiirus:", _min_speed_in_area)

	_car = null

func _ready() -> void:
	detection_area.body_entered.connect(body_entered)
	detection_area.body_exited.connect(body_exited)
	
func _physics_process(_delta: float) -> void:
	if not _car_inside or _car == null:
		return
	
	if not _car.has_variable("speed_kmh"):
		return
	
	var current_speed = _car.speed_kmh
	if current_speed < _min_speed_in_area:
		_min_speed_in_area = current_speed
