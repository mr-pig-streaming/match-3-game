class_name LevelSelect
extends Node2D

@export var active = false

# All possible rooms
var extra_rooms = ["Shop", "Rest Area", "Challenge"]
# The rooms we can currently navigate to
var rooms = ["Puzzle"]
# The index of when we should get a special room
var special_index: int
# Which level we're on
var current_index: int

# Called when the node enters the scene tree for the first time.
func _ready():
	current_index = -1
	special_index = randi_range(0, 2)
	pass # Replace with function body.

func _to_string():
	return JSON.stringify(rooms)

func setup_from_array(_rooms):
	rooms = _rooms
	get_node("Left").text = rooms[0]
	get_node("Left").pressed.connect(choose_level.bind(rooms[0]))
	if (rooms.size() > 1):
		get_node("Right").text = rooms[1]
		get_node("Right").pressed.connect(choose_level.bind(rooms[1]))

func setup():
	print("Current: " + str(current_index) + " Special: " + str(special_index))
	rooms = ["Puzzle"]
	rooms.append(extra_rooms.pick_random())
	get_node("Left").text = rooms[0]
	get_node("Left").pressed.connect(choose_level.bind(rooms[0]))
	if (current_index == special_index && get_node("/root/BaseScene/Globals").sideboard_unlocked):
		get_node("Right").text = rooms[1]
		get_node("Right").pressed.connect(choose_level.bind(rooms[1]))
		get_node("Right").disabled = false
		get_node("Right").visible = true
	else:
		get_node("Right").disabled = true
		get_node("Right").visible = false
	current_index = (current_index + 1) % 3
	if (current_index == 0):
		special_index = randi_range(0, 2)

func choose_level(level):
	if (active):
		get_node("/root/BaseScene/AudioManager").play_click()
		print(level)
		get_parent().navigate(level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
