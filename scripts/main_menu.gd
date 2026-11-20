extends Control

const DIFFICULTIES = {
	"easy": {"cpu_factor": 0.4, "noise": 60.0, "ball_speed": 250},
	"medium": {"cpu_factor": 0.55, "noise": 40.0, "ball_speed": 300},
	"hard": {"cpu_factor": 0.75, "noise": 20.0, "ball_speed": 380},
}

var selected_difficulty: String = "medium"

@onready var easy_btn: Button = $VBox/DiffRow/EasyBtn
@onready var medium_btn: Button = $VBox/DiffRow/MediumBtn
@onready var hard_btn: Button = $VBox/DiffRow/HardBtn
@onready var score_limit: SpinBox = $VBox/ScoreLimit
@onready var score_label: Label = $VBox/ScoreLabel
@onready var start_btn: Button = $VBox/StartBtn

func _ready() -> void:
	# Eine Theme-Schrift, damit auch dynamisch erzeugte Controls dieselbe Font nutzen
	var t := Theme.new()
	t.default_font = load("res://assets/font/Xolonium-Regular.ttf")
	t.default_font_size = 20
	theme = t

	score_label.text = "First to"
	score_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Der SpinBox-Standard 0 wuerde das Spiel nach dem ersten Punkt beenden
	score_limit.min_value = 1
	score_limit.max_value = 21
	score_limit.step = 1
	score_limit.value = GameSettings.score_limit
	score_limit.suffix = "points"
	score_limit.alignment = HORIZONTAL_ALIGNMENT_CENTER

	_build_extra_controls()
	selected_difficulty = GameSettings.difficulty
	_highlight_button(_button_for(selected_difficulty))
	start_btn.grab_focus()

func _build_extra_controls() -> void:
	var vbox: VBoxContainer = $VBox
	var at: int = start_btn.get_index()

	var vol_label := Label.new()
	vol_label.text = "Volume"
	vol_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var vol := HSlider.new()
	vol.min_value = 0.0
	vol.max_value = 1.0
	vol.step = 0.05
	vol.value = GameSettings.volume
	vol.custom_minimum_size = Vector2(0, 24)
	vol.value_changed.connect(func(v: float):
		GameSettings.volume = v
		GameSettings.apply_volume()
		GameSettings.save_settings())

	var large := CheckButton.new()
	large.text = "Large roast text"
	large.button_pressed = GameSettings.large_text
	large.toggled.connect(func(on: bool):
		GameSettings.large_text = on
		GameSettings.save_settings())

	var hint := Label.new()
	hint.text = "Keys: 1 / 2 / 3 difficulty   Enter start   Esc exit"
	hint.add_theme_font_size_override("font_size", 14)
	hint.modulate = Color(1, 1, 1, 0.7)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	for n in [vol_label, vol, large]:
		vbox.add_child(n)
		vbox.move_child(n, at)
		at += 1
	vbox.add_child(hint)

func _button_for(diff: String) -> Button:
	match diff:
		"easy": return easy_btn
		"hard": return hard_btn
		_: return medium_btn

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: _select("easy")
			KEY_2: _select("medium")
			KEY_3: _select("hard")

func _select(diff: String) -> void:
	selected_difficulty = diff
	_highlight_button(_button_for(diff))

func _on_easy_btn_pressed() -> void: _select("easy")
func _on_medium_btn_pressed() -> void: _select("medium")
func _on_hard_btn_pressed() -> void: _select("hard")

func _on_start_btn_pressed() -> void:
	var settings = DIFFICULTIES[selected_difficulty].duplicate()
	settings["difficulty"] = selected_difficulty
	settings["score_limit"] = int(score_limit.value)
	GameSettings.apply(settings)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _highlight_button(active: Button) -> void:
	for btn in [easy_btn, medium_btn, hard_btn]:
		btn.modulate = Color(0.55, 0.55, 0.55)
	active.modulate = Color.WHITE

func _on_exit_btn_pressed() -> void:
	get_tree().quit()
