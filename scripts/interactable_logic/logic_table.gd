extends Node2D

@export var sprite_texture: Texture2D = null
var states: Array = []

@onready var storage_sprite

signal show_message(message: String, time: float)
signal wait(time: float, post_callback: Callable)
signal show_timer()
signal hide_timer()

func _ready():
	Reset.connect("resetted", Callable(self, "_on_resetted"))

	storage_sprite = get_parent().get_node("StorageSprite")
	storage_sprite.visible = false

	states = [
		Callable(self, "_swap_inventory")
	]

func get_sprite_texture():
	return sprite_texture

func get_process_function():
	return Callable(self, "_display_storage")

func get_states():
	return states

func _display_storage():
	pass

var storage = Inventory.get_empty()

func _swap_inventory():
	if not Inventory.has_item():
		storage_sprite.visible = false
	else:
		storage_sprite.visible = true
		if Inventory.holding_bowl:
			if Inventory.is_bowl_empty():
				storage_sprite.texture = Icons["items"].get("Empty Bowl", null)
			else:
				storage_sprite.texture = Icons["items"].get("Filled Bowl", null)
		else:
			storage_sprite.texture = Icons["items"].get(Inventory.current_item, null)
	var inventory = Inventory.get_inventory()
	Inventory.set_inventory(storage)
	storage = inventory
	return 0

func _on_resetted(day):
	storage = Inventory.get_empty()
