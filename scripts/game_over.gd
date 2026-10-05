extends Control

@onready var winner_label = $VBoxContainer/WinnerLabel
@onready var score_label = $VBoxContainer/ScoreLabel

func _ready() -> void:
    winner_label.text = "%s WINS! 🏆" % GameSettings.winner
    score_label.text = "%d  :  %d" % [
        GameSettings.final_score[0],
        GameSettings.final_score[1]
    ]

func _on_rematch_btn_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_menu_btn_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")