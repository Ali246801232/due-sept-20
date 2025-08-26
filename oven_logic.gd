extends Node

@export var sprite_texture: Texture2D
func get_sprite_texture():
	sprite_texture = load("res://sprites/test_interactable.png")
	return sprite_texture

func get_states() -> Array:
	return [
		{
			"pre_action": Callable(self, "take_item_from_player"),
			"wait_time": 5.0,
			"auto_end": false,
			"post_action": Callable(self, "finish_cooking"),
			"next_state": 1
		},
		{
			"pre_action": Callable(self, "give_item_to_player"),
			"next_state": 0
		}
	]

func take_item_from_player():
	print("Player puts raw item in oven")

func finish_cooking():
	print("Oven finished cooking, ready to pick up")

func give_item_to_player():
	print("Player takes cooked item from oven")
