extends Node

func save_data():
	var file = FileAccess.open("user://save_data.res", FileAccess.WRITE)
	var data = {
		options = Global.options,
	}
	file.store_line(JSON.stringify(data))

func load_data():
	var file = FileAccess.open("user://save_data.res", FileAccess.READ)
	if not file:
			return
	var data:Dictionary = JSON.parse_string(file.get_line())
	if data:
		if data.has("options"):
			Global.options.merge(data.options, true)
