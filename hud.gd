extends CanvasLayer

var inventory

func _ready() -> void:
	Inventory.connect("update_inventory", Callable(self, "redraw_inventory"))

func redraw_inventory():
	inventory = Inventory.get_inventory()

	# Handle single inventory item
	var item_node = $InventoryGUI/Item
	if Inventory.has_item():
		item_node.visible = true
		item_node.texture = Icons.items[inventory["item"]]
	else:
		item_node.visible = false

	# Switch between
	if Inventory.holding_bowl:
		$InventoryGUI.play("inventory_bowl")
	else:
		$InventoryGUI.play("inventory_no_bowl")

	# Handle bowl slots and extenders for multi-width ingredients
	for i in range(Inventory.bowl_size):
		var bowl_slot = get_node("InventoryGUI/Bowl" + str(i))
		var extender = get_node("InventoryGUI/Extender" + str(i))

		if not Inventory.holding_bowl or inventory["bowl"][i] == "":
			bowl_slot.visible = false
			if i > 0:
				extender.visible = false
		elif inventory["bowl"][i] == Inventory.continue_marker:
			bowl_slot.visible = false
			if i > 0:
				extender.visible = true
		else:
			bowl_slot.texture = Icons.ingredients[inventory["bowl"][i]]
			bowl_slot.visible = true
			if i > 0:
				extender.visible = false
