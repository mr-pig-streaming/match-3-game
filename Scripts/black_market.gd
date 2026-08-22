class_name BlackMarket
extends Node2D

@export var num_diamonds: int = 0
var active = true
var upgrade_buttons = []
var helper_bought = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#create_buttons()
	get_parent().get_node("Globals").starting_helper = "Chippy"
	get_parent().save_state = "BLACK_MARKET\n" + black_market_to_json()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_num_diamonds(diamonds: int):
	num_diamonds = diamonds
	get_node("ShardsLabel").text = ""
	get_node("ShardsLabel").clear()
	get_node("ShardsLabel").push_color(Color.BLACK)
	get_node("ShardsLabel").append_text("Shards: " + str(diamonds))

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

func create_hacker_buttons():
	# Create the unlock button
	var unlock_button = Button.new()
	unlock_button.text = "1: Unlock Maintenance Panel"
	unlock_button.name = "UnlockButton"
	unlock_button.position = Vector2(1000, 150)
	add_child(unlock_button)
	unlock_button.pressed.connect(unlock_side_panel)
	print(get_parent().get_node("Globals").sideboard_unlocked)
	if (get_parent().get_node("Globals").sideboard_unlocked == true):
		unlock_button.disabled = true
	upgrade_buttons.append(unlock_button)
	var y_pos = 225
	var helper_button = Button.new()
	helper_button.text = "10: Unlock a special helper\nfor the next round"
	helper_button.name = "HelperButton"
	helper_button.position = Vector2(1000, y_pos)
	if (helper_bought == true || get_parent().get_node("Globals").sideboard_unlocked == false):
		print("Disabling helper button...")
		helper_button.disabled = true
	else:
		helper_button.disabled = false
	add_child(helper_button)
	helper_button.pressed.connect(buy_helper.bind(10))
	upgrade_buttons.append(helper_button)
	y_pos += 75
	var radar_button = Button.new()
	radar_button.text = "10: Unlock radar"
	radar_button.name = "RadarButton"
	radar_button.position = Vector2(1000, y_pos)
	if (get_parent().get_node("Globals").radar_unlocked == true || get_parent().get_node("Globals").sideboard_unlocked == false):
		print("Disabling radar button...")
		radar_button.disabled = true
	else:
		radar_button.disabled = false
	add_child(radar_button)
	radar_button.pressed.connect(buy_radar.bind(10))
	upgrade_buttons.append(radar_button)

func clear_hacker_buttons():
	for b in upgrade_buttons:
		if (b != null):
			b.queue_free()
	upgrade_buttons.clear()

func recreate_hacker_buttons():
	clear_hacker_buttons()
	create_hacker_buttons()
	get_parent().save_state = "BLACK_MARKET\n" + black_market_to_json()

func create_battery_buttons():
	var y_pos = 150
	for i in range(4):
		var battery = get_parent().get_node("Globals").battery_upgrades[i]
		var battery_button = Button.new()
		battery_button.text = str(battery[1]) + ": " + battery[0]
		battery_button.name = "BatteryButton" + str(i)
		battery_button.position = Vector2(1000, y_pos)
		y_pos += 75
		add_child(battery_button)
		battery_button.pressed.connect(buy_battery.bind(battery[0], battery[1], i))
		upgrade_buttons.append(battery_button)
		# If it isn't available yet, or if it has already been bought, disable it
		if (battery[2] == false || battery[3] == true):
			battery_button.disabled = true

func clear_battery_buttons():
	for b in upgrade_buttons:
		if (b != null):
			b.queue_free()
	upgrade_buttons.clear()

func recreate_battery_buttons():
	clear_battery_buttons()
	create_battery_buttons()
	get_parent().save_state = "BLACK_MARKET\n" + black_market_to_json()

func create_smuggler_buttons():
	var half_shards = num_diamonds / 2
	var smuggle_button = Button.new()
	smuggle_button.text = "Smuggle remaining shards\nI keep " + str(num_diamonds - half_shards) + ", you'll start with " + str(half_shards)
	smuggle_button.position = Vector2(1000, 150)
	add_child(smuggle_button)
	smuggle_button.pressed.connect(smuggle_shards)
	upgrade_buttons.append(smuggle_button)

func clear_smuggler_buttons():
	for b in upgrade_buttons:
		if (b != null):
			b.queue_free()

func recreate_smuggler_buttons():
	clear_smuggler_buttons()
	create_smuggler_buttons()
	get_parent().save_state = "BLACK_MARKET\n" + black_market_to_json()

