extends Node

var slots: Array = []
var active: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get all customer slots
	for child in get_children():
		if child is CustomerSlot:
			slots.append(child)
			active.append(false)
	assert(slots.size() > 0, "There must be at least one CustomerSlot node")

	# Connect signals for customer slots
	for index in range(slots.size()):
		var slot = slots[index]
		slot.connect("order_taken", Callable(self, "_on_order_taken").bind(index))
		slot.connect("order_complete", Callable(self, "_on_order_complete").bind(index))
		slot.connect("timer_ended", Callable(self, "_on_timer_ended").bind(index))

func _on_order_taken(slot_index):
	active[slot_index] = true

func _on_order_complete(slot_index):
	active[slot_index] = false

func _on_timer_ended(slot_index):
	active[slot_index] = false
