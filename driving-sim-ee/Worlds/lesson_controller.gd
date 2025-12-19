extends Node

var _prev_ok_value: int = 0
var _is_lesson_mode := false

@onready var spawns: Node3D = $"../LessonSpawns"
@onready var bounds_root: Node = $"../LessonBounds"
@onready var goals_root: Node = $"../LessonGoals"

@onready var ui_panel: Control = $"../LessonUI/Root/Panel"
@onready var title_label: Label = $"../LessonUI/Root/Panel/Margin/VBox/TitleLabel"
@onready var body_label: RichTextLabel = $"../LessonUI/Root/Panel/Margin/VBox/BodyLabel"
@onready var btn_retry: Button = $"../LessonUI/Root/Panel/Margin/VBox/Buttons/BtnRetry"
@onready var btn_menu: Button = $"../LessonUI/Root/Panel/Margin/VBox/Buttons/BtnMenu"

var _stop_signs: Array[Node] = []
var _popup_open := false
var _intro_popup_open := false

var car: VehicleBody3D = null
var lesson_id: int = 0

var bounds_area: Area3D = null
var goal_area: Area3D = null

var _start_transform: Transform3D
var _prev_wrong_value: int = 0
var _active: bool = false


func _lesson_key(suffix: String) -> String:
	return "L%d_%s" % [lesson_id, suffix]


func _build_intro_bbcode() -> String:
	var rule_key := _lesson_key("RULE")
	var task_key := _lesson_key("TASK")
	var fail_key := _lesson_key("FAIL")

	return "[b]%s[/b]\n%s\n\n[b]%s[/b]\n%s\n\n[b]%s[/b]\n%s" % [
		tr("UI_RULE"), tr(rule_key),
		tr("UI_TASK"), tr(task_key),
		tr("UI_FAIL"), tr(fail_key),
	]


# helper
func _setup_lesson7_collision_fail() -> void:
	if lesson_id != 7:
		return
	if car == null:
		push_error("LessonController: car is null, cannot setup lesson 7 collision fail.")
		return

	car.contact_monitor = true
	car.max_contacts_reported = 8

	if not car.body_entered.is_connected(_on_car_body_entered):
		car.body_entered.connect(_on_car_body_entered)


func _process(_delta: float) -> void:
	if _popup_open:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _ready() -> void:
	$"../LessonUI".process_mode = Node.PROCESS_MODE_ALWAYS
	$"../LessonUI/Root".process_mode = Node.PROCESS_MODE_ALWAYS
	$"../LessonUI/Root/Panel".process_mode = Node.PROCESS_MODE_ALWAYS

	ui_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	$"../LessonUI/Root".mouse_filter = Control.MOUSE_FILTER_STOP

	ui_panel.visible = false

	btn_retry.pressed.connect(_on_retry_pressed)
	btn_menu.pressed.connect(_on_menu_pressed)

	btn_retry.text = tr("UI_RETRY")
	btn_menu.text = tr("UI_MENU")

	var cars := get_tree().get_nodes_in_group("car")
	if cars.is_empty():
		push_error("LessonController: No node in group 'car' found. Add your VehicleBody3D to group 'car'.")
		return
	car = cars[0] as VehicleBody3D
	if car == null:
		push_error("LessonController: Node in group 'car' is not a VehicleBody3D.")
		return

	var main := get_tree().root.get_node_or_null("Main")
	if main == null or not ("current_lesson_id" in main):
		push_error("LessonController: Could not read Main.current_lesson_id")
		return

	lesson_id = int(main.current_lesson_id)
	if lesson_id <= 0:
		return

	_prev_ok_value = _get_watched_ok_value()
	_is_lesson_mode = lesson_id > 0

	if lesson_id == 3:
		_connect_stop_signs()

	_setup_lesson7_collision_fail()
	_select_lesson_areas(lesson_id)
	_apply_spawn(lesson_id)

	_prev_wrong_value = _get_watched_wrong_value()
	_active = true

	if "contact_monitor" in car:
		car.contact_monitor = true
	if "max_contacts_reported" in car:
		car.max_contacts_reported = 8

	_show_intro_popup()


func _on_stop_evaluated(correct: bool, stopped_time: float) -> void:
	if lesson_id != 3:
		return
	if not _active:
		return

	if correct:
		var msg := tr("L3_STOP_OK") % stopped_time
		_show_popup(tr("UI_SUCCESS"), msg, false)
	else:
		var msg_bad := tr("L3_STOP_BAD") % [stopped_time, 1.0]
		_fail(tr("UI_FAIL"), msg_bad)


func _connect_stop_signs() -> void:
	_stop_signs = get_tree().get_nodes_in_group("stop_sign")

	for s in _stop_signs:
		if s and s.has_signal("stop_evaluated"):
			if not s.stop_evaluated.is_connected(_on_stop_evaluated):
				s.stop_evaluated.connect(_on_stop_evaluated)


func _physics_process(_delta: float) -> void:
	if not _active:
		return

	# fail check
	var now_wrong := _get_watched_wrong_value()
	if now_wrong > _prev_wrong_value:
		_prev_wrong_value = now_wrong
		_fail(tr("UI_FAIL"), _get_fail_message())
		return

	# complete check
	var now_ok := _get_watched_ok_value()
	if now_ok > _prev_ok_value:
		_prev_ok_value = now_ok
		_complete()
		return


