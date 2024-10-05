extends RigidBody2D

@onready var area_2d = $Area2D
@onready var left_wing = $"Visuals/Left Wing"
@onready var right_wing = $"Visuals/Right Wing"

enum BeeState {
	BEE_STATE_CHASE,
	BEE_STATE_IDLE,
	BEE_STATE_GO_HOME,
	BEE_STATE_PICK_WAX,
	BEE_STATE_HEAL_HIVE,
}

var freq := 0.1
var amplitude := 400.0
var time := 0.0
var target: Node = null
var max_speed = 500.0
var damage := 1.0
var home_position := Vector2.ZERO
var game_state := BeeState.BEE_STATE_IDLE
var wing_rotation := 0.0
var wing_rotation_sign := 1.0

func _ready():
	area_2d.body_entered.connect(hit)
	home_position = position

func _process(delta):
	time += delta
	wing_rotation = (wing_rotation + delta * 60 * wing_rotation_sign) / 14 * 14
	if wing_rotation > 14 or wing_rotation < 0:
		wing_rotation_sign *= -1
	right_wing.rotation_degrees = wing_rotation
	left_wing.rotation_degrees = -wing_rotation

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if game_state == BeeState.BEE_STATE_IDLE:
		var vel :Vector2 = Vector2.ZERO
		vel.x = sin(PI/2 * time) * freq * amplitude
		vel.y = sin(PI * time) * freq * amplitude
		linear_velocity = vel
	elif game_state == BeeState.BEE_STATE_CHASE and target != null:
		var dir = target.position - position
		var dist = dir.length()
		dir = dir.normalized()

		var speedScale = 1.0# - (1.0 / ((max(0.0, dist - 60.0) / 50.0) + 1.0))
		var speed = max(max_speed/3.33, speedScale * max_speed)

		var vel = dir * speed

		linear_velocity = vel
	elif game_state == BeeState.BEE_STATE_PICK_WAX:
		if position.distance_to(target.position) <= 70:
			Global.state.wax += 1
			game_state = BeeState.BEE_STATE_GO_HOME

		var dir = target.position - position
		var dist = dir.length()
		dir = dir.normalized()

		var speedScale = 1.0 - (1.0 / ((max(0.0, dist - 60.0) / 50.0) + 1.0))
		var speed = max(max_speed/3.33, speedScale * max_speed)

		var vel = dir * speed

		linear_velocity = vel
	elif game_state == BeeState.BEE_STATE_HEAL_HIVE:
		var dir = target.position - position
		var dist = dir.length()
		dir = dir.normalized()

		var speedScale = 1.0 #- (1.0 / ((max(0.0, dist - 60.0) / 50.0) + 1.0))
		var speed = max(max_speed/3.33, speedScale * max_speed)

		var vel = dir * speed

		linear_velocity = vel
	else :
		if position.distance_to(home_position) <= 10:
			game_state = BeeState.BEE_STATE_IDLE

		var dir = home_position - position
		var dist = dir.length()
		dir = dir.normalized()

		var speedScale = 1.0 - (1.0 / ((max(0.0, dist - 60.0) / 50.0) + 1.0))
		var speed = max(max_speed/3.33, speedScale * max_speed)

		var vel = dir * speed

		linear_velocity = vel

func hit_enemy(enemy:Node2D):
	Utils.spawn(preload("res://src/particle/bullet_pop/bullet_pop_wall.tscn"), position, get_parent())
	game_state = BeeState.BEE_STATE_GO_HOME
	target = null

func chase_target(t: Node2D):
	target = t
	game_state = BeeState.BEE_STATE_CHASE

func pick_wax(t: Node2D):
	target = t
	game_state = BeeState.BEE_STATE_PICK_WAX

func heal_hive(t: Node2D):
	target = t
	game_state = BeeState.BEE_STATE_HEAL_HIVE

func hit(body):
	print("hit by ", body)
	if not body or not is_instance_valid(body):
		return

	if body.is_in_group("hive") and game_state == BeeState.BEE_STATE_HEAL_HIVE:
		if Global.state.wax > 0:
			Global.state.wax -= 1
			Global.hive.heal(1)
		game_state = BeeState.BEE_STATE_GO_HOME


