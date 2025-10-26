class_name GameBoard
extends Node2D

signal game_finished(game_state)

@export var turns_left: int
@export var diamonds: int = 0
var active = true
var max_turns: int
var score: int = 0
var goal: int = 10
var goal_score = 10000000
var puzzle_level = 1

# All the cards/chips 
var deck = []
# The currently active scene. Used for scene transitions
var active_scene
var levelSelect: LevelSelect = null
var saved_state: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func setup_from_scratch():
	randomize()
	var grid: Grid = preload("res://Scenes/grid.tscn").instantiate()
	add_child(grid)
	grid.set_level(puzzle_level)
	grid.name = "Grid"
	grid.visible = true
	grid.active = true
	grid.end_turn.connect(_on_grid_end_turn)
	active_scene = grid
	get_node("Score_Label").text = "Score: " + str(score)
	get_node("Turns_Label").text = "Turns Left: " + str(turns_left)  + "/" + str(max_turns)
	get_node("Goal_Label").text = "Goal: 0/" + str(goal)
	get_node("Diamonds_Label").text = "Shards: " + str(diamonds)
	setup_deck()

# Creates the game board from the appropriate lines of the save file
# Only the necessary lines should be passed, in an array of strings
func setup_from_file(save_lines):
	# Setup the sideboard
	get_node("SideBoard").json_to_sideboard(save_lines.slice(0, 2))
	# Setup the deck
	var json = JSON.new()
	json.parse(save_lines[2])
	var _deck = json.data
	for d in _deck:
		var card = Card.card_from_string(d)
		deck.append(card)
	# Setup the basics of the game board
	var stats = save_lines[3].split(",")
	turns_left = int(stats[0])
	max_turns = int(stats[1])
	diamonds = int(stats[2])
	score = int(stats[3])
	goal = int(stats[4])
	goal_score = int(stats[5])
	puzzle_level = int(stats[6])
	# Setup the level select
	json = JSON.new()
	json.parse(save_lines[4])
	var select: LevelSelect = preload("res://Scenes/level_select.tscn").instantiate()
	add_child(select)
	select.name = "LevelSelect"
	select.active = true
	select.visible = true
	select.setup_from_array(json.data)
	active_scene = select
	get_node("Score_Label").text = "Score: " + str(score)
	get_node("Turns_Label").text = "Turns Left: " + str(turns_left)  + "/" + str(max_turns)
	get_node("Goal_Label").text = "Goal: 0/" + str(goal)
	get_node("Diamonds_Label").text = "Shards: " + str(diamonds)

func setup_deck():
	var base_deck = get_parent().get_node("Globals").starting_deck
	var num_cards = base_deck.size()
	for i in num_cards:
		var card = Card.new_card(base_deck[i][0], base_deck[i][1], base_deck[i][2])
		deck.append(card)

func update_check_type():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func check_win(total_matched):
	print("Check win")
	get_node("Goal_Label").text = "Goal: " + str(total_matched) + "/" + str(goal)
	if turns_left <= 0:
		print("You lose!")
		game_finished.emit("LOSE")
	elif score >= goal_score:
		game_finished.emit("WIN")
	elif turns_left >= 0 && total_matched >= goal:
		level_select()

func check_win_challenge(num_blocks):
	print("Check win challenge: " + str(num_blocks))
	if turns_left <= 0:
		print("You lose!")
		game_finished.emit("LOSE")
	elif score >= goal_score:
		game_finished.emit("WIN")
	elif turns_left >= 0 && num_blocks == 0:
		level_select()

func level_select():
	if (levelSelect != null):
		levelSelect.queue_free()
		levelSelect = null
	var select: LevelSelect = preload("res://Scenes/level_select.tscn").instantiate()
	add_child(select)
	select.name = "LevelSelect"
	select.active = true
	select.visible = true
	select.setup(2)
	saved_state = "IN_RUN" + "\n" + get_node("SideBoard").sideboard_to_json() + gameboard_to_json()
	get_parent().save_state = saved_state
	transition_to(select)

func add_diamonds(num_to_add):
	diamonds += num_to_add
	get_node("Diamonds_Label").text = "Shards: " + str(diamonds)

