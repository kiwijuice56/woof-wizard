extends Node
# Handles all save data, excluding party for bundle bugs :(

@export var data: Dictionary

func save_data() -> void:
	print(data)
	get_tree().get_root().get_node("Main/PlayerParty").save_data()
	data["spawn_room"] = get_tree().get_root().get_node("Main").current_room
	var save_file: SaveFile = SaveFile.new()
	save_file.data = data
	ResourceSaver.save(save_file, "user://save.tres")

func load_data() -> void:
	if not is_new_file():
		var save: SaveFile = ResourceLoader.load("user://save.tres")
		data = save.data
	else:
		# Starting file setup
		data = {}
		data["inventory"] = {"flan": 0, "leche": 0, "copal": 0}
		data["spawn_room"] = "origin_cave"
		data["party_config"] = [] # initialized by PlayerParty
	get_tree().get_root().get_node("Main/PlayerParty").load_data()

func is_new_file() -> bool:
	return not ResourceLoader.exists("user://save.tres")
