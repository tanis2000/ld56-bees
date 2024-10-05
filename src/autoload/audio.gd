extends Node

var player_pool:Array[AudioStreamPlayer] = []
var player_ids: Array[int]               = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func setup(node: Node):
	player_pool = []
	for i in 32:
		var p = AudioStreamPlayer.new()
		node.add_child(p)
		player_pool.push_back(p)
		player_ids.push_back(-1)
		
func set_volume(bus: String = "sfx", volume := 1.0):
	volume = pow(volume, 2.0)
	if bus == "music":
		volume *= 0.5
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(volume))

func play(stream:AudioStream, pitchLower := 1.0, pitchUpper := 1.0, bus := "sfx", vol := 1.0) -> int:
	for i in player_pool.size():
		var p: AudioStreamPlayer = player_pool[i]

		if p.playing:
			continue

		p.stream = stream
		if bus == "music":
			p.pitch_scale = 1.0
		else:
			p.pitch_scale = max(0.1,randf_range(pitchLower, pitchUpper))

		p.volume_db = linear_to_db(vol)
		p.bus = bus
		p.play()
		var id: int = randi() #chance of collision is infinitesimal and the consequence is minor anyway
		player_ids[i] = id

		return id
	return -1

func play_random(streams:Array[AudioStream], pitchLower := 1.0, pitchUpper := 1.0, bus := "sfx", vol := 1.0):
	play(streams.pick_random(), pitchLower, pitchUpper, bus, vol)

func stop(id:int):
	var idx: int = player_ids.find(id)
	if idx >= 0 and idx < player_pool.size():
		player_pool[idx].stop()

func seek(id:int, time:float):
	var idx: int = player_ids.find(id)
	if idx >= 0 and idx < player_pool.size():
		player_pool[idx].seek(time)

func pitch(id:int, p:float):
	var idx = player_ids.find(id)
	if idx >= 0 and idx < player_pool.size():
		player_pool[idx].pitch_scale = max(0.1,p * Global.timescale)

func volume(id:int, v:float):
	var idx = player_ids.find(id)
	if idx >= 0 and idx < player_pool.size():
		player_pool[idx].volume_db = linear_to_db(v)
