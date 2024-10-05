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
var spawn_timer := 4.0

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

	if Input.is_action_just_pressed("ct_input"):
		Global.inputType = Global.InputType.INPUT_CONTROLLER
	if Input.is_action_just_pressed("kb_input"):
		Global.inputType = Global.InputType.INPUT_KEYBOARD

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
