class_name SideBoard
extends Node2D

signal card_activated

var active: bool = true
# The number of cards we currently have on hand

var x_offset = 720
var y_offset = 80
var y_tick = 140
var x_tick = 140

var y_offset_hand = 180
var x_offset_hand = 880

# The microchips associated with each of the colour buttons
var microchips = [null, null, null, null, null, null]

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Unlocked: " + str(get_parent().get_parent().get_node("Globals").sideboard_unlocked))
	var helper
	if (get_parent().get_parent().get_node("Globals").starting_helper == "Chippy"):
		helper = preload("res://Scenes/clippy_helper.tscn").instantiate()
	if (get_parent().get_parent().get_node("Globals").starting_helper == "Cleaner"):
		helper = preload("res://Scenes/cleaner_helper.tscn").instantiate()
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_input_event(viewport, event, shape_idx):
	pass

func sideboard_to_json():
	var json_string = ""
	return json_string

# Receives an array of 2 JSON strings as follows:
# [0]: The chips in hand
# [1]: The active cards and the card zone
func json_to_sideboard(json_array):
	active = true
	var json = JSON.new()
	# Load the hand
	json.parse(json_array[0])
	var hand_array = json.data


func remove_all_debuffs():
	pass


func _on_red_button_pressed():
	print("Clicked red")
	if (microchips[0] != null and get_parent().red_matched >= microchips[0].cost):
		# Instants get sent to the gameboard directly...
		if microchips[0].base_duration == 0:
			get_parent().set_grid_effect(microchips[0].effect)
		# Longer term effects get set to active and handled separately
		else:
			get_parent().set_grid_effect(microchips[0].effect)
			microchips[0].activate(get_parent().red_matched)
		get_parent().red_matched = 0
		get_node("ColourContainer/RedButton").disabled = true


func _on_orange_button_pressed():
	print("Clicked orange")
	if (microchips[1] != null and get_parent().orange_matched >= microchips[1].cost):
		# Instants get sent to the gameboard directly...
		if microchips[1].base_duration == 0:
			get_parent().set_grid_effect(microchips[1].effect)
		# Longer term effects get set to active and handled separately
		else:
			get_parent().set_grid_effect(microchips[1].effect)
			microchips[1].activate(get_parent().orange_matched)
		get_parent().orange_matched = 0
		get_node("ColourContainer/OrangeButton").disabled = true


func _on_yellow_button_pressed():
	print("Clicked yellow")
	if (microchips[2] != null and get_parent().yellow_matched >= microchips[2].cost):
		# Instants get sent to the gameboard directly...
		if microchips[2].base_duration == 0:
			get_parent().set_grid_effect(microchips[2].effect)
		# Longer term effects get set to active and handled separately
		else:
			get_parent().set_grid_effect(microchips[2].effect)
			microchips[2].activate(get_parent().yellow_matched)
		get_parent().yellow_matched = 0
		get_node("ColourContainer/YellowButton").disabled = true


func _on_green_button_pressed():
	print("Clicked green")
	if (microchips[3] != null and get_parent().green_matched >= microchips[3].cost):
		# Instants get sent to the gameboard directly...
		if microchips[3].base_duration == 0:
			get_parent().set_grid_effect(microchips[3].effect)
		# Longer term effects get set to active and handled separately
		else:
			get_parent().set_grid_effect(microchips[3].effect)
			microchips[3].activate(get_parent().green_matched)
		get_parent().green_matched = 0
		get_node("ColourContainer/GreenButton").disabled = true


func _on_blue_button_pressed():
	print("Clicked blue")
	if (microchips[4] != null and get_parent().blue_matched >= microchips[4].cost):
		# Instants get sent to the gameboard directly...
		if microchips[4].base_duration == 0:
			get_parent().set_grid_effect(microchips[4].effect)
		# Longer term effects get set to active and handled separately
		else:
			get_parent().set_grid_effect(microchips[4].effect)
			microchips[4].activate(get_parent().blue_matched)
		get_parent().blue_matched = 0
		get_node("ColourContainer/BlueButton").disabled = true


func _on_purple_button_pressed():
	print("Clicked purple")
	if (microchips[5] != null and get_parent().purple_matched >= microchips[5].cost):
		# Instants get sent to the gameboard directly...
		if microchips[5].base_duration == 0:
			get_parent().set_grid_effect(microchips[5].effect)
		# Longer term effects get set to active and handled separately
		else:
			get_parent().set_grid_effect(microchips[5].effect)
			microchips[5].activate(get_parent().purple_matched)
		get_parent().purple_matched = 0
		get_node("ColourContainer/PurpleButton").disabled = true

func update_buttons():
	if (microchips[0] != null and get_parent().red_matched >= microchips[0].cost):
		get_node("ColourContainer/RedButton").disabled = false
	if (microchips[1] != null and get_parent().orange_matched >= microchips[1].cost):
		get_node("ColourContainer/OrangeButton").disabled = false
	if (microchips[2] != null and get_parent().yellow_matched >= microchips[2].cost):
		get_node("ColourContainer/YellowButton").disabled = false
	if (microchips[3] != null and get_parent().green_matched >= microchips[3].cost):
		get_node("ColourContainer/GreenButton").disabled = false
	if (microchips[4] != null and get_parent().blue_matched >= microchips[4].cost):
		get_node("ColourContainer/BlueButton").disabled = false
	if (microchips[5] != null and get_parent().purple_matched >= microchips[5].cost):
		get_node("ColourContainer/PurpleButton").disabled = false

func reduce_chip_duration(interval):
	for i in range(6):
		if microchips[i] != null:
			microchips[i].reduce_duration(interval)

func connect_expired_signals():
	for i in range(6):
		if microchips[i] != null:
			microchips[i].expired.connect(expire_effect)

func expire_effect(effect):
	print("Removing " + effect + " from active")
	get_parent().remove_card_effect(effect)
	
func get_active_chip_effects():
	var active_chips = []
	for i in range(0, 6):
		if (microchips[i] != null and microchips[i].active):
			active_chips.append(microchips[i].effect)
	return active_chips
