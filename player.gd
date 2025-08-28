extends CharacterBody2D

@export var speed: float = 200.0

var nearby_interactables: Array = []
var move_actions := ["move_up", "move_down", "move_left", "move_right"]

func _ready():
	$Camera2D.make_current()

func _physics_process(_delta: float):
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		dir = dir.normalized()

	velocity = dir * speed
	move_and_slide()

	_update_animation_and_facing(dir)

	if Input.is_action_just_pressed("interact") and nearby_interactables.size() > 0:
		_try_interact()

# Called by Interactable nodes when the player enters their area
func add_interactable(interactable: Node):
	if interactable == null:
		return
	if not nearby_interactables.has(interactable):
		nearby_interactables.append(interactable)

# Called by Interactable nodes when the player exits their area
func remove_interactable(interactable: Node):
	if interactable == null:
		return
	if nearby_interactables.has(interactable):
		nearby_interactables.erase(interactable)

# Clean up dead references and try to interact with the nearest interactable
func _try_interact():
	nearby_interactables = nearby_interactables.filter(func(a):
		return a != null and a.is_inside_tree()
	)

	if nearby_interactables.size() == 0:
		return

	var target := _get_closest_interactable()
	if target and target.has_method("interact"):
		target.interact()

# Return nearest interactable in case player in multiple interaction areas
func _get_closest_interactable() -> Node:
	var closest: Node = null
	var closest_dist2 := INF
	for area in nearby_interactables:
		if area == null:
			continue
		if not area.is_inside_tree():
			continue
		var d2 := global_position.distance_squared_to(area.global_position)
		if d2 < closest_dist2:
			closest_dist2 = d2
			closest = area
	return closest

# Mirror sprite and switch animations upon movement
func _update_animation_and_facing(dir: Vector2) -> void:
	# Flip sprite
	if dir.x < 0:
		$Sprite.flip_h = true
	elif dir.x > 0:
		$Sprite.flip_h = false

	# Switch animations
	var any_move_pressed := move_actions.any(Input.is_action_pressed)
	if any_move_pressed:
		if $Sprite.animation != "walk" or not $Sprite.is_playing():
			$Sprite.play("walk")
	else:
		if $Sprite.animation != "idle":
			$Sprite.play("idle")
