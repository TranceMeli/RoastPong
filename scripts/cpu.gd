extends StaticBody2D

var p_height: float
var shape_offset_y: float
var target_y: float = 0.0
var noise_timer: float = 0.0

var CPU_SPEED_FACTOR: float
var CPU_NOISE: float

const NOISE_INTERVAL := 0.4

func _ready() -> void:
	# Masse aus der Kollisionsform: das ColorRect ist ausgeblendet und kleiner als die Hitbox
	p_height = $CollisionShape2D.shape.size.y
	shape_offset_y = $CollisionShape2D.position.y
	CPU_SPEED_FACTOR = GameSettings.cpu_factor
	CPU_NOISE = GameSettings.noise
	position.y = (get_parent().BOTTOM_WALL_Y / 2.0) - shape_offset_y
	target_y = position.y

func center_y() -> float:
	return position.y + shape_offset_y

func _process(delta: float) -> void:
	var ball = $"../Ball"
	noise_timer -= delta
	if noise_timer <= 0.0:
		if ball.visible:
			target_y = ball.position.y + randf_range(-CPU_NOISE, CPU_NOISE)
		else:
			target_y = get_parent().BOTTOM_WALL_Y / 2.0
		noise_timer = NOISE_INTERVAL
	var step: float = get_parent().PADDLE_SPEED * CPU_SPEED_FACTOR * delta
	var c := center_y()
	c += clamp(target_y - c, -step, step)
	var half := p_height / 2.0
	c = clamp(c, half, get_parent().BOTTOM_WALL_Y - half)
	position.y = c - shape_offset_y
