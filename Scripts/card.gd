class_name Card
extends Node2D

var card_name: String = ""
var card_held: bool
var original_position: Vector2
var mouse_offset: Vector2
var card_active: bool = false
var durability: int
var cost: int
var type: String = ""

static func new_card(_card_name: String, _durability: int, _cost: int, _type: String = ""):
	var card = load("res://Scenes/card.tscn").instantiate()
	card.update_name(_card_name)
	card.durability = _durability
	card.cost = _cost
	card.type = _type
	return card

# Called when the node enters the scene tree for the first time.
func _ready():
	card_held = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _to_string():
	var result = card_name + "," + str(durability) + "," + str(cost) + "," + type + "," + str(position) + "," + str(card_active)
	return result

static func card_from_string(json_string: String):
	var json_elements = json_string.split(",")
	var card = new_card(json_elements[0], int(json_elements[1]), int(json_elements[2]), json_elements[3])
	if (json_elements[6] == "true"):
		card.card_active = true
	else:
		card.card_active = false
	var x = json_elements[4].right(-1)
	var y = json_elements[5].left(-1)
	card.position = Vector2(int(x), int(y))
	return card

func update_name(text):
	card_name = text
	get_node("Area2D").get_child(0).get_child(0).text = text

func _input(event):
	if (card_held):
		if (event is InputEventMouseMotion):
			position = get_global_mouse_position() + mouse_offset

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			card_held = true
			get_parent().set_held_card(self)
			original_position = position
			mouse_offset = get_global_mouse_position() - position
		elif event.is_released():
			get_parent().drop_card()
			card_held = false
			get_parent().set_held_card(null)

func return_to_original():
	var tween: Tween = create_tween()
	tween.tween_property(self,"position",original_position, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.play();
