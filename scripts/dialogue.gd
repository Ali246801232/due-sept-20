extends Node

var dialogue_sequences: Dictionary = {}

class DialogueSequence:
	signal conversation()
	signal choice()
	signal game_over(message)
	signal end()
	var _sequence: Dictionary
	var _start_node: String
	var _current_node: Dictionary
	var _callback: Callable
	
	func _init(sequence, start_node, callback) -> void:
		_sequence = sequence
		_start_node = start_node
		_callback = callback
	
	func get_current():
		return _current_node
	
	# TODO: if this only advances, then signals should be handled elsewhere
	func next_node():
		match _current_node["type"]:
			"conversation":
				emit_signal("conversation", _current_node["lines"])
				_current_node = _sequence[_current_node["next"]]
			"choice":
				emit_signal("choice", _current_node["choices"])
			"game_over":
				emit_signal("game_over", _current_node["message"])
			"end":
				emit_signal("end")
	
	func choose_option(option):
		for choice in _current_node["choices"]:
			pass
