extends Node


func spawn(scene:Resource, position:Vector2, parent:Node, args:Dictionary = {}) -> Node:
	var inst = scene.instantiate()
	var iargs = inst.get("args")
	if iargs != null:
		iargs.merge(args, true)
	inst.position = position
	#parent.add_child(inst)
	parent.call_deferred("add_child", inst)
	return inst

func lexp(a:Variant, b:Variant, t:float):
	return a + (b - a) * (1.0 - exp(-t))

func hms(totalSeconds := 0.0, decimalPlaces := 0, leadingZero := false):
	var decimals = fposmod(totalSeconds, 1.0)
	var timeSign = "" if totalSeconds >= 0.0 else "-"
	var totalSecondsI := int(totalSeconds)
	var seconds := totalSecondsI%60
	var minutes := (totalSecondsI/60)%60
	var hours := (totalSecondsI/60)/60

	#returns a string with the format "HH:MM:SS.ss"
	var base = ""
	var values = [hours, minutes, seconds]
	if leadingZero:
		base = "%02d:%02d:%02d"
	else:
		base = "%d:%02d:%02d"
	if decimalPlaces > 0:
		base += ".%0"+str(decimalPlaces)+"d"
		values += [decimals * pow(10, decimalPlaces)]
	return timeSign + (base % values)

func weightedRandom(items:Array[Dictionary]):
	var weights := []

	for i in items.size():
		var item = items[i]
		if i == 0:
			weights.push_back(item.weight)
		else:
			weights.push_back(item.weight + weights.back())

	var rand = randf() * weights.back()

	var choice := 0
	for item in items:
		if weights[choice] > rand:
			break
		choice += 1

	return items[choice]
