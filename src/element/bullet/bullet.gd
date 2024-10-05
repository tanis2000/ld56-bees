extends Node2D

var args := {
	angle = Vector2.RIGHT,
	speed = 1200.0
}

var angle := Vector2.RIGHT
var speed := 0.0
var timer := 0.0
var damage = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	print("bullet shot")
	rotation = args.angle.angle()
	angle = args.angle
	speed = args.speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var vel = angle * speed
	position += vel * delta
	rotation = angle.angle()

	timer += delta
	if timer > 4.0:
		queue_free()

func _draw():
	draw_circle(Vector2.ZERO, 5.0, Color.WHITE)
	scale.x = 2.0

func hitWall(side:int = 0):
	Utils.spawn(preload("res://src/particle/bullet_pop/bullet_pop_wall.tscn"), position, get_parent())
	queue_free()

func hit_enemy(enemy:Node2D):
	Utils.spawn(preload("res://src/particle/bullet_pop/bullet_pop_wall.tscn"), position, get_parent())
	speed *= 0.667