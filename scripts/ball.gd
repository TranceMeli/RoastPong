extends CharacterBody2D

var win_size: Vector2
const START_SPEED: int = 300
const ACCEL: int = 20
var speed: int
var dir: Vector2
const MAX_Y_VECTOR: float = 0.6

func _ready() -> void:
	win_size = get_viewport_rect().size

func new_ball():
	position.x = win_size.x / 2
	position.y = randi_range(200, win_size.y - 200)
	speed = GameSettings.ball_speed
	dir = random_direction()

func random_direction():
	var new_dir := Vector2()
	new_dir.x = [1, -1].pick_random()
	new_dir.y = randf_range(-1, 1)
	return new_dir.normalized()

func _physics_process(delta):
	var collision = move_and_collide(dir * speed * delta)
	if collision:
		var collider = collision.get_collider()
		if collider == $"../CPU" or collider == $"../CPU2":
			speed += ACCEL
			dir = new_direction(collider)
			get_parent().sound_paddle.play()
		else:
			dir = dir.bounce(collision.get_normal())
			get_parent().sound_wall.play()

func new_direction(collider):
	var ball_y = position.y
	var pad_y = collider.position.y
	var dist = ball_y - pad_y
	var new_dir := Vector2()

	if dir.x > 0:
		new_dir.x = -1
	else:
		new_dir.x = 1
	new_dir.y = (dist / (collider.p_height / 2)) * MAX_Y_VECTOR
	return new_dir.normalized()
