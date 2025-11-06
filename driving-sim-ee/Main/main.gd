extends Node

@onready var level_container = $LevelContainer
@onready var hud = $HUD
@onready var main_menu = $MainMenu
@onready var pause_menu = $PauseMenu

var current_level: Node = null

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

	hud.visible = true
	main_menu.visible = false
	pause_menu.visible = false
	get_tree().paused = false

func _on_BtnSandbox_pressed():
	load_level("res://Worlds/world.tscn")

func _on_BtnTestLesson_pressed():
	load_level("res://Worlds/test_lesson.tscn")

func _on_BtnQuit_pressed():
	get_tree().quit()
