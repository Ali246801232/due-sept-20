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
	if not Inventory.holding_bowl:
		emit_signal("show_message", "You're not holding a bowl!", 3.0)
		return 0
	if Inventory.is_bowl_full():
		emit_signal("show_message", "Your bowl is full!", 3.0)
		return 0
	Inventory.add_ingredient("Water")
	return 0
