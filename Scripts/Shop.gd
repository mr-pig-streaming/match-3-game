class_name Shop
extends Node2D

@export var active: bool

var x_offset = 160
var y_offset = 178
var y_tick = 64

# Items in the shop - Name, Cost... (more later)
var shop_items = [ShopItem.new(12, "Battery Pack", "Extra Energy"),
				  ShopItem.new(20, "Big Battery Pack", "Extra Energy"),
				  ShopItem.new(30, "Improve Horizontal Efficiency", "More efficient Horizontal matches"),
				  ShopItem.new(30, "Improve Vertical Efficiency", "More efficient Vertical Matches"),
				  ShopItem.new(40, "Improve Cross Efficiency", "More efficient matches when vertical and horizontal meet"),
				  ShopItem.new(30, "Improve Diagonal Efficiency \\", "More efficient diagonal matches with downward slope"),
				  ShopItem.new(30, "Improve Diagonal Efficiency /", "More efficient diagonal matches with upward slope"),
				  ShopItem.new(40, "Improve X Efficiency", "More efficient matches when upward and downward diagonal meet")
				  ]
var items_for_sale = []

var button_indexes = []

var item1: Button = Button.new()
var item2: Button = Button.new()
var item3: Button = Button.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add cards from the globals
	shop_items.shuffle()
	items_for_sale = shop_items.slice(0, 3)
	for i in range(3):
		var button = Button.new()
		button.text = str(items_for_sale[i].cost) + ": " + items_for_sale[i].item_name
		button.position = Vector2(x_offset, y_offset + y_tick * i)
		button.pressed.connect(buy_item.bind(items_for_sale[i], i))
		button.name = "ShopButton" + str(i)
		button.set_tooltip_text(items_for_sale[i].tooltip)
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
