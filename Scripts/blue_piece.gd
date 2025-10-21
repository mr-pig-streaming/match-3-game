class_name BluePiece
extends Piece


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func clone():
	var copy = preload("res://Scenes/blue_piece.tscn").instantiate()
	copy.colour = colour
	copy.position = position
	return copy
