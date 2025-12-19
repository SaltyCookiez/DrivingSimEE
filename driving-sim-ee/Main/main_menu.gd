extends Control

@onready var lbl_language: Label = $CenterContainer/VBoxContainer/HBoxContainer/LabelLanguage
@onready var opt_language: OptionButton = $CenterContainer/VBoxContainer/HBoxContainer/OptionLanguage

@onready var btn_sandbox: Button = $CenterContainer/VBoxContainer/BtnSandbox
@onready var btn_test_lesson: Button = $CenterContainer/VBoxContainer/BtnTestLesson
@onready var btn_lesson_1: Button = $CenterContainer/VBoxContainer/BtnLesson1
@onready var btn_lesson_2: Button = $CenterContainer/VBoxContainer/BtnLesson2
@onready var btn_lesson_3: Button = $CenterContainer/VBoxContainer/BtnLesson3
@onready var btn_lesson_4: Button = $CenterContainer/VBoxContainer/BtnLesson4
@onready var btn_lesson_5: Button = $CenterContainer/VBoxContainer/BtnLesson5
@onready var btn_lesson_6: Button = $CenterContainer/VBoxContainer/BtnLesson6
@onready var btn_lesson_7: Button = $CenterContainer/VBoxContainer/BtnLesson7
@onready var btn_lesson_8: Button = $CenterContainer/VBoxContainer/BtnLesson8
@onready var btn_lesson_9: Button = $CenterContainer/VBoxContainer/BtnLesson9
@onready var btn_quit: Button = $CenterContainer/VBoxContainer/BtnQuit


func _ready() -> void:
	btn_sandbox.pressed.connect(_on_sandbox_pressed)
	btn_test_lesson.pressed.connect(_on_test_lesson_pressed)
	btn_lesson_1.pressed.connect(_on_lesson_1_pressed)
	btn_lesson_2.pressed.connect(_on_lesson_2_pressed)
	btn_lesson_3.pressed.connect(_on_lesson_3_pressed)
	btn_lesson_4.pressed.connect(_on_lesson_4_pressed)
	btn_lesson_5.pressed.connect(_on_lesson_5_pressed)
	btn_lesson_6.pressed.connect(_on_lesson_6_pressed)
	btn_lesson_7.pressed.connect(_on_lesson_7_pressed)
	btn_lesson_8.pressed.connect(_on_lesson_8_pressed)
	btn_lesson_9.pressed.connect(_on_lesson_9_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)

	_setup_language_dropdown()
	_refresh_all_texts()


func _setup_language_dropdown() -> void:
	opt_language.clear()
	opt_language.add_item("English", 0)
	opt_language.add_item("Eesti", 1)

	var loc := TranslationServer.get_locale()
	if loc.begins_with("et"):
		opt_language.select(1)
	else:
		opt_language.select(0)

	opt_language.item_selected.connect(_on_language_selected)


func _on_language_selected(index: int) -> void:
	match index:
		0:
			TranslationServer.set_locale("en")
		1:
			TranslationServer.set_locale("et")

	_refresh_all_texts()


func _refresh_all_texts() -> void:
	lbl_language.text = tr("UI_LANGUAGE")

	var keep := opt_language.selected
	opt_language.set_item_text(0, tr("UI_ENGLISH"))
	opt_language.set_item_text(1, tr("UI_ESTONIAN"))
	opt_language.select(keep)

	btn_sandbox.text = tr("UI_SANDBOX")
	btn_test_lesson.text = tr("UI_TEST_LESSON")
	btn_lesson_1.text = tr("UI_LESSON_1")
	btn_lesson_2.text = tr("UI_LESSON_2")
	btn_lesson_3.text = tr("UI_LESSON_3")
	btn_lesson_4.text = tr("UI_LESSON_4")
	btn_lesson_5.text = tr("UI_LESSON_5")
	btn_lesson_6.text = tr("UI_LESSON_6")
	btn_lesson_7.text = tr("UI_LESSON_7")
	btn_lesson_8.text = tr("UI_LESSON_8")
	btn_lesson_9.text = tr("UI_LESSON_9")
	btn_quit.text = tr("UI_QUIT")


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
