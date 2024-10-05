extends Node2D

@onready var http = $HTTPRequest
@onready var leaderboard = $Panel/VBoxContainer/HBoxContainer/Leaderboard
@onready var start_button = $Panel/VBoxContainer/HBoxContainer/VBoxContainer/StartButton
@onready var quit_button = $Panel/VBoxContainer/HBoxContainer/VBoxContainer/QuitButton
@onready var name_input = $Panel/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/NameTextEdit
@onready var audio = $Audio
@onready var error_label = $Panel/VBoxContainer/HBoxContainer/VBoxContainer/ErrorLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.menu = self
	Game.load_data()
	Audio.setup(audio)
	Audio.set_volume("sfx", Global.options.sound_volume)
	Audio.set_volume("music", Global.options.music_volume)
	name_input.text = Global.options.name
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	name_input.text_changed.connect(_on_name_changed)
	http.request_completed.connect(_on_request_completed)
	http.request("https://podium.altralogica.it/l/binocle-example/top/0?pageSize=10")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	for member in json["members"]:
		var label := Label.new()
		label.text = "{0}. {1} {2}".format([member["rank"], Utils.hms(member["score"]), member["publicID"]])
		leaderboard.add_child(label)

func _on_start_pressed():
	if Global.options.name != "":
		error_label.visible = false
		Game.save_data()
		var scene = load("res://src/main/main.tscn")
		var instance = scene.instantiate()
		get_tree().change_scene_to_file("res://src/main/main.tscn")
		#get_tree().root.add_child(instance)
	else:
		error_label.visible = true

func _on_quit_pressed():
	get_tree().quit()
	
func _on_name_changed():
	Global.options.name = name_input.text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ct_input"):
		Global.inputType = Global.InputType.INPUT_CONTROLLER
	if Input.is_action_just_pressed("kb_input"):
		Global.inputType = Global.InputType.INPUT_KEYBOARD
