extends RigidBody2D

@onready var enemy = $Enemy
@onready var poly = $Visuals/Polygon2D
@onready var left_wing = $"Visuals/Left Wing"
@onready var right_wing = $"Visuals/Right Wing"

var max_speed := 90.0 #180.0
var knockbackVel := Vector2.ZERO
var delta := 0.0
var wing_rotation := 0.0
var wing_rotation_sign := 1.0

func _physics_process(delta):
	self.delta = delta
	wing_rotation = (wing_rotation + delta * 60 * wing_rotation_sign) / 14 * 14
	if wing_rotation > 14 or wing_rotation < 0:
		wing_rotation_sign *= -1
	right_wing.rotation_degrees = wing_rotation
	left_wing.rotation_degrees = -wing_rotation

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	knockbackVel = Utils.lexp(knockbackVel, Vector2.ZERO, 20.0 * delta)

	var dir = Global.hive.position - position
	var dist = dir.length()
	dir = dir.normalized()

	#var speedScale = 1.0 - (1.0 / ((max(0.0, dist - 60.0) / 50.0) + 1.0))
	var speedScale = 1.0 - (1.0 / ((max(0.0, dist - 20.0) / 50.0) + 1.0))
	var speed = max(max_speed/3.33, speedScale * max_speed)

	var vel = dir * speed

	linear_velocity = vel + knockbackVel

func knockback(from:Vector2):
	knockbackVel = 2000.0 * (position - from).normalized()
	enemy.flash()

func kill(soft := false):
	if not soft:
		Audio.play(preload("res://src/sfx/enemy-die.wav"), 0.8, 1.2)
	for i in 4:
		Utils.spawn(preload("res://src/particle/enemy_pop/enemy_pop.tscn"), position, get_parent(), {color = poly.color})

	Global.stats.total_enemies_killed += 1

	queue_free()
