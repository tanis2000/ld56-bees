extends Node2D

@onready var text = $PanelContainer/MarginContainer/Text

var args := {
	t = "",
}

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_degrees = randf_range(-10, 10)
	text.text = args.t
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(0, 100), 1).set_trans(Tween.TRANS_SINE)
	tween.set_parallel()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1).set_trans(Tween.TRANS_SINE)
	tween.set_parallel(false)
	tween.tween_callback(self.queue_free)