func buy_battery(upgrade_name, upgrade_cost, upgrade_index):
	if (!active):
		return
	if (num_diamonds >= upgrade_cost):
		set_num_diamonds(num_diamonds - upgrade_cost)
		get_parent().get_node("Globals").battery_upgrades[upgrade_index][3] = true
		if (upgrade_index < 3):
			get_parent().get_node("Globals").battery_upgrades[upgrade_index + 1][2] = true
		get_parent().get_node("Globals").max_turns += 10 * (upgrade_index + 1)
		recreate_battery_buttons()

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
		recreate_hacker_buttons()

func buy_helper(cost):
	if (!active):
		return
	get_node("/root/BaseScene/AudioManager").play_click()
	if (num_diamonds >= cost):
		set_num_diamonds(num_diamonds - cost)
		get_parent().get_node("Globals").starting_helper = "Cleaner"
		helper_bought = true
		recreate_hacker_buttons()

func buy_radar(cost):
	if (!active):
		return
	get_node("/root/BaseScene/AudioManager").play_click()
	if (num_diamonds >= cost):
		set_num_diamonds(num_diamonds - cost)
		get_parent().get_node("Globals").radar_unlocked = true
		recreate_hacker_buttons()

func smuggle_shards():
	if (!active):
		return
	get_node("/root/BaseScene/AudioManager").play_click()
	var half_shards = num_diamonds / 2
	get_parent().get_node("Globals").starting_shards = half_shards
	set_num_diamonds(0)
	recreate_smuggler_buttons()

func _on_hacker_button_pressed():
	if (!active):
		return
	get_node("HackerSprite").visible = true
	get_node("HackerButton").visible = false
	get_node("HackerButton").disabled = true
	get_node("BatteryButton").visible = false
	get_node("BatteryButton").disabled = true
	get_node("SmugglerButton").visible = false
	get_node("SmugglerButton").disabled = true
	get_node("NewRunButton").visible = false
	get_node("NewRunButton").disabled = true
	get_node("MarketBackground").visible = false
	create_hacker_buttons()
	pass # Replace with function body.


func _on_battery_button_pressed():
	if (!active):
		return
	get_node("BatterySprite").visible = true
	get_node("HackerButton").visible = false
	get_node("HackerButton").disabled = true
	get_node("BatteryButton").visible = false
	get_node("BatteryButton").disabled = true
	get_node("SmugglerButton").visible = false
	get_node("SmugglerButton").disabled = true
	get_node("NewRunButton").visible = false
	get_node("NewRunButton").disabled = true
	get_node("MarketBackground").visible = false
	create_battery_buttons()
	pass # Replace with function body.


func _on_back_button_pressed():
	if (!active):
		return
	get_node("MarketBackground").visible = true
	get_node("HackerButton").visible = true
	get_node("HackerButton").disabled = false
	get_node("BatteryButton").visible = true
	get_node("BatteryButton").disabled = false
	get_node("SmugglerButton").visible = true
	get_node("SmugglerButton").disabled = false
	get_node("NewRunButton").visible = true
	get_node("NewRunButton").disabled = false
	get_node("HackerSprite").visible = false
	get_node("BatterySprite").visible = false
	get_node("SmugglerSprite").visible = false
	clear_battery_buttons()
	clear_hacker_buttons()
	clear_smuggler_buttons()
	pass # Replace with function body.


func _on_smuggler_button_pressed():
	if (!active):
		return
	get_node("SmugglerSprite").visible = true
	get_node("HackerButton").visible = false
	get_node("HackerButton").disabled = true
	get_node("BatteryButton").visible = false
	get_node("BatteryButton").disabled = true
	get_node("SmugglerButton").visible = false
	get_node("SmugglerButton").disabled = true
	get_node("NewRunButton").visible = false
	get_node("NewRunButton").disabled = true
	create_smuggler_buttons()
	get_node("MarketBackground").visible = false
	pass # Replace with function body.


func _on_guidebook_button_pressed():
	if (!active):
		return
	get_node("/root/BaseScene/AudioManager").play_click()
	active = false
	var guidebook = preload("res://Scenes/guidebook.tscn").instantiate()
	guidebook.name = "Guidebook"
	add_child(guidebook)
	guidebook.z_index = 10
	guidebook.position = Vector2(640, 360)
	guidebook.get_node("CloseButton").pressed.connect(close_guidebook)

func close_guidebook():
	active = true
	get_node("Guidebook").queue_free()
