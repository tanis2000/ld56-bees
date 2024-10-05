extends Node2D

@onready var gameArea = $gameArea
@onready var camera = $Camera2D
@onready var player = $gameArea/Player
@onready var hive = $gameArea/Hive
@onready var bees_home = $gameArea/BeesHome

@onready var left_area = $left_area
@onready var right_area = $right_area
@onready var top_area = $top_area
@onready var bottom_area = $bottom_area

@onready var audio = $Audio
@onready var actions = $Actions

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.main = self
	left_area.area_entered.connect(on_borders_hit)
	right_area.area_entered.connect(on_borders_hit)
	top_area.area_entered.connect(on_borders_hit)
	bottom_area.area_entered.connect(on_borders_hit)
	Audio.setup(audio)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ct_input"):
		Global.inputType = Global.InputType.INPUT_CONTROLLER
	if Input.is_action_just_pressed("kb_input"):
		Global.inputType = Global.InputType.INPUT_KEYBOARD

func on_borders_hit(body:Node2D):
	print("test")
	if body.is_in_group("bullet"):
		var bullet = body.get_parent()
		bullet.hitWall()

func game_over():
	var scene = load("res://src/ui/menu/menu.tscn")
	var instance = scene.instantiate()
	get_tree().change_scene_to_file.call_deferred("res://src/ui/menu/menu.tscn")
	#get_tree().root.add_child(instance)

