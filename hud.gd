extends CanvasLayer

var inventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Inventory.connect("update_inventory", Callable(self, "redraw_inventory"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func redraw_inventory():
	inventory = Inventory.get_inventory()
	if Inventory.has_item():
		$Label.text = inventory["item"]
	else:
		$Label.text = "None"
	if Inventory.holding_bowl and not Inventory.is_bowl_empty():
		$Label2.text = inventory["bowl"][0]
		$Label3.text = inventory["bowl"][1]
		$Label4.text = inventory["bowl"][2]
		$Label5.text = inventory["bowl"][3]
	else:
		$Label2.text = ""
		$Label3.text = ""
		$Label4.text = ""
		$Label5.text = ""
