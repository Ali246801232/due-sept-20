extends CharacterBody2D

@export var speed: float = 250.0

signal interacted(interactable)
signal closest_interactable_changed(interactable)
var _nearby_interactables: Array = []
var _closest_interactable = null
var _move_actions := ["move_left", "move_right", "move_up", "move_down"]

func _ready():
	Freeze.connect("frozen", Callable(self, "freeze"))
	Freeze.connect("unfrozen", Callable(self, "unfreeze"))

	$Camera2D.make_current()

func _physics_process(_delta: float):
	var dir: Vector2 = Input.callv("get_vector", _move_actions)
	if dir != Vector2.ZERO:
		dir = dir.normalized()

	velocity = dir * speed
	move_and_slide()

	_update_animation_and_facing(dir)
	
	var _new_closest = _get_closest_interactable()
	if _closest_interactable != _new_closest:
		_closest_interactable = _new_closest
		emit_signal("closest_interactable_changed", _closest_interactable)

	if Input.is_action_just_pressed("interact") and _closest_interactable:
		emit_signal("interacted", _closest_interactable)

# Called by Interactable nodes when the player enters their area
func add_interactable(interactable: Node):
	if interactable == null:
		return
	if not _nearby_interactables.has(interactable):
		_nearby_interactables.append(interactable)

# Called by Interactable nodes when the player exits their area
func remove_interactable(interactable: Node):
	if interactable == null:
		return
	if _nearby_interactables.has(interactable):
		_nearby_interactables.erase(interactable)

# Try to interact with the closest interactable if it exists
func _try_interact():
	# Remove dead references
	_nearby_interactables = _nearby_interactables.filter(func(interactable):
		return interactable != null and interactable.is_inside_tree()
	)

	# No nearby interactables
	if _nearby_interactables.size() == 0:
		return

	# Interact with closest interactable
	var target := _get_closest_interactable()
	if target:
		emit_signal("interacted", target)

# Return closest interactable to player
func _get_closest_interactable() -> Node:
	var closest: Node = null
	var closest_dist2 := INF
	for interactable in _nearby_interactables:
		if interactable == null:
			continue
		if not interactable.is_inside_tree():
			continue
		var anchor = interactable.distance_anchor
		var d2 := global_position.distance_squared_to(anchor)
		if d2 < closest_dist2:
			closest_dist2 = d2
			closest = interactable
	return closest

# Mirror sprite and switch animations upon movement
func _update_animation_and_facing(dir: Vector2) -> void:
	# Flip sprite
	if dir.x < 0:
		$Sprite.flip_h = true
	elif dir.x > 0:
		$Sprite.flip_h = false

	# Switch animations
	var any_move_pressed := _move_actions.any(Input.is_action_pressed)
	if any_move_pressed:
		if $Sprite.animation != "walk" or not $Sprite.is_playing():
			$Sprite.play("walk")
	else:
		if $Sprite.animation != "idle":
			$Sprite.play("idle")
