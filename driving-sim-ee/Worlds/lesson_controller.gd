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

# Mission text n what stat we watch
const LESSONS := {
	1: {
		"title": "Ül1: Läbisõit keelatud",
		"body": "[b]Ülesanne[/b]\nSa näed märki [b]\"Läbisõit keelatud\"[/b]. See tähendab, et sa ei tohi sellest teest läbi sõita.\n\n[b]Mida teha?[/b]\nVali [b]õige suund[/b] (pööra ära) ja sõida mööda [b]lubatud teed[/b].\n\n[b]Läbikukkumine[/b]\nKui sõidad keelatud lõigule (drive-through), kukud läbi ja sind pannakse tagasi algusesse."
	},
	2: {
		"title": "Ül2: Parempööre keelatud",
		"body": "[b]Ülesanne[/b]\nSa lähened ristmikule, kus kehtib märk [b]\"Parempööre keelatud\"[/b]. See tähendab, et sa [b]ei tohi[/b] paremale pöörata, isegi kui tee tundub vaba.\n\n[b]Mida teha?[/b]\nSõida [b]otse edasi[/b] või vali [b]lubatud suund[/b] vastavalt teekattemärgistele ja liikluskorraldusele.\n\n[b]Läbikukkumine[/b]\nKui teed keelatud parempöörde, loetakse see liiklusrikkumiseks ja sind pannakse tagasi algusesse."
	},
	3: {
		"title": "Ü3: STOP märk",
		"body": "[b]Ülesanne[/b]\nSa lähened ristmikule, kus kehtib [b]STOP märk[/b]. STOP-märk tähendab, et sa pead [b]täielikult peatuma[/b] enne stoppjoont või ristmikku.\n\n[b]Mida teha?[/b]\nPeatu täielikult (kiirus peab olema [b]0 km/h[/b]). Veendu, et tee on vaba, ja alles siis jätka sõitu [b]lubatud suunas[/b].\n\n[b]Läbikukkumine[/b]\nKui sa ei peatu STOP-märgi juures täielikult või sõidad ristmikule ilma peatumata, loetakse see liiklusrikkumiseks ja sind pannakse tagasi algusesse."
	},
	4: {
		"title": "Ül4: Möödasõit keelatud",
		"body": "[b]Ülesanne[/b]\nSelles lõigus kehtib märk [b]\"Möödasõit keelatud\"[/b].\n\n[b]Mida teha?[/b]\nSõida [b]oma reas[/b] ja ära soorita möödasõitu.\n\n[b]Läbikukkumine[/b]\nKui üritad möödasõitu / lähed vastassuunavööndisse, kukud läbi ja sind pannakse tagasi algusesse."
	},
	5: {
		"title": "Ül5: U-pööre keelatud",
		"body": "[b]Ülesanne[/b]\nSelles kohas kehtib märk [b]\"U-pööre keelatud\"[/b].\n\n[b]Mida teha?[/b]\nÄra tee U-pööret. Vali [b]lubatud suund[/b] või sõida edasi.\n\n[b]Läbikukkumine[/b]\nKui teed U-pöörde, kukud läbi ja sind pannakse tagasi algusesse."
	},
	6: {
		"title": "Ül6: Paaritu päeva parkimine",
		"body": "[b]Ülesanne[/b]\nSee märk näitab, et [b]paaritu kuupäeva päeval[/b] on siin [b]parkimine lubatud[/b] (paaritul päeval).\n\n[b]Kuidas see kontroll töötab?[/b]\nMärk kontrollib ise sinu tegevust oma tsoonis:\n• Kui jääd märgi tsoonis [b]peaaegu seisma[/b] ja püsid nii umbes [b]5 sekundit[/b], loetakse see \"parkimiseks\".\n• Kui sõidad lihtsalt läbi, loetakse see \"mitte parkimiseks\".\n\n[b]Reegel[/b]\n• [b]Paaritu päev[/b] → parkimine on [b]lubatud[/b]\n• [b]Paaris päev[/b] → parkimine on [b]keelatud[/b]\n\n[b]Lõpetamine[/b]\nÕppetund loetakse lõpetatuks siis, kui märk tuvastab, et tegid [b]õige valiku[/b] (parkisid lubatud päeval või sõitsid korrektselt läbi).\n\n[b]Läbikukkumine[/b]\nKui märk tuvastab, et \"parkisid\" [b]keelatud päeval[/b], saad vea ja sind pannakse tagasi algusesse."
	},
	7: {
		"title": "Ül7: Anna teed ringristmikul",
		"body": "[b]Ülesanne[/b]\nSa lähened ringristmikule, kus kehtib märk [b]\"Anna teed\"[/b].\n\n[b]Mida teha?[/b]\n[b]Oota[/b], kuni ringristmikul liikuv sõiduk on sinust möödunud.\nPärast seda võid siseneda [b]ainult siis[/b], kui samast suunast ei tule enam teisi sõidukeid.\n\n[b]Sõiduülesanne[/b]\nRingristmikule sisenedes pead tegema [b]esimese parempöörde[/b] (väljumine esimesest väljasõidust).\n\n[b]Läbikukkumine[/b]\nKui ei anna teed või sisened liiga kiiresti, loetakse see rikkumiseks ja sind pannakse tagasi algusesse."
	},
	8: {
		"title": "Ül8: Vasakpööre keelatud",
		"body": "[b]Ülesanne[/b]\nRistmikul kehtib märk [b]\"Vasakpööre keelatud\"[/b].\n\n[b]Mida teha?[/b]\nÄra pööra vasakule. Sõida [b]otse[/b] või vali [b]lubatud suund[/b].\n\n[b]Läbikukkumine[/b]\nKui teed keelatud vasakpöörde, kukud läbi ja sind pannakse tagasi algusesse."
	},
	9: {
		"title": "Ül9: Foorituli",
		"body": "[b]Ülesanne[/b]\nSõida ristmikule ja järgi foorituld.\n\n[b]Mida teha?[/b]\nPeatu valgusfoori juures ja [b]oota kuni tuli läheb roheliseks[/b].\nKui tuli on roheline, sõida [b]otse edasi[/b].\n\n[b]Lõpetamine[/b]\nÕppetund loetakse lõpetatuks siis, kui sõidad [b]rohelise tulega otse edasi[/b] ja jõuad märgitud alasse.\n\n[b]Läbikukkumine[/b]\nKui ületad ristmiku, kui tuli ei ole roheline, kukud läbi ja sind pannakse tagasi algusesse."
	},
}

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
		_show_popup("STOP: Õige", "Peatusid %.1f s. Tubli!" % stopped_time, false)
	else:
		_fail("STOP: Vale", "Peatusid ainult %.1f s. Pead peatuma täielikult vähemalt %.1f s." % [stopped_time, 1.0])


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
		_fail("Viga", _get_fail_message())
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

	_fail("Viga", "Sõitsid keelatud või valesse tsooni. Proovi uuesti.")

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
		_fail("Viga", "Sa põrkasid kokku ringristmikul liikuva sõidukiga. Proovi uuesti.")

