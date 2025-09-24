extends CanvasLayer

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueText
@onready var player_sprite = $PlayerSprite
@onready var npc_sprite = $NPCSprite
@onready var player_name = $PlayerName
@onready var npc_name = $NPCName
@onready var choices = $Choices
@onready var next_button = $NextDialogue
@onready var audio_player = $AudioPlayer

var typewriter_tween: Tween
var dialogue_speed = 25
var choice_buttons = []
var current_node

signal next_line()
var line_index = 0
var current_line

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Reset.connect("resetted", Callable(self, "_on_resetted"))

	Dialogue.connect("node_started", Callable(self, "_on_node_started"))
	Dialogue.connect("dialogue_started", Callable(self, "_on_dialogue_started"))
	connect("next_line", Callable(self, "play_line"))

	next_button.modulate.a = 0.0
	next_button.connect("pressed", Callable(self, "skip_dialogue"))
	audio_player.volume_db = -15.0

	player_sprite.visible = false
	npc_sprite.visible = false
	player_name.visible = false
	npc_name.visible = false
	visible = false

var last_chars_visible = 0

func _process(delta):
	if not current_node:
		return
	if not current_node["type"] == "conversation":
		return
	if current_line.get("audio", null):
		return
	if dialogue_text.visible_ratio > 0 and (current_node["lines"][line_index]["speaker"] != "Anje" or current_node["lines"][line_index]["speaker"] != "Mordekaiser"):
		var chars_visible = int(dialogue_text.visible_ratio * dialogue_text.text.length())
		if chars_visible > last_chars_visible:
			if current_node["lines"][line_index]["speaker"] == "Anje":
				audio_player.stream = load("res://assets/audio/asriel_blip.wav")
			if current_node["lines"][line_index]["speaker"] == "Mordekaiser":
				audio_player.stream = load("res://assets/audio/asgore_blip.wav")
			if dialogue_text.text[chars_visible - 1] != " ":
				audio_player.play()
			last_chars_visible = chars_visible
	else:
		last_chars_visible = 0

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
			show_choice()
		"game_over":
			Dialogue.game_over(current_node["message"])
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

func set_speaker(speaker: String):
	var is_player = (speaker == "Anje")
	dialogue_box.play("player" if is_player else "npc")
	player_name.visible = is_player
	player_sprite.visible = is_player
	npc_name.visible = not is_player
	npc_sprite.visible = not is_player
	if is_player:
		player_name.text = "Anje"
		player_sprite.texture = load("res://assets/dialogue_icons/dialogue_anje.png")
	else:
		npc_name.text = speaker
		npc_sprite.texture = Icons.dialogue_icons.get(speaker, null)
		print(speaker)

func play_line():
	current_line = current_node["lines"][line_index]
	
	set_speaker(current_line["speaker"])
	
	var sprite_override = current_line.get("sprite_override", null)
	if sprite_override:
		player_sprite.texture = load(sprite_override)
		npc_sprite.texture = load(sprite_override)
	
	dialogue_text.text = current_line["text"]

	dialogue_text.visible_ratio = 0.0
	if typewriter_tween and typewriter_tween.is_running():
		typewriter_tween.kill()
	typewriter_tween = create_tween()
	typewriter_tween.tween_property(
		dialogue_text,
		"visible_ratio",
		1.0,
		float(dialogue_text.text.length()) / dialogue_speed
	)

	if current_line["speaker"] == "Ali":
		audio_player.volume_db = -25.0
	else:
		audio_player.volume_db = -15.0

	audio_player.stop()
	audio_player.stream = null
	var audio_path = current_line.get("audio", "")
	if audio_path:
		var stream
		var base_path = "res://assets/audio/voicelines/" + audio_path
		var wav_stream = load(base_path + ".wav")
		if wav_stream:
			stream = wav_stream
		else:
			var mp3_stream = load(base_path + ".mp3")
			if mp3_stream:
				stream = mp3_stream
		audio_player.stream = stream
		if audio_player.stream:
			await get_tree().create_timer(0.2).timeout
			audio_player.play()

	if current_line.get("autoskip", false):
		await typewriter_tween.finished
		skip_dialogue()

func show_choice():
	var choices_list: Dictionary = current_node["choices"]
	for choice_text in choices_list.keys():
		var choice_button = Button.new()
		choice_button.text = choice_text
		choice_button.connect("pressed", Callable(self, "_on_choice_selected").bind(choice_text))
		choice_button.add_theme_font_size_override("font_size", 37)
		choice_buttons.append(choice_button)
		choices.add_child(choice_button)

func _on_choice_selected(choice_text):
	var choices_list = current_node["choices"]
	Dialogue.choice_selected(choices_list[choice_text])
	for choice_button in choice_buttons:
		choice_button.queue_free()
	choice_buttons = []


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
		line_index = 0
		Dialogue.conversation_finished()
		return
	emit_signal("next_line")

func _on_resetted(day):
	typewriter_tween.kill()
	audio_player.stop()
	audio_player.volume_db = -15.0
	player_sprite.visible = false
	npc_sprite.visible = false
	player_name.visible = false
	npc_name.visible = false
	visible = false
	choice_buttons = []
	line_index = 0
	current_line = null
	current_node = null
