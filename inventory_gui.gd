extends AnimatedSprite2D

var inventory

func _ready() -> void:
	Inventory.connect("update_inventory", Callable(self, "redraw_inventory"))

func redraw_inventory():
	inventory = Inventory.get_inventory()

	# Handle single inventory item
	var item_node = $Item
	if Inventory.has_item():
		item_node.visible = true
		item_node.texture = Icons.items[inventory["item"]]
	else:
		item_node.visible = false

	# Show or hide bowl slots
	if Inventory.holding_bowl:
		play("inventory_bowl")
	else:
		play("inventory_no_bowl")

	# Fill bowl slots and extenders for multi-width ingredients
	for i in range(Inventory.bowl_size):
		var bowl_slot = get_node("Bowl" + str(i))
		var extender = null
		if i > 0:
			extender = get_node("Extender" + str(i))

		if not Inventory.holding_bowl or inventory["bowl"][i] == "":
			bowl_slot.visible = false
			if extender: extender.visible = false
		elif inventory["bowl"][i] == Inventory.continue_marker:
			bowl_slot.visible = false
			if extender: extender.visible = true
		else:
			bowl_slot.texture = Icons.items[inventory["bowl"][i]]
			bowl_slot.visible = true
			if extender: extender.visible = false
