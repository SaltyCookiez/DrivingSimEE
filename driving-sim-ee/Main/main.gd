extends Node

@onready var level_container = $LevelContainer
# @onready var car = $Car
@onready var hud = $HUD
@onready var main_menu = $MainMenu
@onready var pause_menu = $PauseMenu

var current_level: Node = null
var current_lesson_id: int = 0

func set_lesson(id: int) -> void:
	current_lesson_id = id

func return_to_menu() -> void:
	if current_level:
		current_level.queue_free()
		current_level = null

	get_tree().paused = false
	hud.visible = false
	main_menu.visible = true
	pause_menu.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _ready():
	print("Main scene loaded")
	
	hud.visible = false
	main_menu.visible = true
	pause_menu.visible = false

func _process(_delta):
	if Input.is_action_just_pressed("Pause_game"):
		_toggle_pause()

func _toggle_pause():
	if main_menu.visible:
		return

	if get_tree().paused:
		get_tree().paused = false
		pause_menu.hide_menu()
		hud.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		get_tree().paused = true
		pause_menu.show_menu()
		hud.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func load_level(path: String):
	if current_level:
		current_level.queue_free()

	var new_scene = load(path).instantiate()
	level_container.add_child(new_scene)
	current_level = new_scene
	
	var car = new_scene.get_node_or_null("CarRoot")

	if car:
		car.set_hud(hud)
	else:
		print("WARNING: Car not found")

	hud.visible = true
	main_menu.visible = false
	pause_menu.visible = false
	get_tree().paused = false

func start_lesson(lesson_id: int) -> void:
	GameState.selected_lesson_id = lesson_id
	load_level("res://Worlds/test_lesson.tscn")

func _on_BtnSandbox_pressed():
	load_level("res://Worlds/world.tscn")

func _on_BtnTestLesson_pressed():
	load_level("res://Worlds/test_lesson.tscn")

func _on_BtnLesson1_pressed():
	current_lesson_id = 1
	load_level("res://Worlds/test_lesson.tscn")

func _on_BtnLesson2_pressed():
	current_lesson_id = 2
	load_level("res://Worlds/test_lesson.tscn")

func _on_BtnLesson3_pressed():
	current_lesson_id = 3
	load_level("res://Worlds/test_lesson.tscn")

func _on_BtnLesson4_pressed():
	current_lesson_id = 4
	load_level("res://Worlds/test_lesson.tscn")
	
func _on_BtnLesson5_pressed():
	current_lesson_id = 5
	load_level("res://Worlds/test_lesson.tscn")
	
func _on_BtnLesson6_pressed():
	current_lesson_id = 6
	load_level("res://Worlds/test_lesson.tscn")
	
func _on_BtnLesson7_pressed():
	current_lesson_id = 7
	load_level("res://Worlds/test_lesson.tscn")
	
func _on_BtnLesson8_pressed():
	current_lesson_id = 8
	load_level("res://Worlds/test_lesson.tscn")
	
func _on_BtnLesson9_pressed():
	current_lesson_id = 9
	load_level("res://Worlds/test_lesson.tscn")

func _on_BtnQuit_pressed():
	get_tree().quit()
