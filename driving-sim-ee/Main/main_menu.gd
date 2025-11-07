extends Control

func _ready():
	$CenterContainer/VBoxContainer/BtnSandbox.pressed.connect(_on_sandbox_pressed)
	$CenterContainer/VBoxContainer/BtnTestLesson.pressed.connect(_on_test_lesson_pressed)
	$CenterContainer/VBoxContainer/BtnQuit.pressed.connect(_on_quit_pressed)

func _on_sandbox_pressed():
	get_parent().load_level("res://Worlds/world.tscn")

func _on_test_lesson_pressed():
	get_parent().load_level("res://Worlds/test_lesson.tscn")

func _on_quit_pressed():
	get_tree().quit()
