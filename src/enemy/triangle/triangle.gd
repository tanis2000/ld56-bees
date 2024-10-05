extends RigidBody2D

@onready var enemy = $Enemy

var points:Array[Vector2] = []
var max_speed := 180.0
var knockbackVel := Vector2.ZERO
var delta := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 3:
		points.push_back(22.0*Vector2.from_angle(TAU*i/3.0))
	points.push_back(points[0])

	rotation = randf() * TAU

	$Line2D.points = PackedVector2Array(points)

	#enemy.spawn()

func _physics_process(delta):
	self.delta = delta
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	knockbackVel = Utils.lexp(knockbackVel, Vector2.ZERO, 20.0 * delta)

	var dir = Global.player.position - position
	var dist = dir.length()
	dir = dir.normalized()
	
	var speedScale = 1.0 - (1.0 / ((max(0.0, dist - 60.0) / 50.0) + 1.0))
	var speed = max(max_speed/3.33, speedScale * max_speed)
	
	var vel = dir * speed
	
	#position += vel * delta
	linear_velocity = vel + knockbackVel
	angular_velocity = TAU*0.1

func kill(soft := false):
	if not soft:
		Audio.play(preload("res://src/sfx/enemy-die.wav"), 0.8, 1.2)
	for i in 4:
		Utils.spawn(preload("res://src/particle/enemy_pop/enemy_pop.tscn"), position, get_parent(), {color = $Line2D.default_color})

	Global.stats.total_enemies_killed += 1

	queue_free()

func knockback(from:Vector2):
	knockbackVel = 2000.0 * (position - from).normalized()
	enemy.flash()
