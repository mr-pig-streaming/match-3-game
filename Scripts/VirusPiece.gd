class_name VirusPiece
extends Piece

signal time_expired
@export var life: int
@export var broken: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_life(_life: int):
	life = _life
	get_node("TimerLabel").text = str(life)

func countdown():
	life -= 1
	get_node("TimerLabel").text = str(life)
	if (life == 0):
		time_expired.emit()

func crack_piece():
	if (durability <= 0):
		broken = true

func clone():
	var copy = preload("res://Scenes/virus_piece.tscn").instantiate()
	copy.colour = colour
	copy.durability = durability
	copy.update_life(life)
	return copy
