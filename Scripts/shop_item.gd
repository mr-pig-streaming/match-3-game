class_name ShopItem
extends Node2D

@export var cost: int
@export var item_name: String
@export var card: Card
# Likely other members

func _init(_cost: int, _name: String, _card: Card):
	cost = _cost
	item_name = _name
	card = _card

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
