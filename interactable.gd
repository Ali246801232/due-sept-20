extends Area2D

@export var sprite_texture: Texture2D
@onready var timer: Timer = $WaitingTimer
var _current_state: int = 0
var _states: Array = []
var _running: bool = false
var _prev_timer: bool
signal wait_started(wait_time: float)
signal wait_ended()


func _ready():
	# Apply sprite
	$Sprite.texture = sprite_texture

	# Timer setup
	timer.one_shot = true
	timer.autostart = false

	# Connect Area2D signals
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

	# Look for child logic node to get states and optional sprite override
	for child in get_children():
		if child.has_method("get_states"):
			_states = child.get_states()
			if child.has_method("get_sprite_texture"):
				sprite_texture = child.get_sprite_texture()
				$Sprite.texture = sprite_texture
			break

	assert(_states.size() > 0, "Interactable must have at least one state defined")

func _on_body_entered(body: Node):
	if body.has_method("add_interactable"):
		body.add_interactable(self)

func _on_body_exited(body: Node):
	if body.has_method("remove_interactable"):
		body.remove_interactable(self)

func interact():
	# Check and remove progress bar from previous timer
	if _prev_timer:
		emit_signal("wait_ended")
		_prev_timer = false

	# Check if already running
	if _running:
		print("State running, cannot interact again")
		return

	# Start running and load state
	_running = true
	var state = _states[_current_state]

	# Pre-action
	if state.has("pre_action") and state.pre_action.is_valid():
		state.pre_action.call()
	
	# Waiting timer
	if state.has("wait_time") and state.wait_time > 0:
		emit_signal("wait_started", state.wait_time)
		_prev_timer = true
		timer.start(state.wait_time)
		await timer.timeout

	#
	if state.has("auto_end") and state.auto_end:
		_prev_timer = false
		emit_signal("wait_ended")

	# Post-action
	if state.has("post_action") and state.post_action.is_valid():
		state.post_action.call()

	# Move to next state
	assert(state.has("next_state"), "State must define next_state")
	_current_state = state.next_state
	_running = false
