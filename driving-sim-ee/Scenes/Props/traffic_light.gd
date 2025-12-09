extends Node3D

enum Phase { RED, RED_YELLOW, GREEN, YELLOW }

@onready var red_lamp: MeshInstance3D = $RedLamp
@onready var yellow_lamp: MeshInstance3D = $YellowLamp
@onready var green_lamp: MeshInstance3D = $GreenLamp

@export var inverted: bool = false

@export var red_time: float = 10.0
@export var red_yellow_time: float = 2.0
@export var green_time: float = 10.0
@export var yellow_time: float = 2.0

var red_off    := Color.from_string("#680000", Color.BLACK)
var yellow_off := Color.from_string("#6e5500", Color.BLACK)
var green_off  := Color.from_string("#005f08", Color.BLACK)

var red_on     := Color.from_string("#ff0000", Color.BLACK)
var yellow_on  := Color.from_string("#ffb700", Color.BLACK)
var green_on   := Color.from_string("#00ff15", Color.BLACK)

@export var emission_energy_on: float = 1.8

var _phase: Phase = Phase.RED

func _ready() -> void:
	_make_lamp_materials_unique()
	_apply_phase(Phase.RED)

func _process(_delta: float) -> void:
	var new_phase := _get_phase_from_shared_clock()
	if new_phase != _phase:
		_apply_phase(new_phase)

func _cycle_len() -> float:
	return red_time + red_yellow_time + green_time + yellow_time

func _get_phase_from_shared_clock() -> Phase:
	var cycle := _cycle_len()
	if cycle <= 0.0:
		return Phase.RED

	var offset := (red_time + red_yellow_time) if inverted else 0.0

	var tt := fposmod(TrafficLightClock.t + offset, cycle)

	if tt < red_time:
		return Phase.RED
	tt -= red_time

	if tt < red_yellow_time:
		return Phase.RED_YELLOW
	tt -= red_yellow_time

	if tt < green_time:
		return Phase.GREEN

	return Phase.YELLOW

func _apply_phase(p: Phase) -> void:
	_phase = p

	_lamp_off(red_lamp, red_off)
	_lamp_off(yellow_lamp, yellow_off)
	_lamp_off(green_lamp, green_off)

	match p:
		Phase.RED:
			_lamp_on(red_lamp, red_on)
		Phase.RED_YELLOW:
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

func _make_lamp_materials_unique() -> void:
	var m = red_lamp.get_active_material(0)
	if m: red_lamp.set_surface_override_material(0, m.duplicate(true))
	m = yellow_lamp.get_active_material(0)
	if m: yellow_lamp.set_surface_override_material(0, m.duplicate(true))
	m = green_lamp.get_active_material(0)
	if m: green_lamp.set_surface_override_material(0, m.duplicate(true))
