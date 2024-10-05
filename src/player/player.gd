extends CharacterBody2D

@onready var Bullet = preload("res://src/element/bullet/bullet.tscn")
@onready var ActionLabel = preload("res://src/element/action_label/action_label.tscn")
@onready var Bee = preload("res://src/element/bee/bee.tscn")

var shooting = 0.0
var moving = 0.0
var fireRate := 2.0
var shootTimer := 0.0
var max_speed = 200.0
var knockbackVel := Vector2.ZERO
var hitTimer := 0.0
var aimAngle := Vector2.ZERO

var bpm = 80
var command_complete_time := 1.0
var input_complete_time := 0.2
var input_timer := 0.0
var input_min_timer := 0.0
var command: Array[Global.PlayerAction] = []

func _ready():
	Global.player = self

func _process(delta):
	if Global.main.paused:
		return

	input_timer -= delta
	input_min_timer -= delta

	if Input.is_action_pressed("bee") and input_min_timer <= 0:
		input_timer = command_complete_time
		input_min_timer = input_complete_time
		perform_action(Global.PlayerAction.PLAYER_ACTION_BEE)

	if Input.is_action_pressed("bada") and input_min_timer <= 0:
		input_timer = command_complete_time
		input_min_timer = input_complete_time
		perform_action(Global.PlayerAction.PLAYER_ACTION_BADA)

	if Input.is_action_pressed("bon") and input_min_timer <= 0:
		input_timer = command_complete_time
		input_min_timer = input_complete_time
		perform_action(Global.PlayerAction.PLAYER_ACTION_BON)

	if Input.is_action_pressed("boo") and input_min_timer <= 0:
		input_timer = command_complete_time
		input_min_timer = input_complete_time
		perform_action(Global.PlayerAction.PLAYER_ACTION_BOO)

	if input_timer <= 0 and command.size() > 0:
		execute_command(command)


func _physics_process(delta):
	shooting -= 10.0 * delta
	hitTimer -= 1.0 * delta
	var moveDir = Vector2.ZERO

	if Input.is_action_pressed("right"):
		moveDir.x += 1
	else:
		moveDir.x += Input.get_action_strength("ct_right")

	if Input.is_action_pressed("left"):
		moveDir.x -= 1
	else:
		moveDir.x -= Input.get_action_strength("ct_left")

	if Input.is_action_pressed("up"):
		moveDir.y -= 1
	else:
		moveDir.y -= Input.get_action_strength("ct_up")

	if Input.is_action_pressed("down"):
		moveDir.y += 1
	else:
		moveDir.y += Input.get_action_strength("ct_down")

	if moveDir.length() > 0.001:
		moving = 1.0

	if Input.is_action_pressed("ct_shoot") or Input.is_action_pressed("shoot"):
		shooting = 1.0

	if Global.inputType == Global.InputType.INPUT_KEYBOARD:
		aimAngle = get_local_mouse_position().normalized()
	else:
		var vec = Input.get_vector("ct_aim_left", "ct_aim_right", "ct_aim_up", "ct_aim_down")
		if vec.length() > 0.1:
			aimAngle = vec.normalized()

	shootTimer -= 1.0 * delta
	if shootTimer <= 0.0 and (Input.is_action_pressed("ct_shoot") or Input.is_action_pressed("shoot")):
		shootTimer = 1.0 / fireRate
		Audio.play(preload("res://src/sfx/shoot.wav"))
		var angle = aimAngle
		Utils.spawn(Bullet, position, get_parent(), {angle = angle})
		Global.stats.total_bullets_fired +=1

	moveDir = moveDir.limit_length(1.0)

	velocity = Utils.lexp(velocity, moveDir * max_speed, 20.0 * delta)
	knockbackVel = Utils.lexp(knockbackVel, Vector2.ZERO, 20.0 * delta)
	velocity += knockbackVel
	move_and_slide()

func hit_enemy(enemy:Node2D):
	if "knockback" in enemy:
		enemy.knockback(position)
	knockback(enemy.position)

	if hitTimer <= 0.0:
		damage(1)
	else:
		Audio.play(preload("res://src/sfx/hit.wav"), 0.8, 1.2)

func knockback(from:Vector2, strength = 1.0):
	knockbackVel = strength * 500.0 * (global_position - from).normalized()

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
		hitTimer = 0.3

func kill():
	var a = func():
		process_mode = Node.PROCESS_MODE_DISABLED
	a.call_deferred()
	visible = false
	Global.state.dead = true
	Global.main.game_over()


