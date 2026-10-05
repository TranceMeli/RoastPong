extends StaticBody2D

var ball_pos: Vector2
var dist
var move_by
var win_height: int
var p_height: int
var target_y: float = 0.0
var noise_timer: float = 0.0

var CPU_SPEED_FACTOR: float
var CPU_NOISE: float

const NOISE_INTERVAL := 0.4

func _ready() -> void:
	win_height = get_viewport_rect().size.y
	p_height = $ColorRect.get_size().y
	CPU_SPEED_FACTOR = GameSettings.cpu_factor
	CPU_NOISE = GameSettings.noise

func _process(delta: float) -> void:
	ball_pos = $"../Ball".position
	noise_timer -= delta
	if noise_timer <= 0.0:
		target_y = ball_pos.y + randf_range(-CPU_NOISE, CPU_NOISE)
		noise_timer = NOISE_INTERVAL
	dist = position.y - target_y
	if abs(dist) > get_parent().PADDLE_SPEED * delta:
		move_by = get_parent().PADDLE_SPEED * delta * (dist / abs(dist)) * CPU_SPEED_FACTOR
	else:
		move_by = dist
	position.y -= move_by
	var bottom_limit = get_parent().BOTTOM_WALL_Y - p_height / 2
	position.y = clamp(position.y, p_height / 2, bottom_limit)
