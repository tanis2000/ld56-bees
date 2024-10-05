extends Node2D

@onready var close_btn = $Panel/ScrollContainer/VBoxContainer/CloseButton

# Called when the node enters the scene tree for the first time.
func _ready():
	close_btn.pressed.connect(on_close)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_close():
	Global.main.start_game()
	Global.main.paused = false
	get_parent().remove_child(self)