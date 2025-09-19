extends CanvasLayer

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueText
@onready var player_sprite = $PlayerSprite
@onready var npc_sprite = $NPCSprite
@onready var player_name = $PlayerName
@onready var npc_name = $NPCName

var typewriter_tween: Tween
var dialogue_speed = 10
var dialogue_sequence

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	player_name.text = "Anje"
	player_sprite.texture = load("res://assets/player/player_idle.png")
	player_sprite.visible = false
	npc_sprite.visible = false
	player_name.visible = false
	npc_name.visible = false

func set_dialogue_sequence(sequence):
	dialogue_sequence = sequence

func set_speaker(speaker: String):
	var is_player = (dialogue_sequence.get_current_node()["speaker_side"] == "player")
	dialogue_box.play("player" if is_player else "npc")
	player_name.visible = is_player
	player_sprite.visible = is_player
	npc_name.visible = not is_player
	npc_sprite.visible = not is_player
	if not is_player:
		npc_name.text = speaker
		npc_sprite.texture = Icons.customers[speaker]


func play_node():
	#visible = true
	#set_player() or set_npc()
	var current_node = dialogue_sequence.get_current_node()
	dialogue_text.text = current_node.dialogue_text

	dialogue_text.visible_ratio = 0.0
	if typewriter_tween.is_running():
		typewriter_tween.kill()
	typewriter_tween = create_tween()
	typewriter_tween.tween_property(
		dialogue_text,
		"visible_ratio",
		1.0,
		dialogue_text.text.length() / dialogue_speed
	)

	#if current_dialogue["autoskip"]:
		#await typewriter_tween.finished
		#skip_dialogue()

func skip_dialogue():
	#if unskippable or autoskip, then return
	if typewriter_tween.is_running():
		typewriter_tween.kill()
		dialogue_text.visible_ratio = 1.0
		return
	#current_dialogue = dialogue_sequence.next_dialogue()
	#if current_dialogue["type"] == "end":
		#visible = false
		#Freeze.is_frozen = false
		#return
	dialogue_sequence.next_node()
	play_node()
