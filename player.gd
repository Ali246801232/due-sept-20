extends CharacterBody2D

@export var speed: float = 200.0

var last_facing_right: bool = true
var nearby_interactibles: Array[Node] = []

# Set up camera to follow player
func _ready():
	$Camera2D.make_current()
	$Camera2D.position_smoothing_enabled = true
	$Camera2D.position_smoothing_speed = 5.0
	$Camera2D.zoom = Vector2(1.25, 1.25)

# Handle movement with input
func _physics_process(_delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1

	if dir != Vector2.ZERO:
		dir = dir.normalized()

	velocity = dir * speed
	move_and_slide()

	_update_animation_and_facing(dir)

	if Input.is_action_just_pressed("interact") and nearby_interactibles.size() > 0:
		var closest = _get_closest_interactible()
		if closest:
			closest.interact()

# Mirror sprite and switch animations upon movement
func _update_animation_and_facing(dir: Vector2) -> void:
	if dir.x < 0:
		$Sprite.flip_h = true
		last_facing_right = false
	elif dir.x > 0:
		$Sprite.flip_h = false
		last_facing_right = true

	var any_move_pressed := Input.is_action_pressed("move_up") \
							or Input.is_action_pressed("move_down") \
							or Input.is_action_pressed("move_left") \
							or Input.is_action_pressed("move_right")
	if any_move_pressed:
		if $Sprite.animation != "walk" or not $Sprite.is_playing():
			$Sprite.play("walk")
	else:
		if $Sprite.animation != "idle":
			$Sprite.play("idle")

# Return the nearest interactible from the list of nearby ones
func _get_closest_interactible() -> Node:
	var closest: Node = null
	var closest_dist := INF
	for area in nearby_interactibles:
		if area and area.is_inside_tree():
			var dist = position.distance_to(area.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest = area
	return closest

# Add interactible to nearby list when entering its detection area
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		nearby_interactibles.append(area)

# Remove interactible from nearby list when leaving its detection area
func _on_area_exited(area: Area2D) -> void:
	if area in nearby_interactibles:
		nearby_interactibles.erase(area)
