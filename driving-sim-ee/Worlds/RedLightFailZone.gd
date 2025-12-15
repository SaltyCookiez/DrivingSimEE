extends Area3D

var traffic_light: Node3D = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var lights := get_tree().get_nodes_in_group("traffic_light")
	if lights.is_empty():
		push_error("RedLightFailZone: No node in group 'traffic_light' found.")
		traffic_light = null
	else:
		traffic_light = lights[0] as Node3D

func _process(_delta: float) -> void:
	if traffic_light == null:
		monitoring = true
		monitorable = true
		return

	monitoring = not traffic_light.is_green()
	monitorable = monitoring
