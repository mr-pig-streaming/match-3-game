class_name RestArea
extends Node2D

var activated: bool = false
var active: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_recharge_button_pressed():
	get_node("ClickPlayer").play()
	if (!activated):
		print("Recharging")
		get_parent().recharge()
		activated = true
	pass # Replace with function body.


func _on_debug_button_pressed():
	get_node("ClickPlayer").play()
	if (!activated):
		print("Debugging")
		activated = true
		get_parent().get_node("SideBoard").remove_all_debuffs()
	pass # Replace with function body.


func _on_leave_button_pressed():
	print("Leaving")
	get_parent().level_select()
