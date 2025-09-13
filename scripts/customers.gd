# TODO: SEPARATE CUSTOMER FROM ORDER

extends Node

var customers: Array = []

var valid_orders = [
	{"name": "Plain Cookies", "tags": ["Cookies"]},
	{"name": "Sugar Cookies", "tags": ["Cookies"]},
	{"name": "Chocolate Chip Cookies", "tags": ["Cookies"]},
	{"name": "Butter Cookies", "tags": ["Cookies"]},
	{"name": "Cheese Cookies", "tags": ["Cookies"]},
	{"name": "Mixed Nut Cookies", "tags": ["Cookies"]},
	{"name": "Chocolate Crinkles", "tags": ["Crinkles"]},
	{"name": "Ube Crinkles", "tags": ["Crinkles"]},
	{"name": "Plain Bread", "tags": ["Bread"]},
	{"name": "Banana Bread", "tags": ["Bread"]},
	{"name": "Egg Bread", "tags": ["Bread"]},
	{"name": "Coco Bread", "tags": ["Bread"]},
	{"name": "Cheese Pandesal", "tags": ["Pandesal"]},
	{"name": "Ube Pandesal", "tags": ["Pandesal"]},
]

var filters = ["_RANDOM_COOKIES_", "_RANDOM_BREAD_", "_RANDOM_NORMAL_"]

class Customer:
	var _name: String
	var _sprite: Texture
	var _orders: Array
	var _special_order: String
	var _effects: Dictionary
	var _filters: Array
	var _allow_random: bool

	func _init(customer_name: String):
		_name = customer_name
		_sprite = Icons.customers[_name]
	
	func set_orders(orders):
		_orders = orders.duplicate()
	
	func set_orders_from_tags(include: Array, exclude: Array, valid_orders: Array):
		_orders = []
		for order in valid_orders:
			var order_tags = order.get("tags", [])
			var include_ok = include.is_empty() or include.any(func(tag): return order_tags.has(tag))
			var exclude_ok = exclude.is_empty() or not exclude.any(func(tag): return order_tags.has(tag))
			if include_ok and exclude_ok:
				_orders.append(order["name"])
	
	func set_special_order(order):
		_special_order = order
	
	func set_filters(valid_orders):
		for order in valid_orders:
			if not order["name"] in _orders:
				continue
			if "Cookies" in order["tags"] or "Crinkles" in order["tags"]:
				if "_RANDOM_COOKIES_" not in _filters:
					_filters.append("_RANDOM_COOKIES_")
			if "Bread" in order["tags"] or "Pandesaal" in order["tags"]:
				if "_RANDOM_BREAD_" not in _filters:
					_filters.append("_RANDOM_BREAD_")
			if "_RANDOM_COOKIES_" in _filters and "_RANDOM_BREAD_" in _filters:
				_filters.append("_RANDOM_NORMAL_")

	func set_effects(effects):
		_effects = effects.duplicate()

	func set_allow_random(allow_random):
		_allow_random = allow_random

	func match_filter(filter):
		if filter in _filters:
			return true
		return  false

	func get_random_order():
		return _orders[randi() % _orders.size()]

	func get_effects():
		return _effects
	
	func get_name():
		return _name
	
	func get_sprite():
		return _sprite
	
	func get_allow_random():
		return _allow_random

func new_customer(customer_name, properties):
	var default_properties := {
		"orders": [],
		"special_order": "",
		"include": [],
		"exclude": [],
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
		if customer.get_name() == customer_name:
			return
	var new_customer = Customer.new(customer_name)

	if not props["orders"].is_empty():
		new_customer.set_orders(props["orders"])
	elif not props["include"].is_empty() or not props["exclude"].is_empty():
		new_customer.set_orders_from_tags(props["include"], props["exclude"], valid_orders)
	else:
		new_customer.set_orders_from_tags(["Cookies", "Crinkles", "Bread", "Pandesal"], [], valid_orders)
	new_customer.set_filters(valid_orders)
	new_customer.set_special_order(props["special_order"])
	new_customer.set_effects(props["effects"])
	new_customer.set_allow_random(props["allow_random"])

	customers.append(new_customer)

func get_random_customer(filter):
	if customers.is_empty():
		return null
	var filtered = []
	for customer in customers:
		if customer.match_filter(filter) and not customer.get_allow_random():
			filtered.append(customer)
	return filtered[randi_range(0, filtered.size() - 1)]

func get_customer(customer_name):
	if customer_name in filters:
		return get_random_customer(customer_name)
	for customer in customers:
		if customer.get_name() == customer_name:
			return customer
	return null
