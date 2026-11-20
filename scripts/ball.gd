extends CharacterBody2D

const ACCEL: int = 20
const MAX_SPEED: int = 900
const MAX_Y_VECTOR: float = 0.6
const FIELD_MARGIN: int = 100

var win_size: Vector2
var speed: int = 0
var dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	win_size = get_viewport_rect().size

func stop() -> void:
	speed = 0
	dir = Vector2.ZERO
	hide()
	set_physics_process(false)

func new_ball() -> void:
	position.x = win_size.x / 2
	position.y = randi_range(FIELD_MARGIN, get_parent().BOTTOM_WALL_Y - FIELD_MARGIN)
	speed = GameSettings.ball_speed
	dir = random_direction()
	show()
	set_physics_process(true)

func random_direction() -> Vector2:
	# Winkel max. ~35 Grad, damit der Aufschlag nie fast senkrecht laeuft
	var angle := randf_range(-0.6, 0.6)
	var new_dir := Vector2.RIGHT.rotated(angle)
	if randf() < 0.5:
		new_dir.x = -new_dir.x
	return new_dir.normalized()

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(dir * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider == $"../CPU" or collider == $"../CPU2":
			speed = min(speed + ACCEL, MAX_SPEED)
			dir = new_direction(collider)
			get_parent().sound_paddle.play()
		else:
			dir = dir.bounce(collision.get_normal())
			get_parent().sound_wall.play()

func new_direction(paddle) -> Vector2:
	var dist: float = position.y - paddle.center_y()
	var new_dir := Vector2()
	new_dir.x = -1 if dir.x > 0 else 1
	new_dir.y = clamp(dist / (paddle.p_height / 2.0), -1.0, 1.0) * MAX_Y_VECTOR
	return new_dir.normalized()
