extends StonePiece

# Called when the node enters the scene tree for the first time.
func _ready():
	broken = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func crack_piece():
	if (durability >= 1):
		get_node("Crack_Timer").start()
	if (durability == 0):
		broken = true

func harden_piece():
	print("Hardening piece...")
	print("Durability: " + str(durability))
	get_node("HardenTimer").start()

func _on_timer_timeout():
	if (durability > base_durability):
		get_node("Shield").visible = true
	else:
		get_node("Shield").visible = false
	get_node("/root/BaseScene/AudioManager").play_crack()
	if (durability == 1):
		get_node("Sprite2D").texture = load("res://Art/Sand.png")


func _on_harden_timer_timeout():
	if (durability > base_durability):
		get_node("Shield").visible = true
	else:
		get_node("Shield").visible = false

func clone():
	var copy = preload("res://Scenes/sand_piece.tscn").instantiate()
	copy.colour = colour
	copy.durability = durability
	copy.effect = effect
	copy.base_durability = base_durability
	copy.get_node("Sprite2D").texture = get_node("Sprite2D").texture
	copy.get_node("Shield").visible = get_node("Shield").visible
	return copy
