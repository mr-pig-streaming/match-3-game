class_name SideBoard
extends Node2D

signal card_activated

var active: bool = true
# The number of cards we currently have on hand
var num_cards = 0
# The cards we currently have on hand
var cards = []
# The card slots - including which card is contained if any
var card_slots = []
# The card currently being held
var held_card = null
# If the mouse is in the chip area
var in_chip_area = false

var x_offset = 720
var y_offset = 80
var y_tick = 140
var x_tick = 140

var y_offset_hand = 180
var x_offset_hand = 880

# Called when the node enters the scene tree for the first time.
func _ready():
	cards = []
	for i in range(9):
		cards.append(null)
	setup_card_slots()
	print("Unlocked: " + str(get_parent().get_parent().get_node("Globals").sideboard_unlocked))
	var helper = preload("res://Scenes/clippy_helper.tscn").instantiate()
	helper.scale *= 0.75
	add_child(helper)
	move_child(helper, -1)
	helper.name = "Helper"
	helper.position = Vector2(848, 676)
	if (get_parent().get_parent().get_node("Globals").sideboard_unlocked):
		active = true
		get_node("PanelSprite").visible = false
	else:
		active = false
		get_node("PanelSprite").visible = true
		move_child(get_node("PanelSprite"), -1)

func setup_card_slots():
	card_slots = []
	for i in range(5):
		card_slots.append("LOCKED")
	var num_slots = get_parent().get_parent().get_node("Globals").num_card_slots
	for i in range(num_slots):
		card_slots[i] = "EMPTY"
	# Add the sprites for the open and locked slots
	for i in range(5):
		var sprite = Sprite2D.new()
		sprite.position = Vector2(x_offset, y_offset + i * y_tick)
		if (card_slots[i] == "EMPTY"):
			sprite.texture = load("res://Art/OpenSlot.png")
		else:
			sprite.texture = load("res://Art/LockedSlot.png")
		add_child(sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_input_event(viewport, event, shape_idx):
	pass

func drop_card():
	if (!active):
		return
	print("Card Released")
	if (held_card != null):
		if (in_chip_area):
			if (!activate_card(held_card)):
				held_card.return_to_original()
		else:
			held_card.return_to_original()

func activate_card(card: Card):
	var cost = card.cost
	if (get_parent().spend_diamonds(cost)):
		for i in range(0, card_slots.size()):
			if (card_slots[i] is String && card_slots[i] == "EMPTY"):
				get_node("/root/BaseScene/AudioManager").play_powerup()
				card_slots[i] = card
				card.position = Vector2(x_offset, y_offset + (y_tick * i))
				card.card_active = true
				card_activated.emit(card)
				var index = cards.find(card)
				cards[index] = null
				return true
	return false

func activate_debuff(debuff: Card):
	print("Trying to activate " + debuff.card_name)
	for i in range(0, card_slots.size()):
		print("Index " + str(i) + ": " + str(card_slots[i]))
		if (card_slots[i] is String || card_slots[i].type != "DEBUFF"):
			get_node("/root/BaseScene/AudioManager").play_powerup()
			add_child(debuff)
			card_slots[i] = debuff
			debuff.position = Vector2(x_offset, y_offset + (y_tick * i))
			debuff.card_active = true
			card_activated.emit(debuff)
			return

func set_held_card(card):
	if (!active):
		return
	held_card = card


func _on_chip_area_mouse_entered():
	in_chip_area = true


func _on_chip_area_mouse_exited():
	in_chip_area = false

func reduce_card_durability():
	# If there is a timestop card, only that one gets reduced, else they all get reduced
	if (get_active_card_effects().has("Time Stop")):
		for i in range(0, card_slots.size()):
			if (card_slots[i] is Card && card_slots[i].card_name == "Time Stop"):
				card_slots[i].durability -= 1
	else:
		for i in range(0, card_slots.size()):
			if (card_slots[i] is Card):
				card_slots[i].durability -= 1
	deactivate_cards()

func deactivate_cards():
	for i in range(0, card_slots.size()):
		if (card_slots[i] is Card && card_slots[i].durability <= 0):
			get_node("/root/BaseScene/AudioManager").play_powerdown()
			get_parent().remove_card_effect(card_slots[i].card_name)
			card_slots[i].visible = false
			card_slots[i].queue_free()
			card_slots[i] = "EMPTY"

func get_active_card_effects():
	var active_cards = []
	for i in range(0, card_slots.size()):
		if (card_slots[i] is Card):
			active_cards.append(card_slots[i].card_name)
	return active_cards


func _on_dispenser_button_pressed():
	if (!active):
		return
	if (num_cards >= 9):
		return
	get_node("/root/BaseScene/AudioManager").play_click()
	var card = get_parent().random_card()
	if (card != null):
		for i in range(9):
			if (cards[i] == null):
				var row: int = i / 3
				var col: int = i % 3
				var x = x_offset_hand + col * x_tick
				var y = y_offset_hand + row * y_tick
				card.position = Vector2(x, y)
				add_child(card)
				cards[i] = card
				break
	else:
		print("Not enough diamonds")

func remove_all_debuffs():
	var num_slots = get_parent().get_parent().get_node("Globals").num_card_slots
	for i in range(0, card_slots.size()):
		if (card_slots[i] is Card && card_slots[i].type == "DEBUFF"):
			card_slots[i].durability = 0
	deactivate_cards()
	# Lock any slots that were locked before
	for i in range(0, card_slots.size()):
		if (i >= num_slots && card_slots[i] is String):
			card_slots[i] = "LOCKED"

func sideboard_to_json():
	var json_string = ""
	json_string += JSON.stringify(cards) + "\n"
	json_string += JSON.stringify(card_slots) + "\n"
	return json_string

# Receives an array of 2 JSON strings as follows:
# [0]: The chips in hand
# [1]: The active cards and the card zone
func json_to_sideboard(json_array):
	cards = []
	for i in range(9):
		cards.append(null)
	setup_card_slots()
	active = true
	var json = JSON.new()
	# Load the hand
	json.parse(json_array[0])
	var hand_array = json.data
	for i in hand_array.size():
		var card = null
		if (hand_array[i] != null):
			# Make a card with this info
			card = Card.card_from_string(hand_array[i])
			add_child(card)
		cards[i] = card
	# Load the active cards
	json = JSON.new()
	json.parse(json_array[1])
	var active_array = json.data
	for i in active_array.size():
		var slot = active_array[i]
		if (slot != "EMPTY" && slot != "LOCKED"):
			slot = Card.card_from_string(slot)
			add_child(slot)
		card_slots[i] = slot
	print("Unlocked: " + str(get_parent().get_parent().get_node("Globals").sideboard_unlocked))
	if (get_parent().get_parent().get_node("Globals").sideboard_unlocked):
		active = true
		get_node("PanelSprite").visible = false
	else:
		active = false
		get_node("PanelSprite").visible = true
		move_child(get_node("PanelSprite"), -1)


func _on_view_button_pressed():
	if (!active):
		return
	print("Viewing chips...")
	active = false
	var dispenser = preload("res://Scenes/dispenser.tscn").instantiate()
	dispenser.name = "Dispenser"
	dispenser.z_index = 10
	dispenser.position = Vector2(640, 360)
	add_child(dispenser)
	get_parent().active = false
	get_parent().active_scene.active = false
	var deck = get_parent().deck
	for card in deck:
		print(dispenser.get_node("ChipsLabel"))
		dispenser.get_node("ChipsLabel").append_text(card.card_name)
	dispenser.get_node("CloseButton").pressed.connect(close_dispenser)

func close_dispenser():
	get_node("Dispenser").queue_free()
	active = true
	get_parent().active = true
	get_parent().active_scene.active = true
