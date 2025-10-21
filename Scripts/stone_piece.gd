class_name StonePiece
extends Piece

@export var broken: bool
@export var effect: String
@export var base_durability: int

# Called when the node enters the scene tree for the first time.
func _ready():
	broken = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func crack_piece():
	if (durability >= base_durability):
		get_node("Crack_Timer").start()
	if (durability == 0):
		broken = true

func harden_piece():
	print("Hardening piece...")
	get_node("HardenTimer").start()

func _on_timer_timeout():
	if (durability > 1):
		get_node("Shield").visible = true
	else:
		get_node("Shield").visible = false
	get_node("/root/BaseScene/AudioManager").play_crack()
	if (durability == 1):
		get_node("Sprite2D").texture = load("res://Art/Stone_cracked.png")


func _on_harden_timer_timeout():
	if (durability > base_durability):
		get_node("Shield").visible = true
	else:
		get_node("Shield").visible = false
	if (durability == 2):
		get_node("Sprite2D").texture = load("res://Art/Stone.png")
	if (durability == 1):
		get_node("Sprite2D").texture = load("res://Art/Stone_cracked.png")

func clone():
	var copy = preload("res://Scenes/stone_piece.tscn").instantiate()
	copy.colour = colour
	copy.durability = durability
	copy.effect = effect
	copy.base_durability = base_durability
	copy.get_node("Sprite2D").texture = get_node("Sprite2D").texture
	copy.get_node("Shield").visible = get_node("Shield").visible
	return copy
