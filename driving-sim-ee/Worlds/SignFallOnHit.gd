extends Area3D

@export var target_to_fall: NodePath = NodePath("..")
@export var fall_angle_deg: float = 90.0
@export var fall_time: float = 0.35

var _fallen := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if _fallen:
		return
	if body == null or not body.is_in_group("car"):
		return

	_fallen = true

	var target := get_node_or_null(target_to_fall) as Node3D
	if target == null:
		return

	_disable_collisions(target)

	var tween := create_tween()
	var start_rot := target.rotation_degrees
	var end_rot := start_rot + Vector3(fall_angle_deg, 0.0, 0.0)
	tween.tween_property(target, "rotation_degrees", end_rot, fall_time)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _disable_collisions(root: Node) -> void:
	for n in root.get_children():
		if n is CollisionShape3D:
			(n as CollisionShape3D).disabled = true
		_disable_collisions(n)
