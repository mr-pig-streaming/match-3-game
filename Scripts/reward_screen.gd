class_name RewardScreen
extends Node2D

var active: bool = true
var reward_fragments = []
var num_fragments = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	for n in num_fragments:
		var frag_type = randi_range(0, 2)
		if (frag_type == 0):
			reward_fragments.append(["COST", randi_range(5, 10)])
		if (frag_type == 1):
			reward_fragments.append(["EFFECT", get_node("/root/BaseScene/Globals").get_random_chip_effect()])
		if (frag_type == 2):
			reward_fragments.append(["DURATION", randi_range(1, 3)])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_take_it_button_pressed():
	print("Taking chip fragments...")
	for n in num_fragments:
		print("Taking fragment " + str(reward_fragments[n]))
		get_parent().add_fragment(reward_fragments[n][0], str(reward_fragments[n][1]))
	get_parent().level_select()
	pass # Replace with function body.
