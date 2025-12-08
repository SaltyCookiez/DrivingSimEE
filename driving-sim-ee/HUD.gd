extends CanvasLayer

@onready var speed_label: Label = $HUDPanel/SpeedLabel
@onready var gear_label: Label = $HUDPanel/GearLabel

func update_speed(speed: float):
	speed_label.text = str(int(speed)) + " km/h"

func update_gear(gear: String):
	gear_label.text = "Gear: " + gear
