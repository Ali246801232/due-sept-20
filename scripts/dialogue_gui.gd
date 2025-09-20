# TODO:
# - how the fuck do i do autoskip
# - 

extends CanvasLayer

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueText
@onready var player_sprite = $PlayerSprite
@onready var npc_sprite = $NPCSprite
@onready var player_name = $PlayerName
@onready var npc_name = $NPCName
@onready var choices = $Choices
@onready var next_button = $NextDialogue

var typewriter_tween: Tween
var dialogue_speed = 25

var current_node

signal next_line()
var line_index = 0
var current_line

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogue.connect("node_started", Callable(self, "_on_node_started"))
	Dialogue.connect("dialogue_started", Callable(self, "_on_dialogue_started"))
	connect("next_line", Callable(self, "play_line"))

	next_button.connect("pressed", Callable(self, "skip_dialogue"))

	player_name.text = "Anje"
	player_sprite.texture = load("res://assets/player/player_idle.png")
	player_sprite.visible = false
	npc_sprite.visible = false
	player_name.visible = false
	npc_name.visible = false
	visible = false

func _on_dialogue_started():
	visible = true

func _on_node_started(node: Dictionary):
	current_node = node
	match node["type"]:
		"start":
			Dialogue.start()
		"conversation":
			play_line()
		"choice":
			pass
		"end":
			var callback = node.get("callback", null)
			if callback:
				callback.call()
			Dialogue.end()
			dialogue_ended()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_dialogue") and not event.is_echo():
		skip_dialogue()

func dialogue_ended():
	player_sprite.visible = false
	npc_sprite.visible = false
	player_name.visible = false
	npc_name.visible = false
	visible = false

# TODO: why the fuck are the labels not visible
func set_speaker(speaker: String):
	var is_player = (speaker == "Anje")
	dialogue_box.play("player" if is_player else "npc")
	player_name.visible = is_player
	player_sprite.visible = is_player
	npc_name.visible = not is_player
	npc_sprite.visible = not is_player
	if not is_player:
		npc_name.text = speaker
		npc_sprite.texture = Icons.customers[speaker]

func play_line():
	current_line = current_node["lines"][line_index]
	
	set_speaker(current_line["speaker"])
	dialogue_text.text = current_line["text"]

	dialogue_text.visible_ratio = 0.0
	if typewriter_tween and typewriter_tween.is_running():
		typewriter_tween.kill()
	typewriter_tween = create_tween()
	typewriter_tween.tween_property(
		dialogue_text,
		"visible_ratio",
		1.0,
		dialogue_text.text.length() / dialogue_speed
	)

	if current_line.get("autoskip", false):
		await typewriter_tween.finished
		skip_dialogue()

func show_choice():
	pass

func skip_dialogue():
	if not visible or current_node["type"] != "conversation":
		return

	if typewriter_tween.is_running():
		if current_line.get("autoskip", false) or not current_line.get("skippable", true):
			return
		typewriter_tween.kill()
		dialogue_text.visible_ratio = 1.0
		return

	line_index += 1
	if line_index >= current_node["lines"].size():
		Dialogue.conversation_finished()
		return
	emit_signal("next_line")
