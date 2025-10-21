class_name UpgradeItem
extends Node2D

var upgrade_name: String
var upgrade_cost: int
var upgrade_purchased: bool
var upgrade_available: bool

static func new_upgrade(values):
	var item = UpgradeItem.new()
	item.upgrade_name = values[0]
	item.upgrade_cost = values[1]
	item.upgrade_purchased = values[2]
	item.upgrade_available = values[3]
	return item

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
