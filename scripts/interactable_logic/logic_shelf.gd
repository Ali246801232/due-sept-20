extends Node2D

@export var sprite_texture: Texture2D

signal show_message(message: String, time: float)
signal wait(time: float, post_callback: Callable)
signal show_timer()
signal hide_timer()

func get_sprite_texture():
	sprite_texture = Icons.interactables["Shelf"]
	return sprite_texture

func get_states():
	return [
		Callable(self, "take_bowl")
	]

func take_bowl():
	if Inventory.has_item():
		emit_signal("show_message", "You're already holding something!", 3.0)
		return 0
	var output_inventory = Inventory.get_empty()
	output_inventory["item"] = "Bowl"
	Inventory.set_inventory(output_inventory)
	return 0
