extends Node2D


var _slots: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get all customer slots
	for child in get_children():
		if child.is_class("CustomerSlot"):
			_slots.append(child)
	assert(_slots.size() > 0, "There must be at least one CustomerSlot node")

	# Connect signals for customer slots
	for index in range(_slots.size()):
		var slot = _slots[index]
		slot.connect("order_taken", Callable(self, "_on_order_taken").bind(index))
		slot.connect("order_complete", Callable(self, "_on_order_complete").bind(index))

func _on_order_taken(slot_index):
	pass
