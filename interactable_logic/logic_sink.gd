extends Node2D

@export var sprite_texture: Texture2D

signal show_message(message: String, time: float)
signal wait(time: float, post_callback: Callable)
signal show_timer()
signal hide_timer()

func get_sprite_texture():
	sprite_texture = Icons.interactables["Sink"]
	return sprite_texture

func get_states():
	return [
		Callable(self, "take_water")
	]

func take_water():
	if Inventory.has_item() and not Inventory.holding_bowl:
		emit_signal("show_message", "You're already holding something!", 3.0)
	elif Inventory.holding_bowl and not Inventory.is_bowl_full():
		Inventory.add_ingredient("Water")
	elif Inventory.holding_bowl and Inventory.is_bowl_full():
		emit_signal("show_message", "Your bowl is full!", 3.0)
	elif not Inventory.has_item():
		Inventory.add_item("Water")
	return 0
