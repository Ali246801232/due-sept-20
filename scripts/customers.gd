extends Node

var customers: Array = []

class Customer:
	var _name: String
	var _sprite: Texture
	var _effects: Dictionary
	var _allow_random: bool

	func _init(customer_name: String):
		_name = customer_name
		_sprite = Icons.customers[_name]
	
	func set_effects(effects):
		_effects = effects.duplicate()

	func set_allow_random(allow_random):
		_allow_random = allow_random
	
	func get_name():
		return _name
	
	func get_sprite():
		return _sprite

	func get_effects():
		return _effects
	
	func get_allow_random():
		return _allow_random

func new_customer(customer_name, properties):
	var default_properties := {
		"allow_random": true,
		"effects": {
			"time_multiplier": 1,
			"score_multiplier": 1,
			"recipe_screen": false
		}
	}

	var props = default_properties.duplicate(true)
	if properties and properties is Dictionary:
		for key in properties.keys():
			if key == "effects" and properties[key] is Dictionary:
				for effect in properties[key].keys():
					props["effects"][effect] = properties[key][effect]
			else:
				props[key] = properties[key]

	for customer in customers:
		assert(customer.get_name() != customer_name, "Customer %s already exists" % customer_name)
	var customer = Customer.new(customer_name)
	customer.set_effects(props["effects"])
	customer.set_allow_random(props["allow_random"])

	customers.append(customer)

func get_random_customer():
	if customers.is_empty():
		return null
	var allowed = []
	for customer in customers:
		if customer.get_allow_random():
			allowed.append(customer)
	return allowed[randi_range(0, allowed.size() - 1)]

func get_customer(customer_name):
	if customer_name == "_RANDOM_":
		return get_random_customer()
	for customer in customers:
		if customer.get_name() == customer_name:
			return customer
	return null
