extends Control

func _ready():
	$CenterContainer/VBoxContainer/BtnSandbox.pressed.connect(_on_sandbox_pressed)
	$CenterContainer/VBoxContainer/BtnTestLesson.pressed.connect(_on_test_lesson_pressed)
	$CenterContainer/VBoxContainer/BtnLesson1.pressed.connect(_on_lesson_1_pressed)
	$CenterContainer/VBoxContainer/BtnLesson2.pressed.connect(_on_lesson_2_pressed)
	$CenterContainer/VBoxContainer/BtnLesson3.pressed.connect(_on_lesson_3_pressed)
	$CenterContainer/VBoxContainer/BtnLesson4.pressed.connect(_on_lesson_4_pressed)
	$CenterContainer/VBoxContainer/BtnLesson5.pressed.connect(_on_lesson_5_pressed)
	$CenterContainer/VBoxContainer/BtnLesson6.pressed.connect(_on_lesson_6_pressed)
	$CenterContainer/VBoxContainer/BtnLesson7.pressed.connect(_on_lesson_7_pressed)
	$CenterContainer/VBoxContainer/BtnLesson8.pressed.connect(_on_lesson_8_pressed)
	$CenterContainer/VBoxContainer/BtnLesson9.pressed.connect(_on_lesson_9_pressed)
	$CenterContainer/VBoxContainer/BtnQuit.pressed.connect(_on_quit_pressed)

func _on_lesson_1_pressed():
	get_parent().set_lesson(1)
	get_parent().load_level("res://Worlds/test_lesson.tscn")

func _on_lesson_2_pressed():
	get_parent().set_lesson(2)
	get_parent().load_level("res://Worlds/test_lesson.tscn")

func _on_lesson_3_pressed():
	get_parent().set_lesson(3)
	get_parent().load_level("res://Worlds/test_lesson.tscn")

func _on_lesson_4_pressed():
	get_parent().set_lesson(4)
	get_parent().load_level("res://Worlds/test_lesson.tscn")
	
func _on_lesson_5_pressed():
	get_parent().set_lesson(5)
	get_parent().load_level("res://Worlds/test_lesson.tscn")
	
func _on_lesson_6_pressed():
	get_parent().set_lesson(6)
	get_parent().load_level("res://Worlds/test_lesson.tscn")
	
func _on_lesson_7_pressed():
	get_parent().set_lesson(7)
	get_parent().load_level("res://Worlds/test_lesson.tscn")
	
func _on_lesson_8_pressed():
	get_parent().set_lesson(8)
	get_parent().load_level("res://Worlds/test_lesson.tscn")
	
func _on_lesson_9_pressed():
	get_parent().set_lesson(9)
	get_parent().load_level("res://Worlds/test_lesson.tscn")

func _on_sandbox_pressed():
	get_parent().load_level("res://Worlds/world.tscn")

func _on_test_lesson_pressed():
	get_parent().load_level("res://Worlds/test_lesson.tscn")

func _on_quit_pressed():
	get_tree().quit()
