extends RigidBody2D

@onready var bodyShape = $CollisionShape2D
@onready var areaShape = $Area2D/CollisionShape2D
@onready var visual = $Polygon2D

var hitTimer := 0.0

func _ready():
	Global.hive = self
	Global.state.health = Global.state.max_health

func _physics_process(delta):
	hitTimer -= 1.0 * delta

func hit_enemy(enemy:Node2D):
	if "knockback" in enemy:
		enemy.knockback(position)

	if hitTimer <= 0.0:
		damage(1)

func damage(amount:float = 1.0):
	if hitTimer <= 0.0:
		Audio.play(preload("res://src/sfx/hit.wav"), 0.8, 1.2)
		Global.hud.flash_damage()
		for i in 3:
			Utils.spawn(preload("res://src/particle/enemy_pop/enemy_pop.tscn"), position, get_parent(), {color = Color(0.831, 0.11, 0.204)})
		Global.state.health -= amount
		if Global.state.health <= 0:
			#TODO: game over screen
			kill()
			return
		var sc :float = 1.0 * Global.state.health / Global.state.max_health
		visual.scale.x = sc
		visual.scale.y = sc
		bodyShape.scale.x = sc
		bodyShape.scale.y = sc
		areaShape.scale.x = sc
		areaShape.scale.y = sc
		hitTimer = 0.3

func kill():
	var a = func():
		process_mode = Node.PROCESS_MODE_DISABLED
	a.call_deferred()
	visible = false
	Global.state.dead = true
	Global.main.game_over()

func heal(amount: float = 1.0):
	Global.state.health += amount