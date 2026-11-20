extends Control

@onready var winner_label: Label = $VBoxContainer/WinnerLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var rematch_btn: Button = $VBoxContainer/RematchBtn

func _ready() -> void:
	var t := Theme.new()
	t.default_font = load("res://assets/font/Xolonium-Regular.ttf")
	theme = t
	for l in [winner_label, score_label]:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	winner_label.text = "%s WINS!" % GameSettings.winner
	# final_score = [links (CPU2), rechts (CPU1)]
	score_label.text = "CPU2  %d : %d  CPU1" % [GameSettings.final_score[0], GameSettings.final_score[1]]
	rematch_btn.grab_focus()

func _on_rematch_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_menu_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
