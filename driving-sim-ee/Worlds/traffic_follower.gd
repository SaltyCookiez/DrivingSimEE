extends PathFollow3D

@export var speed_kmh: float = 10.0

func _ready() -> void:
	loop = true

func _physics_process(delta: float) -> void:
	var speed_mps := speed_kmh / 3.6

	progress += speed_mps * delta
