extends GPUParticles2D

var args := {
	color = Color.WHITE
}

func _ready():
	modulate = args.color
	emitting = true

func _process(delta):
	if not emitting:
		queue_free()
