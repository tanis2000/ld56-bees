extends Node2D

@onready var Bee = preload("res://src/element/bee/bee.tscn")
@onready var Wasp = preload("res://src/enemy/wasp/wasp.tscn")

@onready var gameArea = $gameArea
@onready var camera = $Camera2D
@onready var player = $gameArea/Player
@onready var hive = $gameArea/Hive
@onready var bees_home = $gameArea/BeesHome
@onready var wasps_home = $gameArea/WaspsHome

@onready var audio = $Audio
@onready var actions = $Actions
@onready var http = $HTTPRequest

var paused :=  true
var spawn_timer := 8.0

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.main = self

	Global.state.time_elapsed = 0
	Global.state.wax = 0

	Audio.setup(audio)
	http.request_completed.connect(_on_request_completed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused:
		return

	Global.state.time_elapsed += delta

	spawn_timer -= delta

	if Input.is_action_just_pressed("ct_input"):
		Global.inputType = Global.InputType.INPUT_CONTROLLER
	if Input.is_action_just_pressed("kb_input"):
		Global.inputType = Global.InputType.INPUT_KEYBOARD

	var enemy_count = get_tree().get_nodes_in_group("enemy").size()

	if spawn_timer <= 0.0:
		spawn_timer = 0.35 + 4 * (1.0 / (pow(max(0.0, Global.state.time_elapsed - 4.5), 1.66)/2000.0 + 5.0))
		spawn_timer *= (1.0 / (pow(Global.state.time_elapsed/1200.0, 3.0) + 1.0)) + 0.02
		spawn_timer *= 1.0 - (1.0 / (7.0 + pow(2.0, 22.0 - 0.5*Global.state.time_elapsed)))
		spawn_timer *= 1.0 - (1.0 / (2.0*pow(Global.state.time_elapsed,0.4) - 7.0 + pow(2.0, 0.03*pow(Global.state.time_elapsed-50.0, 2.0))))
		if Global.state.time_elapsed > 60.0 * 2.0:
			if randf() < 0.05 + 0.05 * pow(Global.state.time_elapsed / 600.0, 0.5):
				spawn_timer *= 4.0
		spawn_timer *= 1.0 + 0.7 * pow(max(0, enemy_count - 6.0) / 5.0, 1.5) / (1.0 + (Global.state.time_elapsed / 600.0))
		#spawn_timer *= 2.5
		spawn_timer *= 7.5

		var randCountCap = 0.3 + 3.0 * pow(Global.state.time_elapsed / 100.0, 0.47) * (1.0 - (1.0 / (pow(Global.state.time_elapsed/1900.0, 1.5) + 1.0)))
		var randT = 0.35 * (1.0 - (1.0/(Global.state.time_elapsed / 800.0 + 1.0)))
		var randBase = randT + (1.0 - randT) * pow(randf(), 1.5)
		var randCount = randBase * randCountCap
		randCount += 1.0 * max(0.0, 1.0 - 0.05 * pow(Global.state.time_elapsed - 30.0, 2))
		randCount *= 2.0
		spawn_timer *= 0.9
		print(spawn_timer)
		randCount = floor(randCount)
		for i in (1 + randCount):
			var offset = 50.0 * Vector2(randf_range(-1,1), randf_range(-1,1))
			Utils.spawn(Wasp, wasps_home.position + offset, gameArea)
			Global.spawn_count += 1

func game_over():
	paused = true
	upload_score()
	var scene = load("res://src/ui/game_over/game_over.tscn")
	var instance = scene.instantiate()
	get_tree().root.add_child(instance)

func start_game():
	spawn_bees()
	spawn_wasps()

func spawn_bees():
	Global.player.do_spawn_bee()

func spawn_wasps():
	var pos:Vector2 = wasps_home.position
	pos.x += randf_range(-100, 100)
	pos.y += randf_range(-100, 100)
	Utils.spawn(Wasp, pos, Global.main.gameArea)

func upload_score():
	var data := "{\"score\":{0}}".format([Global.state.time_elapsed])
	print(data)
	var url := "https://podium.altralogica.it/l/binocle-example/members/{0}/score".format([Global.options.name])
	print(url)
	http.request(url, [], HTTPClient.METHOD_PUT, data)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
