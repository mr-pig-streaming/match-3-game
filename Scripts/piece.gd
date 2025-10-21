class_name Piece
extends Node2D

@export var colour: String
@export var matched: bool
@export var durability: int
@export var fixed: bool = false
var grid_x: int
var grid_y: int

# Called when the node enters the scene tree for the first time.
func _ready():
	matched = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_to(location):
	var tween: Tween = create_tween()
	tween.tween_property(self,"position",location, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.play();

func move_to_bag():
	var tween: Tween = create_tween()
	tween.tween_property(self, "rotation", TAU, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.play();

func matches(other_colour: String):
	# Used for exclusion zones
	if ("X" in colour) || ("X" in other_colour):
		return false
	return (colour in other_colour) || (other_colour in colour)

func clone():
	pass # Must be implemented in children
