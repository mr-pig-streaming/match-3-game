class_name Shop
extends Node2D

@export var active: bool

var x_offset = 160
var y_offset = 178
var y_tick = 64

# Items in the shop - Name, Cost... (more later)
var shop_items = [ShopItem.new(12, "Battery Pack", null),
				  ShopItem.new(20, "Big Battery Pack", null)
				  ]
var items_for_sale = []

var button_indexes = []

var item1: Button = Button.new()
var item2: Button = Button.new()
var item3: Button = Button.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add cards from the globals
	var shop_cards = get_tree().get_root().get_node("BaseScene").get_node("Globals").get_shop_cards(3)
	for card in shop_cards:
		var _card = Card.new_card(card[0], card[1], card[2])
		shop_items.append(ShopItem.new(card[2] * 5, "New Chip: " + card[0], _card))
	shop_items.shuffle()
	items_for_sale = shop_items.slice(0, 3)
	for i in range(3):
		var button = Button.new()
		button.text = str(items_for_sale[i].cost) + ": " + items_for_sale[i].item_name
		button.position = Vector2(x_offset, y_offset + y_tick * i)
		button.pressed.connect(buy_item.bind(items_for_sale[i], i))
		button.name = "ShopButton" + str(i)
		add_child(button)
	pass # Replace with function body.

func buy_item(item: ShopItem, index: int):
	get_node("/root/BaseScene/AudioManager").play_click()
	var cost = item.cost
	if (get_parent().spend_diamonds(cost) && active):
		get_parent().shop(item)
		get_node("ShopButton" + str(index)).disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_leave_button_pressed():
	get_node("/root/BaseScene/AudioManager").play_click()
	get_parent().level_select()
