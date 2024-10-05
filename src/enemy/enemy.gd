extends Node

@onready var parent:Node2D = get_parent()
@onready var area_2d = $"../Area2D"

@export var health := 1.0

var flashTimer := 0.0
var flashColor := Color.WHITE
var killed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.body_entered.connect(hit)
	parent.add_to_group("enemy")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	flashTimer = max(0.0, flashTimer - 10.0 * delta)
	var flashValue: float = 1.0 + 200.0 * flashTimer
	if flashColor == Color.WHITE:
		parent.modulate = Color(flashValue, flashValue, flashValue, 1.0)
	else:
		parent.modulate = Color(flashValue, 1.0 - pow(flashTimer, 4.0),  1.0 - pow(flashTimer, 4.0), 1.0)

func flash(red := false):
	flashColor = Color(1.0, 0.0, 0.0, 1.0) if red else Color.WHITE
	flashTimer = 2.0 if red else 1.0

func hit(body):
	print("hit by ", body)
	if not body or not is_instance_valid(body):
		return
	if body.is_in_group("bullet"):
		print("bullet")
		body.get_parent().hit_enemy(parent)
		if "hitBullet" in parent:
			parent.hitBullet(body.get_parent())
		damage(body.get_parent().damage)

	if body.is_in_group("hive"):
		body.hit_enemy(parent)

	if body.is_in_group("player"):
		body.hit_enemy(parent)

	if body.is_in_group("bee"):
		body.hit_enemy(parent)
		if "hit_bee" in parent:
			parent.hit_bee(body.get_parent())
		damage(body.damage)

func damage(amount:float, bypass := false):
	Audio.play(preload("res://src/sfx/hit.wav"), 0.8, 1.2)
	flash()
	health -= amount
	updateHealth()

func updateHealth():
	if health <= 0.0:
		if not killed:
			killed = true
			parent.kill()
