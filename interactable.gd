extends Area2D

@onready var waiting_timer: Timer = $WaitingTimer
@onready var message_bubble: Sprite2D = $MessageBubble

var _logic_node: Node2D
var _states: Array = []
var _current_state: int = 0
var _next_state: int
var _running: bool = false

signal entered_interactable()
signal exited_interactable()
signal other_interacted()

func _ready():
	# Connect player interaction key
	var player = get_parent().get_node("Player")
	if player:
		player.connect("interacted", Callable(self, "_on_interaction"))

	# Connect Area2D signals
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))
	if not is_connected("body_exited", Callable(self, "_on_body_exited")):
		connect("body_exited", Callable(self, "_on_body_exited"))

	# Get states and sprite from logic node
	assert(has_node("Logic"), "Interactable must have a logic node")
	_logic_node = get_node("Logic")
	if _logic_node.has_method("get_states"):
		_states = _logic_node.get_states()
	if _logic_node.has_method("get_sprite_texture"):
		$Sprite.texture = _logic_node.get_sprite_texture()
	assert(_states.size() > 0, "Interactable must have at least one state defined")

	# Connect signals for logic node
	_logic_node.connect("wait", Callable(self, "_wait"))
	_logic_node.connect("show_message", Callable(self, "_show_message"))
	_logic_node.connect("show_timer", Callable(self, "_show_timer"))
	_logic_node.connect("hide_timer", Callable(self, "_hide_timer"))
	_logic_node.connect("show_popup", Callable(self, "_show_popup"))
	_logic_node.connect("hide_popup", Callable(self, "_hide_poup"))
	if _logic_node.has_method("on_entered_interactable"):
		connect("entered_interactable", Callable(_logic_node, "on_entered_interactable"))
	if _logic_node.has_method("on_exited_interactable"):
		connect("exited_interactable", Callable(_logic_node, "on_exited_interactable"))
	if _logic_node.has_method("on_other_interacted"):
		connect("other_interacted", Callable(_logic_node, "on_other_interacted"))

# Add a nearby interactable upon entering its area
func _on_body_entered(body: Node):
	if body.has_method("add_interactable"):
		body.add_interactable(self)
	emit_signal("entered_interactable")

# Remove a nearby interactable upon leaving its area
func _on_body_exited(body: Node):
	if body.has_method("remove_interactable"):
		body.remove_interactable(self)
	emit_signal("exited_interactable")

# Display a message bubble
func _show_message(message: String, time: float):
	message_bubble.show_message(message, time)

# Wait for some time before allowing interaction again
func _wait(time: float, post_callback):
	waiting_timer.wait(time, post_callback)

# Show the timer visualization
func _show_timer():
	waiting_timer.show_timer()

# Hide the timer visualization
func _hide_timer():
	waiting_timer.hide_timer()

func _on_interaction(target):
	if target == self:
		interact()
	else:
		emit_signal("other_interacted")

# Called when the user interacts with the interactable
func interact():
	if _running:
		return
	
	_running = true
	var state = _states[_current_state]
	_next_state = state.call()

	if not waiting_timer.is_stopped():
		await waiting_timer.timeout
	
	_current_state = _next_state
	_running = false
