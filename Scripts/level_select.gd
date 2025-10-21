class_name LevelSelect
extends Node2D

@export var active = false

# All possible rooms
var extra_rooms = ["Shop", "Rest Area", "Challenge"]
# The rooms we can currently navigate to
var rooms = ["Puzzle"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _to_string():
	return JSON.stringify(rooms)

func setup_from_array(_rooms):
	rooms = _rooms
	get_node("Left").text = rooms[0]
	get_node("Left").pressed.connect(choose_level.bind(rooms[0]))
	get_node("Right").text = rooms[1]
	get_node("Right").pressed.connect(choose_level.bind(rooms[1]))

func setup(num_rooms):
	rooms = ["Puzzle"]
	rooms.append(extra_rooms.pick_random())
	rooms.shuffle()
	rooms = rooms.slice(0, num_rooms)
	get_node("Left").text = rooms[0]
	get_node("Left").pressed.connect(choose_level.bind(rooms[0]))
	get_node("Right").text = rooms[1]
	get_node("Right").pressed.connect(choose_level.bind(rooms[1]))

func choose_level(level):
	if (active):
		get_node("/root/BaseScene/AudioManager").play_click()
		print(level)
		get_parent().navigate(level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
