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
	{"name": "Milk", "tags": ["Milk"]}
]

class Customer:
	var _name: String
	var _sprite: Texture
	var _orders: Array
	var _tags: Array

	func _init(customer_name: String):
		_name = customer_name
		_sprite = Icons.customers[_name]
	
	func set_orders(orders):
		_orders = orders
	
	func set_orders_from_tags(include: Array, exclude: Array, order_list: Array):
		pass

func _ready():
	customers.append(Customer.new("Skibidi"))
	customers.append(Customer.new("Weezer"))
	customers.append(Customer.new("Balls"))

func add_customer(customer_name, orders=[], include=[], exclude=[]):
	pass

func get_random_customer():
	return customers[randi() % customers.size()]

func get_customer(customer_name: int):
	for customer in customers:
		if customer.customer_name == customer_name:
			return customer
	return null
