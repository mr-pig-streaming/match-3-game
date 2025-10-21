extends Piece


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func rotate_piece():
	var tween: Tween = create_tween()
	var degrees = rotation_degrees
	tween.tween_property(self,"rotation_degrees",degrees - 90, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.play();

func clone():
	var copy = preload("res://Scenes/rotate_piece.tscn").instantiate()
	copy.colour = colour
	copy.position = position
	copy.rotation_degrees = rotation_degrees
	copy.fixed = fixed
	return copy
