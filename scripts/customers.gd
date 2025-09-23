extends Node

var customers: Array = []

class Customer:
	var _name: String
	var _sprite: Texture
	var _effects: Dictionary
	var _allow_random: bool
	var _manual_first: bool

	func _init(customer_name: String):
		_name = customer_name
		_sprite = Icons.customers[_name]
	
	func set_effects(effects):
		_effects = effects.duplicate()

	func set_allow_random(allow_random):
		_allow_random = allow_random
	
	func set_manual_first(manual_first):
		_manual_first = manual_first
	
	func get_name():
		return _name
	
	func get_sprite():
		return _sprite

	func get_effects():
		return _effects
	
	func get_allow_random():
		return _allow_random
	
	func get_manual_first():
		return _manual_first

func new_customer(customer_name, properties):
	var default_properties := {
		"effects": {
			"time_multiplier": 1,
			"score_multiplier": 1,
			"recipe_screen": false
		},
		"allow_random": true,
		"manual_first": false
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
	customer.set_manual_first(props["manual_first"])

	customers.append(customer)
	Reset.connect("resetted", Callable(self, "_on_resetted").bind(customer_name))

func get_random_customer(existing):
	if customers.is_empty():
		return null
	var allowed = []
	for customer in customers:
		if customer.get_allow_random() and customer.get_name() not in existing:
			allowed.append(customer)
	return allowed[randi_range(0, allowed.size() - 1)]

func get_customer(customer_name, existing):
	if customer_name == "_RANDOM_":
		return get_random_customer(existing)
	for customer in customers:
		if customer.get_name() == customer_name:
			if customer.get_manual_first():
				customer.set_allow_random(true)
			return customer
	return null

func _on_resetted(day, customer_name):
	if day == 1:
		pass
	if day == 2:
		if customer_name == "Kenz":
			get_customer(customer_name, []).set_allow_random(false)
	if day == 3:
		if customer_name == "Melan":
			get_customer(customer_name, []).set_allow_random(false)
		if customer_name == "Kraze":
			get_customer(customer_name, []).set_allow_random(false)
	if day == 4:
		pass
	if day == 5:
		if customer_name == "Chekered":
			get_customer(customer_name, []).set_allow_random(false)
		if customer_name == "Carton":
			get_customer(customer_name, []).set_allow_random(false)
