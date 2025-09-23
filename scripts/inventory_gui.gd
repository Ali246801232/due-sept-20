extends AnimatedSprite2D

var inventory

func _ready() -> void:
	visible = true
	Inventory.connect("update_inventory", Callable(self, "redraw_inventory"))
	Freeze.connect("frozen", Callable(self, "freeze"))
	Freeze.connect("unfrozen", Callable(self, "unfreeze"))

func redraw_inventory():
	inventory = Inventory.get_inventory()

	# Handle single inventory item
	var item_node = $Item
	var item_label = $LabelItem
	if Inventory.has_item():
		item_node.visible = true
		item_label.visible = true
		if not Inventory.holding_bowl:
			item_node.texture = Icons.items[inventory["item"]]
			item_label.text = inventory["item"]
	else:
		item_node.visible = false
		item_label.visible = false

	# Show or hide bowl slots
	if Inventory.holding_bowl:
		play("inventory_bowl")
		if Inventory.is_bowl_empty():
			item_node.texture = Icons.items["Empty Bowl"]
			item_label.text = "Empty Bowl"
		else:
			item_node.texture = Icons.items["Filled Bowl"]
			item_label.text = "Filled Bowl"
	else:
		play("inventory_no_bowl")

	# Fill bowl slots and extenders for multi-width ingredients
	for i in range(Inventory.bowl_size):
		var bowl_slot = get_node("Bowl" + str(i))
		var bowl_label = get_node("LabelBowl" + str(i))
		var extender = null
		if i > 0:
			extender = get_node("Extender" + str(i))

		if not Inventory.holding_bowl or inventory["bowl"][i] == "":
			bowl_slot.visible = false
			bowl_label.visible = false
			if extender: extender.visible = false
		elif inventory["bowl"][i] == Inventory.continue_marker:
			bowl_slot.visible = false
			bowl_label.visible = false
			if extender: extender.visible = true
		else:
			bowl_slot.texture = Icons.items[inventory["bowl"][i]]
			bowl_label.text = inventory["bowl"][i]
			bowl_slot.visible = true
			bowl_label.visible = true
			if extender: extender.visible = false

func freeze():
	visible = false

func unfreeze():
	visible = true
