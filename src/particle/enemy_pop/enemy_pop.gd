extends Node2D


var args := {
				color = Color.WHITE
			}

var vel := Vector2.ZERO

func _ready():
	vel = Vector2.from_angle(randf()*TAU) * randf_range(300.0, 600.0)
	modulate = args.color

func _process(delta):
	vel *= 1.0 - (12.0 * delta)
	position += vel * delta
	scale *= 1.0 - (5.0 * delta)

	if scale.x < 0.1:
		queue_free()

func _draw():
	draw_circle(Vector2.ZERO, 6.0, Color.WHITE)
