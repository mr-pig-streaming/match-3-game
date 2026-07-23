class_name Globals
extends Node2D

@export var max_turns: int
@export var num_card_slots: int
var MAX_INT = 9223372036854775807

# Debuffs that are non-instant have max_int as durability since they are only removed by debugging
var debuffs = [["Three's a\nCrowd", MAX_INT, 0, "A maximum of 3 blocks can match per turn"],
			   ["Half", MAX_INT, 0, "Score is halved for all matches"],
			   ["Harden\nBlocks", 1, 0, "All hard blocks get 1 stage harder"],
			   ["Stone\nPrism", 1, 0, "Spawns several hard blocks at random"],
			   ["Exclusion\nZones", 1, 0, "Spawns several exclusion zones"],
			   ["Discharge", 1, 0, "Discharges some energy from the battery"],
			   ["Chaos", MAX_INT, 1, "Randomly changes the matching rules each turn"]
			  ]

var all_perks = [["Bishop", 3, 3, "Updates match mode to Diagonal. Duration: 3 Turns"],
				 ["Tetris", 3, 3, "Updates match mode to Tetris. Duration: 3 Turns"],
				 ["Double", 3, 4, "Doubles score received from matches. Duration: 3 Turns"],
				 ["Queen", 3, 5, "Updates match mode to straight and diagonal. Duration: 3 Turns"],
				 ["Time Stop", 3, 7, "Stops Time for 3 Turns"],
				 ["Crack Blocks", 0, 5, "Cracks All Hard Blocks"],
				 ["Colourblind", 3, 5, "Red and Green blocks can match with each other. Duration: 3 Tursn"],
				 ["Prism", 0, 6, "Creates several rainbow blocks"],
				 ["Quantum\nTranslocator", 3, 6, "Allows blocks to be moved anywhere is a single move. Duration: 3 Turns"],
				 ["Clear\nExclusions", 0, 5, "Clears all Exclusion Zones (Red X)"],
				 ["Shuffle", 0, 2, "Shuffles the location of all blocks"],
				 ["Antivirus", 0, 4, "Removes all active viruses"]
				 ]

var slot_upgrades = [
	["Unlock Slot 2", 20, false, false],
	["Unlock Slot 3", 30, false, false],
	["Unlock Slot 4", 40, false, false],
	["Unlock Slot 5", 50, false, false]
]

var battery_upgrades = [
	["Battery Pack", 30, false, false],
	["Super Battery", 50, false, false],
	["Supercharger", 70, false, false],
	["Megavolt Cell", 90, false, false]
]

var card_upgrades= [
	["Starting Chip: Shuffle", 10, false, false],
	["Starting Chip: Bishop", 20, false, false],
	["Starting Chip: Antivirus", 30, false, false],
	["Starting Chip: Crack Blocks", 40, false, false],
]

var sideboard_unlocked = false

var radar_unlocked = false

var starting_helper: String = "Chippy"
var starting_shards = 0

# The deck at the start of a round - will be updated when buying new cards between rounds
@export var starting_deck = []

# Called when the node enters the scene tree for the first time.
func _ready():
	max_turns = 25
	num_card_slots = 1
	print("Max turns: " + str(max_turns))
	starting_deck = []
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func increase_max_turns(num_turns):
	max_turns += num_turns
	print("Max turns: " + str(max_turns))

func increase_card_slots(num_slot):
	num_card_slots += num_slot

func get_shop_cards(num_cards: int):
	var possible_perks = []
	for perk in all_perks:
		print("Testing " + perk[0])
		var in_deck = false
		for chip in starting_deck:
			if (perk.hash == chip.hash):
				in_deck = true
		# If the card isn't in the existing deck, we can buy it in the shop
		if (!in_deck):
			possible_perks.append(perk)
	possible_perks.shuffle()
	if (num_cards <= possible_perks.size()):
		return possible_perks.slice(0, num_cards)
	return possible_perks

func get_random_debuff():
	var debuff = debuffs.pick_random()
	return Card.new_card(debuff[0], debuff[1], debuff[2], debuff[3], "DEBUFF")

func add_random_card_to_start():
	var card = all_perks.pick_random()
	starting_deck.append(card)

func globals_to_json():
	var json_string = JSON.stringify(starting_deck) + "\n"
	json_string += str(max_turns) + "," + str(num_card_slots) + "\n"
	json_string += JSON.stringify(slot_upgrades) + "\n"
	json_string += JSON.stringify(battery_upgrades) + "\n"
	json_string += JSON.stringify(card_upgrades) + "\n"
	json_string += str(sideboard_unlocked) + "\n"
	json_string += str(radar_unlocked)
	return json_string

func json_to_globals(save_lines):
	print(save_lines)
	var json = JSON.new()
	json.parse(save_lines[0])
	var deck = json.data
	for card in deck:
		var card_parts = card#.split(",")
		starting_deck.append([card_parts[0], int(card_parts[1]), int(card_parts[2])])
	var line2 = save_lines[1].split(",")
	max_turns = int(line2[0])
	num_card_slots = int(line2[1])
	json = JSON.new()
	json.parse(save_lines[2])
	slot_upgrades = []
	var slots = json.data
	for slot in slots:
		var slot_parts = slot#.split(",")
		slot_upgrades.append([slot_parts[0], int(slot_parts[1]), bool(slot_parts[2]), bool(slot_parts[3])])
	json = JSON.new()
	json.parse(save_lines[3])
	battery_upgrades = []
	var batteries = json.data
	for battery in batteries:
		var battery_parts = battery#.split(",")
		battery_upgrades.append([battery_parts[0], int(battery_parts[1]), bool(battery_parts[2]), bool(battery_parts[3])])
	json = JSON.new()
	json.parse(save_lines[4])
	card_upgrades = []
	var cards = json.data
	for card in cards:
		var card_parts = card#.split(",")
		card_upgrades.append([card_parts[0], int(card_parts[1]), bool(card_parts[2]), bool(card_parts[3])])
	if (save_lines[5] == "true"):
		sideboard_unlocked = true
	else:
		sideboard_unlocked = false
	if (save_lines[6] == "true"):
		radar_unlocked = true
	else:
		radar_unlocked = false
