extends Node2D

@export var sprite_texture: Texture2D = null
var states: Array = []

signal wait(time: float, post_callback: Callable)
signal show_message(message: String, image: String)
signal show_timer()
signal hide_timer()

var popup = load("res://scenes/ContainerPopup.tscn").instantiate()
var ingredients = ["Eggs", "Butter", "Milk", "Cheese"]

func _ready():
	Reset.connect("resetted", Callable(self, "_on_resetted"))

	states = [
		Callable(self, "_toggle_popup")
	]

	add_child(popup)
	popup.visible = false
	popup.set_slots(ingredients)

func _container_input():
	if not popup.visible or Freeze.is_frozen:
		return
	if Input.is_action_just_pressed("container_1"):
		_give_ingredient(1)
	if Input.is_action_just_pressed("container_2"):
		_give_ingredient(2)
	if Input.is_action_just_pressed("container_3"):
		_give_ingredient(3)
	if Input.is_action_just_pressed("container_4"):
		_give_ingredient(4)

func get_process_function():
	return Callable(self, "_container_input")

func get_states():
	return states

func on_exited_interactable():
	popup.visible = false

func on_other_interacted():
	popup.visible = false

func _give_ingredient(index):
	if Inventory.has_item() and not Inventory.holding_bowl:
		emit_signal("show_message", "You're already holding something!", 3.0)
	elif Inventory.holding_bowl and not Inventory.is_bowl_full():
		Inventory.add_ingredient(ingredients[index - 1])
	elif Inventory.holding_bowl and Inventory.is_bowl_full():
		emit_signal("show_message", "Your bowl is full!", 3.0)
	else:
		Inventory.add_item(ingredients[index - 1])

func _toggle_popup():
	if popup.visible:
		popup.visible = false
	else:
		popup.visible = true
	return 0

func _on_resetted(day):
	popup.visible = false

func last_day_state():
	ingredients = ["Cake Box", "", "", ""]
	popup.set_slots(ingredients)