func spend_diamonds(num_to_spend):
	if (diamonds < num_to_spend):
		return false
	diamonds -= num_to_spend
	get_node("Diamonds_Label").text = "Shards: " + str(diamonds)
	return true

func add_score(points):
	score += points
	get_node("Score_Label").text = "Score: " + str(score)

func reset_score():
	score = 0
	get_node("Score_Label").text = "Score: " + str(score)

func reduce_turns(num_turns):
	turns_left -= num_turns
	get_node("Turns_Label").text = "Turns Left: " + str(turns_left)  + "/" + str(max_turns)


func _on_side_board_card_activated(card: Card):
	if (active_scene is Grid):
		set_grid_effect(card.card_name)
		if (card.type != "DEBUFF"):
			active_scene.recheck_matches()

func _on_grid_end_turn(moved: bool):
	# Update the sideboard to reduce the  durability of cards
	print("Moved: " + str(moved))
	if (moved):
		get_node("SideBoard").reduce_card_durability()
		set_grid_effects()
	if (moved):
		get_node("SideBoard/Helper").act()
		if (get_node("Grid").round_matched >= 5):
			if (get_node("Grid").round_matched >= 9):
				get_node("GreatSprite").texture = preload("res://Art/Combo_outstanding.png")
			elif (get_node("Grid").round_matched >= 7):
				get_node("GreatSprite").texture = preload("res://Art/Combo_awesome.png")
			else:
				get_node("GreatSprite").texture = preload("res://Art/Combo_great.png")
			get_node("/root/BaseScene/AudioManager").play_combo(get_node("Grid").round_matched)
			var combo_tween: Tween = create_tween()
			combo_tween.tween_property(get_node("GreatSprite"), "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			combo_tween.finished.connect(remove_combo_sprite)
			combo_tween.play()
	pass # Replace with function body.

func remove_combo_sprite():
	await get_tree().create_timer(0.5).timeout
	var combo_tween: Tween = create_tween()
	combo_tween.tween_property(get_node("GreatSprite"), "scale", Vector2(0.0, 0.0), 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	combo_tween.play()

# Draw a random card from the deck
func random_card():
	if (deck.size() <= 0):
		return null
	if (diamonds <= 0):
		return null
	spend_diamonds(1)
	var index = randi_range(0, deck.size() - 1)
	var card = deck[index]
	deck.remove_at(index)
	return card

func transition_to(target_scene):
	print("Transitioning to " + str(target_scene))
	target_scene.active = false
	target_scene.visible = false
	var inactive_scene = active_scene
	var tween: Tween = create_tween()
	tween.tween_property(get_node("ShutterSprite"),"position", Vector2(640, 360), 0.3).set_ease(Tween.EASE_OUT)
	tween.play()
	active_scene = target_scene
	await get_tree().create_timer(1.2).timeout
	inactive_scene.active = false
	inactive_scene.visible = false
	inactive_scene.queue_free()
	inactive_scene = null
	target_scene.active = true
	target_scene.visible = true
	print("Active scene is a Grid? " + str(active_scene is Grid))
	var tween2: Tween = create_tween()
	tween2.tween_property(get_node("ShutterSprite"),"position", Vector2(640, -640), 0.3).set_ease(Tween.EASE_OUT)
	tween2.play()

func navigate(level):
	match level:
		"Shop":
			var store: Shop = preload("res://Scenes/shop.tscn").instantiate()
			add_child(store)
			store.name = "Shop"
			store.visible = true
			transition_to(store)
		"Puzzle":
			puzzle_level += 1
			var grid: Grid = preload("res://Scenes/grid.tscn").instantiate()
			add_child(grid)
			grid.name = "Grid"
			grid.visible = true
			grid.active = true
			grid.end_turn.connect(_on_grid_end_turn)
			# reset_score()
			goal *= 1.5
			get_node("Goal_Label").text = "Goal: 0/" + str(goal)
			transition_to(grid)
			set_grid_effects()
			grid.clear_board()
			grid.setup_pieces()
			grid.set_level(puzzle_level)
		"Challenge":
			puzzle_level += 1
			var grid: Grid = preload("res://Scenes/grid.tscn").instantiate()
			add_child(grid)
			grid.name = "Grid"
			grid.visible = true
			grid.active = true
			grid.end_turn.connect(_on_grid_end_turn)
			# reset_score()
			goal *= 1.5
			get_node("Goal_Label").text = "Goal: " + str(goal)
			transition_to(grid)
			set_grid_effects()
			grid.clear_board()
			grid.setup_pieces()
			grid.set_level(puzzle_level, true)
		"Rest Area":
			var rest: RestArea = preload("res://Scenes/rest_area.tscn").instantiate()
			add_child(rest)
			rest.name = "RestArea"
			rest.visible = true
			transition_to(rest)

func set_grid_effects():
	var active_cards = get_node("SideBoard").get_active_card_effects()
	for card in active_cards:
		print(card)
		set_grid_effect(card)

func set_grid_effect(card_name: String):
	print("Card name: " + card_name)
	print(active_scene)
	if (active_scene is Grid):
		if (card_name == "Bishop"):
			active_scene.add_effect("MATCH_TYPE_DIAGONAL")
		if (card_name == "Tetris"):
			active_scene.add_effect("MATCH_TYPE_TETRIS")
		if (card_name == "Queen"):
			active_scene.add_effect("MATCH_TYPE_QUEEN")
		if (card_name == "Chaos"):
			active_scene.add_effect("MATCH_TYPE_CHAOS")
		if (card_name == "Double"):
			active_scene.add_effect("MULTIPLIER_TYPE_2")
		if (card_name == "Three's a\nCrowd"):
			active_scene.add_effect("MATCH_TYPE_3")
		if (card_name == "Time Stop"):
			active_scene.add_effect("TIME_STOP")
		if (card_name == "Half"):
			active_scene.add_effect("HALF")
		if (card_name == "Crack Blocks"):
			active_scene.crack_all_blocks()
			get_node("InstantExpiryTimer").start()
		if (card_name == "Prism"):
			active_scene.spawn_rainbow_blocks()
			get_node("InstantExpiryTimer").start()
		if (card_name == "Harden\nBlocks"):
			active_scene.harden_all_blocks()
			get_node("InstantExpiryTimer").start()
		if (card_name == "Stone\nPrism"):
			active_scene.spawn_hard_blocks()
			get_node("InstantExpiryTimer").start()
		if (card_name == "Colourblind"):
			print("Activating colourblind")
			active_scene.add_effect("COLOURBLIND")
		if (card_name == "Quantum\nTranslocator"):
			active_scene.add_effect("TRANSLOCATOR")
		if (card_name == "Clear\nExclusions"):
			active_scene.remove_exclusion_zones()
		if (card_name == "Exclusion\nZones"):
			active_scene.add_exclusion_zones()
			get_node("InstantExpiryTimer").start()
		if (card_name == "Shuffle"):
			active_scene.shuffle()
			get_node("InstantExpiryTimer").start()
		if (card_name == "Antivirus"):
			get_node("SideBoard").remove_all_debuffs()
			get_node("InstantExpiryTimer").start()
		if (card_name == "Discharge"):
			set_num_turns(turns_left - 5)
			get_node("InstantExpiryTimer").start()

func remove_card_effect(card_name):
	if (active_scene is Grid):
		if (card_name == "Bishop"):
			active_scene.remove_effect("MATCH_TYPE_DIAGONAL")
		if (card_name == "Tetris"):
			active_scene.remove_effect("MATCH_TYPE_TETRIS")
		if (card_name == "Queen"):
			active_scene.remove_effect("MATCH_TYPE_QUEEN")
		if (card_name == "Chaos"):
			active_scene.remove_effect("MATCH_TYPE_CHAOS")
		if (card_name == "Double"):
			active_scene.remove_effect("MULTIPLIER_TYPE_2")
		if (card_name == "Three's a\nCrowd"):
			active_scene.remove_effect("MATCH_TYPE_3")
		if (card_name == "Time Stop"):
			active_scene.remove_effect("TIME_STOP")
			active_scene.recheck_matches()
		if (card_name == "Half"):
			active_scene.remove_effect("HALF")
		if (card_name == "Crack Blocks"):
			pass #This is an instant, nothing to do
		if (card_name == "Harden\nBlocks"):
			pass #This is an instant, nothing to do
		if (card_name == "Stone\nPrism"):
			pass #This is an instant, nothing to do
		if (card_name == "Colourblind"):
			active_scene.remove_effect("COLOURBLIND")
			active_scene.correct_colours()
		if (card_name == "Quantum\nTranslocator"):
			active_scene.remove_effect("TRANSLOCATOR")
		if (card_name == "Exclusion\nZones"):
			pass #This is an instant, nothing to do

func recharge():
	turns_left += 5
	if (turns_left > max_turns):
		turns_left = max_turns
	get_node("Turns_Label").text = "Turns Left: " + str(turns_left) + "/" + str(max_turns)

func set_num_turns(num_turns: int):
	turns_left = num_turns
	get_node("Turns_Label").text = "Turns Left: " + str(turns_left) + "/" + str(max_turns)

func set_max_turns(turns: int):
	max_turns = turns
	get_node("Turns_Label").text = "Turns Left: " + str(turns_left) + "/" + str(max_turns)

func increase_max_turns(turns: int):
	set_max_turns(max_turns + turns)

func shop(shop_item: ShopItem):
	if (shop_item.item_name == "Battery Pack"):
		increase_max_turns(5)
		recharge()
	if (shop_item.item_name == "Big Battery Pack"):
		increase_max_turns(10)
		recharge()
		recharge()
	if (shop_item.card != null):
		deck.append(shop_item.card)


func _on_instant_expiry_timer_timeout():
	get_node("SideBoard").deactivate_cards()

func activate_debuff():
	var debuff: Card = get_parent().get_node("Globals").get_random_debuff()
	get_node("SideBoard").activate_debuff(debuff)

func gameboard_to_json():
	var json_string = JSON.stringify(deck) + "\n"
	json_string += str(turns_left) + "," + str(max_turns) + "," + str(diamonds) + "," + str(score) + "," + str(goal) + "," + str(goal_score) + "," + str(puzzle_level) + "\n"
	json_string += str(get_node("LevelSelect"))
	return json_string

func _input(event):
	if (!active):
		return
	if Input.is_key_pressed(KEY_D):
		print("Activating Virus")
		activate_debuff()
	if Input.is_key_pressed(KEY_ESCAPE):
		print("Popup Menu")
		get_node("SideBoard").active = false
		active_scene.active = false
		active = false
		var popup = preload("res://Scenes/popup_menu.tscn").instantiate()
		popup.name = "PopupMenu"
		popup.z_index = 10
		popup.position = Vector2(640, 360)
		add_child(popup)
		popup.get_node("ResumeButton").pressed.connect(closePopupMenu)
		popup.get_node("SaveExitButton").pressed.connect(saveExitGame)
		popup.get_node("ExitButton").pressed.connect(exitGame)
		# Deactivate the save & exit button if this is the very first puzzle of the run
		if (puzzle_level == 1 && active_scene is Grid && get_parent().save_state == ""):
			popup.get_node("SaveExitButton").disabled = true
		else:
			popup.get_node("SaveExitButton").disabled = false

func closePopupMenu():
	print("Resume")
	get_node("/root/BaseScene/AudioManager").play_click()
	get_node("SideBoard").active = true
	active_scene.active = true
	get_node("PopupMenu").queue_free()
	active = true

func saveExitGame():
	print("Save and exit...")
	get_parent().save_game()
	get_tree().quit()

func exitGame():
	print("Exit without saving...")
	get_tree().quit()


func _on_button_pressed():
	get_node("/root/BaseScene/AudioManager").play_click()
	get_node("SideBoard").active = false
	active_scene.active = false
	active = false
	var guidebook = preload("res://Scenes/guidebook.tscn").instantiate()
	guidebook.name = "Guidebook"
	add_child(guidebook)
	guidebook.z_index = 10
	guidebook.position = Vector2(640, 360)
	guidebook.get_node("CloseButton").pressed.connect(close_guidebook)

func close_guidebook():
	get_node("/root/BaseScene/AudioManager").play_click()
	get_node("SideBoard").active = true
	active_scene.active = true
	active = true
	get_node("Guidebook").queue_free()
