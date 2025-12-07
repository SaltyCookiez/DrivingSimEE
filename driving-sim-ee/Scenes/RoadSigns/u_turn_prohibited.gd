extends Node3D

@onready var detection_area: Area3D = $DetectionArea
var _triggered := false  # double counting fix

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("car"):
		return
	if _triggered:
		return
	_triggered = true

	TrafficStats.u_turn_wrong += 1

	print("Sign fault detected")

func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("car"):
		return
	_triggered = false
