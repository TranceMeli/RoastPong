extends CanvasLayer

signal done

@onready var prompt_label = $VBox/PromptLabel
@onready var hint_label = $VBox/HintLabel

var _font: FontFile
var _is_active: bool = false
var _wait_timer: Timer

const GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
const REQUEST_TIMEOUT := 6.0
var API_KEY: String = ""

const SYSTEM_PROMPT = """You are a Pong roast battle commentator. Two AIs are playing Pong against each other: CPU1 and CPU2.

When generating a ROAST (scorer roasts the loser):
- The scorer is cocky and savage
- Attack the loser's skill, reflexes, or intelligence
- Max 10 words, sharp and direct
- Score based on: brevity, harshness, creativity, surprise ending

When generating a COUNTER (loser claps back):
- The loser is defiant and unbothered
- Do NOT roast back – instead brush it off confidently
- Style: "That point was a gift.", "Enjoy it while it lasts.", "I let you have that one."
- Max 10 words, cocky but defensive
- Score based on: confidence, wit, unexpectedness

Reply ONLY as valid JSON, no markdown:
{"roast": "text here", "score": 8, "emoji": "😏"}"""

func _ready() -> void:
	_font = load("res://assets/font/Xolonium-Regular.ttf")
	API_KEY = Config.GEMINI_KEY
	if _font:
		prompt_label.add_theme_font_override("font", _font)
		hint_label.add_theme_font_override("font", _font)
	_wait_timer = Timer.new()
	_wait_timer.one_shot = true
	add_child(_wait_timer)
	hide()

func _input(event: InputEvent) -> void:
	if not _is_active:
		return
	var skip: bool = event.is_action_pressed("ui_accept") 		or (event is InputEventMouseButton and event.pressed)
	if skip:
		get_viewport().set_input_as_handled()
		_wait_timer.stop()
		_wait_timer.timeout.emit()

func _wait(seconds: float) -> void:
	_wait_timer.start(seconds)
	await _wait_timer.timeout

func _show_text(title: String, text: String) -> void:
	hint_label.add_theme_font_size_override("font_size", 40 if GameSettings.large_text else 30)
	prompt_label.text = title
	hint_label.text = text
	hint_label.modulate.a = 0.0
	create_tween().tween_property(hint_label, "modulate:a", 1.0, 0.25)

func activate(scorer: String, victim: String) -> void:
	if _is_active:
		return
	_is_active = true
	show()

	_show_text("%s roasts %s!" % [scorer, victim], "...")
	var roast: Dictionary = await _fetch_roast(scorer, victim, false)
	_show_text("%s roasts %s!" % [scorer, victim], _format(roast))
	await _wait(3.0)

	_show_text("%s claps back!" % victim, "...")
	var counter: Dictionary = await _fetch_roast(victim, scorer, true)
	_show_text("%s claps back!" % victim, _format(counter))
	await _wait(2.5)

	hide()
	_is_active = false
	done.emit()

func _format(r: Dictionary) -> String:
	return "%s  %s  [%d/10]" % [r["emoji"], r["text"], r["score"]]

func _fallback(is_counter: bool) -> Dictionary:
	var list: Array = Roasts.COUNTERS if is_counter else Roasts.ROASTS
	var item: Dictionary = RoastScorer.pick_weighted(list)
	return {"text": item["text"], "emoji": item["emoji"], "score": RoastScorer.score(item["text"])}

func _fetch_roast(scorer: String, victim: String, is_counter: bool) -> Dictionary:
	# Ohne Key sofort lokale Roasts nutzen (spart die Wartezeit auf einen sinnlosen Request)
	if API_KEY.strip_edges() == "":
		return _fallback(is_counter)

	var http := HTTPRequest.new()
	http.timeout = REQUEST_TIMEOUT
	add_child(http)

	var user_prompt := ""
	if is_counter:
		user_prompt = "%s just got roasted by %s in Pong. Generate a defiant, unbothered clap back - as if the point meant nothing. Style: 'I let you have that one.' or 'Enjoy it while it lasts.'" % [scorer, victim]
	else:
		user_prompt = "%s just scored against %s in Pong. Generate a savage roast for %s." % [scorer, victim, victim]

	var body = {
		"system_instruction": {"parts": [{"text": SYSTEM_PROMPT}]},
		"contents": [{"parts": [{"text": user_prompt}]}],
		"generationConfig": {
			"maxOutputTokens": 200,
			"temperature": 0.95,
			"responseMimeType": "application/json",
			"thinkingConfig": {"thinkingBudget": 0}
		}
	}
	var headers := [
		"Content-Type: application/json",
		"x-goog-api-key: " + API_KEY
	]

	# request() kann sofort fehlschlagen - dann kommt kein request_completed - ohne Pruefung des Rueckgabewerts haengt das Spiel
	var err := http.request(GEMINI_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		http.queue_free()
		return _fallback(is_counter)

	var response: Array = await http.request_completed
	http.queue_free()
	return _parse_response(response, is_counter)

func _parse_response(response: Array, is_counter: bool) -> Dictionary:
	if response[0] != HTTPRequest.RESULT_SUCCESS or response[1] != 200:
		return _fallback(is_counter)

	var json = JSON.parse_string(response[3].get_string_from_utf8())
	if typeof(json) != TYPE_DICTIONARY:
		return _fallback(is_counter)
	var candidates = json.get("candidates", [])
	if candidates.is_empty():
		return _fallback(is_counter)
	var parts = candidates[0].get("content", {}).get("parts", [])
	if parts.is_empty():
		return _fallback(is_counter)

	# Gemini umschliesst JSON trotz responseMimeType teils mit Markdown-Fences
	var raw_text: String = str(parts[0].get("text", "")).strip_edges()
	raw_text = raw_text.trim_prefix("```json").trim_prefix("```").trim_suffix("```").strip_edges()

	var parsed = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("roast"):
		return _fallback(is_counter)

	return {
		"text": str(parsed["roast"]),
		"emoji": str(parsed.get("emoji", "🔥")),
		"score": clampi(int(parsed.get("score", 5)), 1, 10)
	}
