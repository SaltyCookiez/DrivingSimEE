extends Control

@onready var resume_button = $Panel/VBoxContainer/BtnResume
@onready var main_menu_button = $Panel/VBoxContainer/BtnMainMenu
@onready var quit_button = $Panel/VBoxContainer/BtnQuit

func _ready():
	
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	resume_button.pressed.connect(_on_resume_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func show_menu():
	self.visible = true

func hide_menu():
	self.visible = false

func _on_resume_button_pressed():
	get_tree().paused = false
	hide_menu()
	get_parent().get_node("HUD").visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_main_menu_button_pressed():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Main/main_menu.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