func perform_action(action: Global.PlayerAction):
	command.push_back(action)
	match action:
		Global.PlayerAction.PLAYER_ACTION_BEE:
			Audio.play(preload("res://src/sfx/bee.wav"), 0.8, 1.2)
			Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "1 - Bee"})
		Global.PlayerAction.PLAYER_ACTION_BADA:
			Audio.play(preload("res://src/sfx/bada.wav"), 0.8, 1.2)
			Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "2 - Bada"})
		Global.PlayerAction.PLAYER_ACTION_BON:
			Audio.play(preload("res://src/sfx/bon.wav"), 0.8, 1.2)
			Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "3 - Bon"})
		Global.PlayerAction.PLAYER_ACTION_BOO:
			Audio.play(preload("res://src/sfx/boo.wav"), 0.8, 1.2)
			Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "4 - Boo"})
		_:
			pass

func execute_command(cmd: Array[Global.PlayerAction]):
	if (cmd.size() == 4
		and cmd[0] == Global.PlayerAction.PLAYER_ACTION_BEE
		and cmd[1] == Global.PlayerAction.PLAYER_ACTION_BEE
		and cmd[2] == Global.PlayerAction.PLAYER_ACTION_BADA
		and cmd[3] == Global.PlayerAction.PLAYER_ACTION_BEE):
			Audio.play(preload("res://src/sfx/yeah.wav"), 0.8, 1.2)
			Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "Yeah!"})
			do_attack_wasps()

	elif (cmd.size() == 4
		and cmd[0] == Global.PlayerAction.PLAYER_ACTION_BADA
		and cmd[1] == Global.PlayerAction.PLAYER_ACTION_BADA
		and cmd[2] == Global.PlayerAction.PLAYER_ACTION_BADA
		and cmd[3] == Global.PlayerAction.PLAYER_ACTION_BEE):
			Audio.play(preload("res://src/sfx/yeah.wav"), 0.8, 1.2)
			Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "Yeah!"})
			do_spawn_bee()

	elif (cmd.size() == 4
		and cmd[0] == Global.PlayerAction.PLAYER_ACTION_BON
		and cmd[1] == Global.PlayerAction.PLAYER_ACTION_BON
		and cmd[2] == Global.PlayerAction.PLAYER_ACTION_BADA
		and cmd[3] == Global.PlayerAction.PLAYER_ACTION_BEE):
			Audio.play(preload("res://src/sfx/yeah.wav"), 0.8, 1.2)
			Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "Yeah!"})
			do_heal_hive()

	elif (cmd.size() == 4
		and cmd[0] == Global.PlayerAction.PLAYER_ACTION_BOO
		and cmd[1] == Global.PlayerAction.PLAYER_ACTION_BOO
		and cmd[2] == Global.PlayerAction.PLAYER_ACTION_BON
		and cmd[3] == Global.PlayerAction.PLAYER_ACTION_BEE):
			Audio.play(preload("res://src/sfx/yeah.wav"), 0.8, 1.2)
			Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "Yeah!"})
			do_pick_wax()

	else:
		Audio.play(preload("res://src/sfx/wrong.wav"), 0.8, 1.2)
		Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "Wrong!"})


	cmd.clear()

func do_attack_wasps():
	var bees = get_tree().get_nodes_in_group("bee").filter(func a(b):
		return b.process_mode != PROCESS_MODE_DISABLED
		)
	var wasps = get_tree().get_nodes_in_group("enemy").filter(func a(b):
		return b.process_mode != PROCESS_MODE_DISABLED
		)

	if wasps.size() == 0:
		return

	for bee in bees:
		if wasps.size() > 0:
			bee.chase_target(wasps[0])
			wasps.pop_front()
		pass

func do_spawn_bee(force: bool = false):
	if Global.state.wax > 0 or force:
		if !force:
			Global.state.wax -= 1

		var pos:Vector2 = Global.main.bees_home.position
		pos.x += randf_range(-100, 100)
		pos.y += randf_range(-100, 100)
		Utils.spawn(Bee, pos, Global.main.gameArea)
	else:
		Utils.spawn(ActionLabel, Vector2.ZERO, Global.main.actions, {t = "Not enough wax!"})
		Audio.play(preload("res://src/sfx/wrong.wav"), 0.8, 1.2)

func do_pick_wax():
	var bees = get_tree().get_nodes_in_group("bee").filter(func a(b):
		return b.process_mode != PROCESS_MODE_DISABLED
		)
	var flowers = get_tree().get_nodes_in_group("flower")

	if flowers.size() == 0:
		return

	for bee in bees:
		var idx := int(randf() * (flowers.size()-1))
		bee.pick_wax(flowers[idx])

func do_heal_hive():
	var bees = get_tree().get_nodes_in_group("bee").filter(func a(b):
		return b.process_mode != PROCESS_MODE_DISABLED
		)

	for bee in bees:
		bee.heal_hive(Global.hive)
