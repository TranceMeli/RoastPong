# Als Autoload anlegen, Name: GameSettings
extends Node

var cpu_factor: float = 0.55
var noise: float = 40.0
var ball_speed: int = 300
var score_limit: int = 7
var winner: String = ""
var final_score: Array = [0, 0]

func apply(settings: Dictionary) -> void:
    cpu_factor = settings["cpu_factor"]
    noise = settings["noise"]
    ball_speed = settings["ball_speed"]
    score_limit = settings["score_limit"]