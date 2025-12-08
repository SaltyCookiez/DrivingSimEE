extends Node3D

enum Phase { RED, RED_YELLOW, GREEN, YELLOW }

@onready var red_lamp: MeshInstance3D = $RedLamp
@onready var yellow_lamp: MeshInstance3D = $YellowLamp
@onready var green_lamp: MeshInstance3D = $GreenLamp

# light timing in sec
@export var red_time: float = 2.0
@export var red_yellow_time: float = 2.0
@export var green_time: float = 10.0
@export var yellow_time: float = 3.0 

# colours
var red_off    := Color.from_string("#680000", Color.BLACK)
var yellow_off := Color.from_string("#6e5500", Color.BLACK)
var green_off  := Color.from_string("#005f08", Color.BLACK)

var red_on     := Color.from_string("#ff0000", Color.BLACK)
var yellow_on  := Color.from_string("#ffb700", Color.BLACK)
var green_on   := Color.from_string("#00ff15", Color.BLACK)

@export var emission_energy_on: float = 1.8

var _phase: Phase = Phase.RED
var _timer: float = 0.0

func _ready() -> void:
	_set_phase(Phase.RED)

func _process(delta: float) -> void:
	_timer += delta

	match _phase:
		Phase.RED:
			if _timer >= red_time:
				_set_phase(Phase.RED_YELLOW)
		Phase.RED_YELLOW:
			if _timer >= red_yellow_time:
				_set_phase(Phase.GREEN)
		Phase.GREEN:
			if _timer >= green_time:
				_set_phase(Phase.YELLOW)
		Phase.YELLOW:
			if _timer >= yellow_time:
				_set_phase(Phase.RED)

func _set_phase(new_phase: Phase) -> void:
	_phase = new_phase
	_timer = 0.0

	# default all off
	_lamp_off(red_lamp, red_off)
	_lamp_off(yellow_lamp, yellow_off)
	_lamp_off(green_lamp, green_off)

	match new_phase:
		Phase.RED:
			_lamp_on(red_lamp, red_on)
		Phase.RED_YELLOW:
			# eu standard
			_lamp_on(red_lamp, red_on)
			_lamp_on(yellow_lamp, yellow_on)
		Phase.GREEN:
			_lamp_on(green_lamp, green_on)
		Phase.YELLOW:
			_lamp_on(yellow_lamp, yellow_on)

func _lamp_on(lamp: MeshInstance3D, color: Color) -> void:
	var mat := lamp.get_active_material(0)
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy = emission_energy_on

func _lamp_off(lamp: MeshInstance3D, base_color: Color) -> void:
	var mat := lamp.get_active_material(0)
	mat.albedo_color = base_color
	mat.emission_enabled = false
	mat.emission = Color(0, 0, 0)
	mat.emission_energy = 0.0
