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