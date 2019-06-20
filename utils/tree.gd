extends Node

# Stores the array representation of the tree
var storage : Array = []

# Alphabet for assiging position id's
var alphabet : Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

# Default alphabet letter for new generations / sub-generations
var defaultindex : int = 12

# Removes an item from the tree, with all it's children
func remove_item(item : String) -> void:
	for i in range(storage.size() - 1, -1, -1):
		if storage[i]["id"] == item or storage[i]["data"]["parent"] == item:
			storage.remove(i)

# Gets an item by id from the tree
func get_item(item : String):
	for entry in storage:
		if entry["id"] == item:
			return entry

# Gets data for an item by id from the tree
func get_item_data(item : String):
	for entry in storage:
		if entry["id"] == item:
			return entry["data"]

# Sets data for an item by id from the tree
func set_item_data(item : String, data) -> void:
	for entry in storage:
		if entry["id"] == item:
			entry["data"] = data

# Adds an item to the tree. If no parent is given, adds it as root
func add_item(parent, near, section : int, item : Dictionary):
	if parent == null && storage.size() > 0:
		print("Root already exists!")
		return false
	elif parent == null && storage.size() == 0:
		# Add as root of the tree
		storage.append({"data": item, "position": alphabet[defaultindex], "id": item['id']})
	else:
		# Find our parent and near items
		var parent_item = null
		var near_item = null

		for entry in storage:
			if entry["id"] == parent:
				parent_item = entry

			if entry["id"] == near:
				near_item = entry

		if !parent_item:
			print("Parent " + parent + " does not exist in the tree!")
			return false

		if parent == near && section == 0:
			# If parent and near are equal, and we have no ABOVE / BELOW position, add as last child                
			storage.append({"data": item, "position": parent_item["position"] + ":" + get_child_position(parent_item["position"], alphabet[defaultindex], section, true), "id": item["id"]})
		else:
			var start_at_letter = near_item["position"].replace(parent_item["position"] + ":", "")

			# If parent and near are different, we are somewhere in between
			storage.append({"data": item, "position": near_item["position"] + get_child_position(near_item["position"], alphabet[defaultindex], section , false), "id": item["id"]})

	# Finally sort tree!
	storage.sort_custom(self, "sort_by_position")

	return item

# Gets a new letter from the alphabet depending on the child location
func get_child_position(parent_position : String, start_position : String, section : int, is_last : bool = false) -> String:
	var next_free_letter = null
	var check_letter = start_position
	var check_index = alphabet.find(check_letter)

	while !next_free_letter:
		var found = false

		for entry in storage:
			if entry["position"] == parent_position + ( ":" if is_last else "" ) + check_letter:
				found = true # Already exists

		if !found:
			next_free_letter = check_letter
		else:
			if section == -1:
				check_index = check_index - 1

				if check_index > -1:
					check_letter = alphabet[check_index]  
				else:
					print("This generation is full (lower bound)!")
			elif section == 0 or section == 1:
				check_index = check_index + 1

				if check_index < alphabet.size():
					check_letter = alphabet[check_index]
				else:
					print("This generation is full (high bound!")
					return ""

	return next_free_letter

func sort_by_position(a : Dictionary, b : Dictionary) -> bool:
	return a["position"] < b["position"]

# Returns the tree in array form
func get_tree_as_array() -> Array:
	return storage

# Sets the tree (expects array)
func set_tree_from_array(tree : Array) -> void:
	storage = tree
