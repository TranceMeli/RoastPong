extends Sprite2D

var score := [0, 0]
const PADDLE_SPEED: int = 500
const BOTTOM_WALL_Y: int = 600

@onready var sound_paddle = $SoundPaddle
@onready var sound_wall = $SoundWall
@onready var sound_point = $SoundPoint
@onready var cpu1_score = $Hud/PlayerScore
@onready var cpu2_score = $Hud/CPUScore

func _on_ball_timer_timeout() -> void:
	$Ball.new_ball()

func _on_score_left_body_entered(body: Node2D) -> void:
	score[1] += 1
	cpu2_score.text = str(score[1])
	sound_point.play()
	await $RoastOverlay.activate("CPU2", "CPU1")
	if score[1] >= GameSettings.score_limit:
		_end_game("CPU2")
	else:
		$BallTimer.start()

func _on_score_right_body_entered(body: Node2D) -> void:
	score[0] += 1
	cpu1_score.text = str(score[0])
	sound_point.play()
	await $RoastOverlay.activate("CPU1", "CPU2")
	if score[0] >= GameSettings.score_limit:
		_end_game("CPU1")
	else:
		$BallTimer.start()

func _end_game(winner: String) -> void:
	GameSettings.winner = winner
	GameSettings.final_score = score
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")