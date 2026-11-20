# Autoload: GameSettings (inkl. Speichern in user://settings.cfg)
extends Node

const SAVE_PATH := "user://settings.cfg"

var difficulty: String = "medium"
var cpu_factor: float = 0.55
var noise: float = 40.0
var ball_speed: int = 300
var score_limit: int = 7
var volume: float = 0.8          # 0..1, Master
var large_text: bool = false     # groessere Roast-Texte
var winner: String = ""
var final_score: Array = [0, 0]   # [links = CPU2, rechts = CPU1]

func _ready() -> void:
	load_settings()
	apply_volume()

func apply(settings: Dictionary) -> void:
	cpu_factor = settings.get("cpu_factor", cpu_factor)
	noise = settings.get("noise", noise)
	ball_speed = settings.get("ball_speed", ball_speed)
	score_limit = settings.get("score_limit", score_limit)
	difficulty = settings.get("difficulty", difficulty)
	save_settings()

func apply_volume() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(volume, 0.0001)))
	AudioServer.set_bus_mute(0, volume <= 0.001)

func save_settings() -> void:
	var c := ConfigFile.new()
	c.set_value("game", "difficulty", difficulty)
	c.set_value("game", "score_limit", score_limit)
	c.set_value("ui", "volume", volume)
	c.set_value("ui", "large_text", large_text)
	c.save(SAVE_PATH)

func load_settings() -> void:
	var c := ConfigFile.new()
	if c.load(SAVE_PATH) != OK:
		return
	difficulty = c.get_value("game", "difficulty", difficulty)
	score_limit = clampi(int(c.get_value("game", "score_limit", score_limit)), 1, 21)
	volume = clampf(float(c.get_value("ui", "volume", volume)), 0.0, 1.0)
	large_text = bool(c.get_value("ui", "large_text", large_text))
	var d: Array = {"easy": [0.4, 60.0, 250], "medium": [0.55, 40.0, 300], "hard": [0.75, 20.0, 380]}.get(difficulty, [0.55, 40.0, 300])
	cpu_factor = d[0]; noise = d[1]; ball_speed = d[2]
