extends Node

@export var sprite_texture: Texture2D

signal show_message(message: String, time: float)
signal wait(time: float, post_callback: Callable)
signal show_timer()
signal hide_timer()


func get_states():
	return [
		Callable(self, "discard")
	]

func discard():
	var output_inventory = Inventory.get_empty()
	if Inventory.holding_bowl and not Inventory.is_bowl_empty():
		output_inventory["item"] = "Bowl"
	Inventory.set_inventory(output_inventory)
	return 0
