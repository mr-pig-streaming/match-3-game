class_name ShopItem
extends Node2D

@export var cost: int
@export var item_name: String
@export var tooltip: String
# Likely other members

func _init(_cost: int, _name: String, _tooltip: String):
	cost = _cost
	item_name = _name
	tooltip = _tooltip

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
