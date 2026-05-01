# Building.gd
extends Node2D

@onready var label = $Label

@export var is_producer: bool
@export var max_stock: float = 100.0
@export var transfer_rate: float = 5.0 # 5 item per detik
@export var building_type: String

var internal_stock: float = 0.0
var current_ore: String = "default"

func _process(delta):
	label.text = str(floor(internal_stock)) + " / " + str(floor(max_stock))
	if is_producer:
		if internal_stock < max_stock:
			internal_stock = min(internal_stock + (0.5 * delta), 100)
	elif internal_stock > 0:
		var amount_to_reduce = 0.5 * delta
		amount_to_reduce = min(amount_to_reduce, internal_stock)
		internal_stock -= amount_to_reduce
		var money_earned = amount_to_reduce * Global.coal_price
		Global.money += money_earned

func _drop_item(req_drop: int, ore: String) -> int:
	# Cek validitas: gedung bukan produsen DAN (tipe ore cocok ATAU gedung terima apa saja)
	if not is_producer and (current_ore == ore or current_ore == null or current_ore == "default"):
		var space_left = max_stock - internal_stock
		var amount_to_fill = min(req_drop, space_left)
		
		internal_stock += amount_to_fill
		current_ore = ore
		
		return req_drop - amount_to_fill # Mengembalikan sisa yang masih ada di agent
	return req_drop

func _supply_item(req_supply: int, ore: String) -> int:
	# Cek validitas: gedung adalah produsen DAN (tipe ore cocok ATAU request default)
	if is_producer and (current_ore == ore or current_ore == null or ore == "default"):
		var amount_available = min(req_supply, internal_stock)
		internal_stock -= amount_available
		return amount_available
	return 0

func set_ore(ore: String):
	current_ore = ore
