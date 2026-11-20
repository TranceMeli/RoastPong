extends Sprite2D

# CPU2 = linkes Paddle, CPU1 = rechtes Paddle
const PADDLE_SPEED: int = 500
const BOTTOM_WALL_Y: int = 717   # Oberkante der unteren Bande (Spielfeld: 0 .. 717)
const COUNTDOWN_STEP := 0.6

var score_left := 0    # CPU2
var score_right := 0   # CPU1
var _round_over := true
var _paused := false

@onready var ball = $Ball
@onready var sound_paddle = $SoundPaddle
@onready var sound_wall = $SoundWall
@onready var sound_point = $SoundPoint
@onready var left_score_label = $Hud/PlayerScore
@onready var right_score_label = $Hud/CPUScore

var _big_label: Label
var _pause_menu: VBoxContainer
var _resume_btn: Button
var _font: FontFile

func _ready() -> void:
	# Main laeuft auch in der Pause (fuer Input), das Spiel selbst nicht.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for n in [$Ball, $CPU, $CPU2, $BallTimer, $RoastOverlay]:
		n.process_mode = Node.PROCESS_MODE_PAUSABLE
	_font = load("res://assets/font/Xolonium-Regular.ttf")
	_build_big_label()
	_build_pause_menu()
	ball.stop()

func _build_big_label() -> void:
	_big_label = Label.new()
	_big_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_big_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_big_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_big_label.add_theme_font_override("font", _font)
	_big_label.add_theme_font_size_override("font_size", 96)
	_big_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_big_label.add_theme_constant_override("outline_size", 12)
	_big_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_big_label.hide()
	$Hud.add_child(_big_label)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P):
		get_viewport().set_input_as_handled()
		_toggle_pause()

func _build_pause_menu() -> void:
	_pause_menu = VBoxContainer.new()
	_pause_menu.custom_minimum_size = Vector2(300, 0)
	_pause_menu.position = Vector2(490, 500)
	var t := Theme.new()
	t.default_font = _font
	t.default_font_size = 22
	_pause_menu.theme = t
	var resume := Button.new()
	resume.text = "Resume"
	resume.pressed.connect(_toggle_pause)
	var menu := Button.new()
	menu.text = "Main menu"
	menu.pressed.connect(_to_menu)
	_pause_menu.add_child(resume)
	_pause_menu.add_child(menu)
	_pause_menu.hide()
	$Hud.add_child(_pause_menu)
	_resume_btn = resume

func _to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	if _paused:
		_big_label.text = "Paused"
		_big_label.add_theme_font_size_override("font_size", 64)
		_big_label.show()
		_pause_menu.show()
		_resume_btn.grab_focus()
	else:
		_big_label.hide()
		_pause_menu.hide()
		_big_label.add_theme_font_size_override("font_size", 96)

func _on_ball_timer_timeout() -> void:
	_serve()

func _serve() -> void:
	for i in [3, 2, 1]:
		_big_label.text = str(i)
		_big_label.show()
		await get_tree().create_timer(COUNTDOWN_STEP, false).timeout
		if not is_inside_tree():
			return
	_big_label.hide()
	_round_over = false
	ball.new_ball()

# Ball hat links das Spielfeld verlassen -> CPU1 (rechts) punktet
func _on_score_left_body_entered(body: Node2D) -> void:
	if body != ball or _round_over:
		return
	score_right += 1
	right_score_label.text = str(score_right)
	await _point_scored("CPU1", "CPU2", score_right)

# Ball hat rechts das Spielfeld verlassen -> CPU2 (links) punktet
func _on_score_right_body_entered(body: Node2D) -> void:
	if body != ball or _round_over:
		return
	score_left += 1
	left_score_label.text = str(score_left)
	await _point_scored("CPU2", "CPU1", score_left)

func _point_scored(scorer: String, loser: String, scorer_points: int) -> void:
	_round_over = true
	ball.stop()
	sound_point.play()
	await $RoastOverlay.activate(scorer, loser)
	if not is_inside_tree():
		return
	if scorer_points >= GameSettings.score_limit:
		_end_game(scorer)
	else:
		_serve()

func _end_game(winner: String) -> void:
	GameSettings.winner = winner
	GameSettings.final_score = [score_left, score_right]
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
