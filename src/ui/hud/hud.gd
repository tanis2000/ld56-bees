extends Node2D

@onready var damage = $CanvasLayer/Damage

var damageFlashTimer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.hud = self

func _process(delta):
	if damageFlashTimer > 0.0:
		damageFlashTimer -= 2.0 * delta
		var amount = 1.0 + 30.0 * pow(damageFlashTimer, 2.0)
		damage.modulate.a = lerp(0.0, 0.5, pow(damageFlashTimer, 2.0))
		if damageFlashTimer <= 0.0:
			damage.modulate.a = 0.0


func flash_damage():
	damageFlashTimer = 1.0