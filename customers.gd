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
	{"name": "Ube Pandesal", "tags": ["Pandesal"]}
]

class Customer:
	var _name: String
	var _sprite: Texture
	var _orders: Array
	var _effects: Dictionary

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

	func get_random_order():
		return _orders[randi() % _orders.size()]

	func set_effects(time_multiplier, score_multiplier):
		_effects = {
			"time_multiplier": time_multiplier,
			"score_multiplier": score_multiplier
		}

	func get_effects():
		return _effects
	
	func get_name():
		return _name

func add_customer(customer_name, orders=[], include=[], exclude=[]):
	var new_customer = Customer.new(customer_name)
	for customer in customers:
		if customer.get_name() == customer_name:
			return
	if not orders.is_empty():
		new_customer.set_orders(orders)
	else:
		new_customer.set_orders_from_tags(include, exclude, valid_orders)
	customers.append(new_customer)

func get_random_customer():
	if customers.is_empty():
		return null
	return customers[randi() % customers.size()]

func get_customer(customer_name):
	for customer in customers:
		if customer.get_name() == customer_name:
			return customer
	return null


func freeze():
	pass

func resume():
	pass
