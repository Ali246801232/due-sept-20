extends Area2D

@onready var waiting_timer: Timer = $WaitingTimer
@onready var interact_popup: Sprite2D = $InteractPopup
@onready var timer_display: TextureProgressBar = $WaitingTimer/TimerDisplay

var _logic_node: Node2D
var _anchors: Dictionary
var _states: Array = []
var _current_state: int = 0
var _next_state: int
var _running: bool = false
var _process_function: Callable

var distance_anchor

signal entered_interactable()
signal exited_interactable()
signal other_interacted()

func _ready():
	Freeze.connect("frozen", Callable(self, "freeze"))
	Freeze.connect("unfrozen", Callable(self, "unfreeze"))
	
	# Connect player interaction signal
	var player = get_tree().current_scene.get_node("Player")
	if player:
		player.connect("interacted", Callable(self, "_on_interaction"))
		player.connect("closest_interactable_changed", Callable(self, "_on_closest_interactable_changed"))

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
	if _logic_node.has_method("get_anchors"):
		_anchors = _logic_node.get_anchors()
	if _logic_node.has_method("get_process_function"):
		_process_function = _logic_node.get_process_function()
	assert(_states.size() > 0, "Interactable must have at least one state defined")
	if _anchors:
		interact_popup.global_position = _anchors.get("interact_popup", interact_popup.global_position)
		timer_display.global_position = _anchors.get("timer_display", timer_display.global_position)
		distance_anchor = _anchors.get("distance", global_position)
	else:
		distance_anchor = global_position

	# Connect signals for logic node
	_logic_node.connect("wait", Callable(self, "_wait"))
	_logic_node.connect("show_message", Callable(self, "_show_message"))
	_logic_node.connect("show_timer", Callable(self, "_show_timer"))
	_logic_node.connect("hide_timer", Callable(self, "_hide_timer"))
	if _logic_node.has_method("on_entered_interactable"):
		connect("entered_interactable", Callable(_logic_node, "on_entered_interactable"))
	if _logic_node.has_method("on_exited_interactable"):
		connect("exited_interactable", Callable(_logic_node, "on_exited_interactable"))
	if _logic_node.has_method("on_other_interacted"):
		connect("other_interacted", Callable(_logic_node, "on_other_interacted"))

func _process(_delta):
	if _process_function:
		_process_function.call()

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

# Display the message box with a message bubble
func _show_message(message: String, time: float):
	var message_box = get_tree().current_scene.get_node("GUI/HUD/MessageBox")
	message_box.show_message(message, time)

# Wait for some time before allowing interaction again
func _wait(time: float, post_callback):
	waiting_timer.wait(time, post_callback)

# Show the timer visualization
func _show_timer():
	waiting_timer.show_timer()

# Hide the timer visualization
func _hide_timer():
	waiting_timer.hide_timer()

# Some interaction happened
func _on_interaction(target):
	if Freeze.is_frozen:
		return
	if target == self:
		interact()
	else:
		emit_signal("other_interacted")

# The closest interactable changed
func _on_closest_interactable_changed(target):
	if target == self:
		interact_popup.visible = true
	else:
		interact_popup.visible = false

# Called when the user interacts with this interactable
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

func freeze():
	waiting_timer.paused = true

func unfreeze():
	waiting_timer.paused = false

func _on_resetted(day):
	if not waiting_timer.is_stopped():
		waiting_timer.stop()
