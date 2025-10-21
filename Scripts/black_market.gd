class_name BlackMarket
extends Node2D

@export var num_diamonds: int = 0
var active = true
var upgrade_buttons = []

# Called when the node enters the scene tree for the first time.
func _ready():
	create_buttons()
	get_parent().save_state = "BLACK_MARKET\n" + black_market_to_json()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_num_diamonds(diamonds: int):
	num_diamonds = diamonds
	get_node("DiamondsLabel").text = "Shards: " + str(diamonds)

func _input(event):
	if (!active):
		return
	if Input.is_key_pressed(KEY_ESCAPE):
		print("Popup Menu")
		active = false
		var popup = preload("res://Scenes/popup_menu.tscn").instantiate()
		popup.name = "PopupMenu"
		popup.z_index = 10
		popup.position = Vector2(640, 360)
		add_child(popup)
		popup.get_node("ResumeButton").pressed.connect(closePopupMenu)
		popup.get_node("SaveExitButton").pressed.connect(saveExitGame)
		popup.get_node("ExitButton").pressed.connect(exitGame)

func closePopupMenu():
	print("Resume")
	get_node("PopupMenu").queue_free()
	active = true

func saveExitGame():
	print("Save and exit...")
	var saved_state = "BLACK_MARKET\n" + black_market_to_json()
	get_parent().save_state = saved_state
	get_parent().save_game()
	get_tree().quit()

func exitGame():
	print("Exit without saving...")
	get_tree().quit()

func black_market_to_json():
	var json_string = str(num_diamonds)
	return json_string

func recreate_buttons():
	for button in upgrade_buttons:
		button.queue_free()
	upgrade_buttons = []
	create_buttons()
	get_parent().save_state = "BLACK_MARKET\n" + black_market_to_json()

func create_buttons():
	# Create the unlock button
	var unlock_button = Button.new()
	unlock_button.text = "1: Unlock Maintenance Panel"
	unlock_button.position = Vector2(50, 360)
	add_child(unlock_button)
	unlock_button.pressed.connect(unlock_side_panel)
	print(get_parent().get_node("Globals").sideboard_unlocked)
	if (get_parent().get_node("Globals").sideboard_unlocked == true):
		unlock_button.disabled = true
	upgrade_buttons.append(unlock_button)
	var x_pos = 350
	for i in range(4):
		var slot = get_parent().get_node("Globals").slot_upgrades[i]
		var slot_button = Button.new()
		slot_button.text = str(slot[1]) + ": " + slot[0]
		slot_button.position = Vector2(x_pos, 180)
		x_pos += 200
		add_child(slot_button)
		slot_button.pressed.connect(buy_slot.bind(slot[0], slot[1], i))
		upgrade_buttons.append(slot_button)
		# If it isn't available yet, or if it has already been bought, disable it
		if (slot[2] == false || slot[3] == true):
			slot_button.disabled = true
	x_pos = 350
	for i in range(4):
		var battery = get_parent().get_node("Globals").battery_upgrades[i]
		var battery_button = Button.new()
		battery_button.text = str(battery[1]) + ": " + battery[0]
		battery_button.position = Vector2(x_pos, 360)
		x_pos += 200
		add_child(battery_button)
		battery_button.pressed.connect(buy_battery.bind(battery[0], battery[1], i))
		upgrade_buttons.append(battery_button)
		# If it isn't available yet, or if it has already been bought, disable it
		if (battery[2] == false || battery[3] == true):
			battery_button.disabled = true
	x_pos = 350
	for i in range(4):
		var card = get_parent().get_node("Globals").card_upgrades[i]
		var card_button = Button.new()
		card_button.text = str(card[1]) + ": " + card[0].replace("Chip: ", "Chip:\n")
		card_button.position = Vector2(x_pos, 540)
		x_pos += 200
		add_child(card_button)
		card_button.pressed.connect(buy_card.bind(card[0], card[1], i))
		upgrade_buttons.append(card_button)
		# If it isn't available yet, or if it has already been bought, disable it
		if (card[2] == false || card[3] == true):
			card_button.disabled = true

func buy_card(upgrade_name, upgrade_cost, upgrade_index):
	if (num_diamonds >= upgrade_cost):
		set_num_diamonds(num_diamonds - upgrade_cost)
		get_parent().get_node("Globals").card_upgrades[upgrade_index][3] = true
		if (upgrade_index < 3):
			get_parent().get_node("Globals").card_upgrades[upgrade_index + 1][2] = true
		# TO DO: Clean this up to reduce duplication
		match upgrade_name:
			"Starting Chip: Shuffle":
				get_parent().get_node("Globals").starting_deck.append(["Shuffle", 0, 2])
			"Starting Chip: Bishop":
				get_parent().get_node("Globals").starting_deck.append(["Bishop", 3, 3])
			"Starting Chip: Antivirus":
				get_parent().get_node("Globals").starting_deck.append(["Antivirus", 0, 4])
			"Starting Chip: Crack Blocks":
				get_parent().get_node("Globals").starting_deck.append(["Crack Blocks", 0, 5])
		recreate_buttons()

func buy_slot(upgrade_name, upgrade_cost, upgrade_index):
	if (num_diamonds >= upgrade_cost):
		set_num_diamonds(num_diamonds - upgrade_cost)
		get_parent().get_node("Globals").slot_upgrades[upgrade_index][3] = true
		if (upgrade_index < 3):
			get_parent().get_node("Globals").slot_upgrades[upgrade_index + 1][2] = true
		get_parent().get_node("Globals").num_card_slots += 1
		recreate_buttons()

func buy_battery(upgrade_name, upgrade_cost, upgrade_index):
	if (num_diamonds >= upgrade_cost):
		set_num_diamonds(num_diamonds - upgrade_cost)
		get_parent().get_node("Globals").battery_upgrades[upgrade_index][3] = true
		if (upgrade_index < 3):
			get_parent().get_node("Globals").battery_upgrades[upgrade_index + 1][2] = true
		get_parent().get_node("Globals").max_turns += 10 * (upgrade_index + 1)
		recreate_buttons()

func unlock_side_panel():
	if (!active):
		return
	get_node("/root/BaseScene/AudioManager").play_click()
	if (num_diamonds >= 1):
		set_num_diamonds(num_diamonds - 1)
		get_parent().get_node("Globals").sideboard_unlocked = true
		get_parent().get_node("Globals").slot_upgrades[0][2] = true
		get_parent().get_node("Globals").battery_upgrades[0][2] = true
		get_parent().get_node("Globals").card_upgrades[0][2] = true
		recreate_buttons()