func _fail(title: String, msg: String) -> void:
	_intro_popup_open = false
	btn_menu.text = "Menüü"
	_active = false
	_show_popup(title, msg, true)

func _complete() -> void:
	_intro_popup_open = false
	btn_menu.text = "Menüü"
	_active = false
	_show_popup("Tubli!", "Õppetund lõpetatud! Vajuta menüüsse.", false)

func _show_intro_popup() -> void:
	if not _is_lesson_mode:
		return

	var data = LESSONS.get(lesson_id, null)
	if data == null:
		return

	_intro_popup_open = true
	btn_retry.visible = false
	btn_menu.visible = true
	btn_menu.text = "Alusta" # Continue

	_show_popup(data.title, data.body, false)

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
			# fallback
			return int(TrafficStats.overtake_wrong) \
				+ int(TrafficStats.drive_through_wrong) \
				+ int(TrafficStats.u_turn_wrong) \
				+ int(TrafficStats.right_turn_wrong) \
				+ int(TrafficStats.left_turn_wrong) \
				+ int(TrafficStats.stop_wrong)

func _get_fail_message() -> String:
	match lesson_id:
		1: return "Sa rikkusid \"Läbisõit keelatud\" märki. Sind pannakse tagasi algusesse."
		2: return "Sa tegid keelatud parempöörde. Sind pannakse tagasi algusesse."
		3: return "Sa ei peatunud STOP märgi juures korrektselt. Sind pannakse tagasi algusesse."
		4: return "Sa tegid keelatud möödasõidu. Sind pannakse tagasi algusesse."
		5: return "Sa tegid keelatud U-pöörde. Sind pannakse tagasi algusesse."
		6: return "Sa rikkusid parkimisreeglit. Sind pannakse tagasi algusesse."
		7: return "Sa ei järginud \"Anna teed\" nõuet. Sind pannakse tagasi algusesse."
		8: return "Sa tegid keelatud vasakpöörde. Sind pannakse tagasi algusesse."
		_: return "Sa tegid liiklusvea. Sind pannakse tagasi algusesse."
