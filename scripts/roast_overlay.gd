extends CanvasLayer

signal done

@onready var prompt_label = $VBox/PromptLabel
@onready var hint_label = $VBox/HintLabel

var _font: FontFile
var _is_active: bool = false

const GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
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
	hide()

func activate(scorer: String, victim: String) -> void:
	if _is_active:
		done.emit()
		return

	_is_active = true

	prompt_label.text = "%s roasts %s!" % [scorer, victim]
	hint_label.text = "..."
	show()

	# Roast von Gemini holen
	var roast = await _fetch_roast(scorer, victim, false)
	hint_label.text = "%s  %s  [%d/10]" % [roast["emoji"], roast["text"], roast["score"]]

	await get_tree().create_timer(2.5).timeout

	# Konter von Gemini holen
	prompt_label.text = "%s claps back!" % victim
	hint_label.text = "..."
	var counter = await _fetch_roast(victim, scorer, true)
	hint_label.text = "%s  %s  [%d/10]" % [counter["emoji"], counter["text"], counter["score"]]

	await get_tree().create_timer(2.0).timeout
	hide()
	_is_active = false
	done.emit()

func _fetch_roast(scorer: String, victim: String, is_counter: bool) -> Dictionary:
	var http = HTTPRequest.new()
	add_child(http)

	var user_prompt = ""
	if is_counter:
		user_prompt = "%s just got roasted by %s in Pong. Generate a defiant, unbothered clap back – as if the point meant nothing. Style: 'I let you have that one.' or 'Enjoy it while it lasts.'" % [scorer, victim]
	else:
		user_prompt = "%s just scored against %s in Pong. Generate a savage roast for %s." % [scorer, victim, victim]

	var body = {
		"system_instruction": {
			"parts": [ {"text": SYSTEM_PROMPT}]
		},
		"contents": [ {
			"parts": [ {"text": user_prompt}]
		}],
		"generationConfig": {
			"maxOutputTokens": 80,
			"temperature": 0.95
		}
	}

	var headers = [
		"Content-Type: application/json",
		"x-goog-api-key: " + API_KEY
	]

	http.request(GEMINI_URL, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

	var response = await http.request_completed
	http.queue_free()

	return _parse_response(response)

func _parse_response(response: Array) -> Dictionary:
	var fallback = RoastScorer.pick_weighted(Roasts.ROASTS)
	var fallback_score = RoastScorer.score(fallback["text"])

	var response_code = response[1]
	var body = response[3]

	if response_code != 200:
		return {"text": fallback["text"], "emoji": fallback["emoji"], "score": fallback_score}

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		return {"text": fallback["text"], "emoji": fallback["emoji"], "score": fallback_score}

	var raw_text = json["candidates"][0]["content"]["parts"][0]["text"].strip_edges()

	# JSON aus Antwort parsen
	var parsed = JSON.parse_string(raw_text)
	if parsed == null or not parsed.has("roast"):
		return {"text": fallback["text"], "emoji": fallback["emoji"], "score": fallback_score}

	return {
		"text": parsed.get("roast", fallback["text"]),
		"emoji": parsed.get("emoji", "🔥"),
		"score": clamp(int(parsed.get("score", 5)), 1, 10)
	}
