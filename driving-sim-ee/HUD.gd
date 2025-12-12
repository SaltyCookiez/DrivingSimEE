extends CanvasLayer

@onready var speed_label: Label = $HUDPanel/SpeedLabel
@onready var gear_label: Label = $HUDPanel/GearLabel

func update_speed(speed: float) -> void:
	speed_label.text = "%d %s" % [int(speed), tr("HUD_KMH")]

func update_gear(gear: String) -> void:
	gear_label.text = "%s: %s" % [tr("HUD_GEAR"), gear]
