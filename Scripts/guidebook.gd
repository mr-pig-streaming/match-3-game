extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_tab_1_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		print("Click Tab 1")
		move_child(get_node("Page1"), 3)


func _on_tab_2_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		print("Click Tab 2")
		move_child(get_node("Page2"), 3)


func _on_tab_3_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		print("Click Tab 3")
		move_child(get_node("Page3"), 3)


func _on_tab_4_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		print("Click Tab 4")
		move_child(get_node("Page4"), 3)