func _select_lesson_areas(id: int) -> void:
	for child in bounds_root.get_children():
		var area := child as Area3D
		if area:
			area.monitoring = false
			area.monitorable = false
			area.visible = false
			if area.body_entered.is_connected(_on_fail_area_entered):
				area.body_entered.disconnect(_on_fail_area_entered)

	for child in goals_root.get_children():
		var area := child as Area3D
		if area:
			area.monitoring = false
			area.monitorable = false
			area.visible = false
			if area.body_entered.is_connected(_on_goal_body_entered):
				area.body_entered.disconnect(_on_goal_body_entered)

	for child in bounds_root.get_children():
		var area := child as Area3D
		if area == null:
			continue

		if area.name.begins_with("Lesson%d" % id):
			area.monitoring = true
			area.monitorable = true
			area.visible = true
			if not area.body_entered.is_connected(_on_fail_area_entered):
				area.body_entered.connect(_on_fail_area_entered)

	for child in goals_root.get_children():
		var area := child as Area3D
		if area == null:
			continue

		if area.name.begins_with("Lesson%dCorrect" % id):
			area.monitoring = true
			area.monitorable = true
			area.visible = true
			if not area.body_entered.is_connected(_on_goal_body_entered):
				area.body_entered.connect(_on_goal_body_entered)


func _set_car_frozen(frozen: bool) -> void:
	if car == null:
		return
	if frozen:
		car.freeze = true
		car.linear_velocity = Vector3.ZERO
		car.angular_velocity = Vector3.ZERO
	else:
		car.freeze = false


func _apply_spawn(id: int) -> void:
	var spawn := spawns.get_node_or_null("Lesson%dSpawn" % id) as Marker3D
	if spawn == null:
		push_error("LessonController: Missing LessonSpawns/Lesson%dSpawn" % id)
		return

	_start_transform = spawn.global_transform
	_teleport_car(_start_transform)


func _teleport_car(t: Transform3D) -> void:
	car.global_transform = t
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO


func _on_fail_area_entered(body: Node3D) -> void:
	if not _active:
		return
	if body == null or not body.is_in_group("car"):
		return

	_fail(tr("UI_FAIL"), tr("LESSON_FAIL_ZONE"))


func _on_goal_body_entered(body: Node3D) -> void:
	if body == null or not body.is_in_group("car"):
		return
	_complete()


func _on_car_body_entered(other: Node) -> void:
	if not _active:
		return
	if lesson_id != 7:
		return
	if other == null:
		return

	if other.is_in_group("traffic_car"):
		_fail(tr("UI_FAIL"), tr("LESSON_FAIL_COLLISION"))


func _fail(title: String, msg: String) -> void:
	_intro_popup_open = false
	btn_retry.text = tr("UI_RETRY")
	btn_menu.text = tr("UI_MENU")
	_active = false
	_show_popup(title, msg, true)


func _complete() -> void:
	_intro_popup_open = false
	btn_retry.text = tr("UI_RETRY")
	btn_menu.text = tr("UI_MENU")
	_active = false

	var success_title := tr("UI_SUCCESS")
	var success_msg := tr(_lesson_key("SUCCESS"))
	_show_popup(success_title, success_msg, false)


func _show_intro_popup() -> void:
	if not _is_lesson_mode:
		return

	_intro_popup_open = true
	btn_retry.visible = false
	btn_menu.visible = true
	btn_menu.text = tr("UI_START")

	var title := tr(_lesson_key("TITLE"))
	var body := _build_intro_bbcode()
	_show_popup(title, body, false)


func _show_popup(title: String, msg: String, show_retry: bool) -> void:
	_popup_open = true
	title_label.text = title
	body_label.bbcode_text = msg
	btn_retry.visible = show_retry
	ui_panel.visible = true

	if _is_lesson_mode:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_set_car_frozen(true)

	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _hide_popup() -> void:
	ui_panel.visible = false
	if _is_lesson_mode:
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	_popup_open = false
	_set_car_frozen(false)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_retry_pressed() -> void:
	_hide_popup()
	_teleport_car(_start_transform)
	_prev_wrong_value = _get_watched_wrong_value()
	_prev_ok_value = _get_watched_ok_value()
	_active = true


func _on_menu_pressed() -> void:
	if _intro_popup_open:
		_intro_popup_open = false
		_hide_popup()
		return

	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var main := get_tree().root.get_node_or_null("Main")
	if main and main.has_method("return_to_menu"):
		main.return_to_menu()
	else:
		get_tree().change_scene_to_file("res://Main.tscn")


func _get_watched_ok_value() -> int:
	match lesson_id:
		6:
			return int(TrafficStats.odd_parking_ok)
		_:
			return 0


func _get_watched_wrong_value() -> int:
	match lesson_id:
		1:
			return int(TrafficStats.drive_through_wrong)
		2:
			return int(TrafficStats.right_turn_wrong)
		3:
			return int(TrafficStats.stop_wrong)
		4:
			return int(TrafficStats.overtake_wrong)
		5:
			return int(TrafficStats.u_turn_wrong)
		6:
			return int(TrafficStats.odd_parking_wrong)
		7:
			return int(TrafficStats.give_way_wrong)
		8:
			return int(TrafficStats.left_turn_wrong)
		_:
			return int(TrafficStats.overtake_wrong) \
				+ int(TrafficStats.drive_through_wrong) \
				+ int(TrafficStats.u_turn_wrong) \
				+ int(TrafficStats.right_turn_wrong) \
				+ int(TrafficStats.left_turn_wrong) \
				+ int(TrafficStats.stop_wrong)


func _get_fail_message() -> String:
	var key := _lesson_key("FAIL")
	return tr(key)
