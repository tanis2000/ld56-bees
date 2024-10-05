extends Node2D

@onready var btn = $Panel/VBoxContainer/CloseButton

# Called when the node enters the scene tree for the first time.
func _ready():
	btn.pressed.connect(close)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func close():
	get_tree().change_scene_to_file.call_deferred("res://src/ui/menu/menu.tscn")
	get_parent().remove_child(self)
