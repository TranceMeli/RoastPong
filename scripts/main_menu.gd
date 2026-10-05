extends Control

const DIFFICULTIES = {
	"easy": {"cpu_factor": 0.4, "noise": 60.0, "ball_speed": 250},
	"medium": {"cpu_factor": 0.55, "noise": 40.0, "ball_speed": 300},
	"hard": {"cpu_factor": 0.75, "noise": 20.0, "ball_speed": 380},
}

var selected_difficulty = "medium"

@onready var easy_btn = $VBox/DiffRow/EasyBtn
@onready var medium_btn = $VBox/DiffRow/MediumBtn
@onready var hard_btn = $VBox/DiffRow/HardBtn
@onready var score_limit = $VBox/ScoreLimit

func _ready() -> void:
	_highlight_button(medium_btn)

func _on_easy_btn_pressed() -> void:
	selected_difficulty = "easy"
	_highlight_button(easy_btn)

func _on_medium_btn_pressed() -> void:
	selected_difficulty = "medium"
	_highlight_button(medium_btn)

func _on_hard_btn_pressed() -> void:
	selected_difficulty = "hard"
	_highlight_button(hard_btn)

func _on_start_btn_pressed() -> void:
	var settings = DIFFICULTIES[selected_difficulty].duplicate()
	settings["score_limit"] = int(score_limit.value)
	GameSettings.apply(settings)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _highlight_button(active: Button) -> void:
	for btn in [easy_btn, medium_btn, hard_btn]:
		btn.modulate = Color(0.5, 0.5, 0.5)
	active.modulate = Color.WHITE


func _on_exit_btn_pressed() -> void:
	pass # Replace with function body.
