extends Node

class DialogueSequence:
	var nodes: Dictionary
	var current_node: Dictionary

	func _init(data: Dictionary) -> void:
		nodes = data
		current_node = nodes.get("start", {})

	func goto_next(next_name: String) -> void:
		if nodes.has(next_name):
			current_node = nodes[next_name]
		else:
			push_error("DialogueSequence: Missing node '%s'" % next_name)
			current_node = {}



var dialogue_sequences: Dictionary = {}
var current_sequence: DialogueSequence

func load_sequences(json_path: String = "res://assets/dialogue_sequences.json") -> void:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if not file:
		push_error("Failed to open dialogue file: %s" % json_path)
		return

	var data: Dictionary = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Dialogue file malformed: %s" % json_path)
		return

	for sequence_name in data.keys():
		dialogue_sequences[sequence_name] = DialogueSequence.new(data[sequence_name])



signal dialogue_started()
signal node_started(node: Dictionary)

func get_sequence(sequence_name: String) -> DialogueSequence:
	return dialogue_sequences.get(sequence_name, null)

func run_sequence(sequence_name: String) -> void:
	Freeze.is_frozen = true
	if not dialogue_sequences.has(sequence_name):
		push_error("Sequence '%s' not found" % sequence_name)
		return
	current_sequence = dialogue_sequences[sequence_name]
	emit_signal("dialogue_started")
	_process_node()

func _process_node() -> void:
	emit_signal("node_started", current_sequence.current_node)


func start() -> void:
	current_sequence.goto_next(current_sequence.current_node["next"])
	_process_node()

func conversation_finished() -> void:
	current_sequence.goto_next(current_sequence.current_node["next"])
	_process_node()

func choice_selected(outcome: String) -> void:
	current_sequence.goto_next(outcome)
	_process_node()

func game_over(message: String) -> void:
	current_sequence.goto_next("end")
	_process_node()

func end() -> void:
	current_sequence = null
	Freeze.is_frozen = false
