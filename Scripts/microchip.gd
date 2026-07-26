class_name Microchip
extends Node2D

var cost: int = 0
var effect: String = ""
var base_duration: float = 0.0
var duration: float = 0.0
var active: bool = false

static func new_microchip(_cost: int, _effect: String, _duration: float, _base_duration: float, _active: bool):
	var chip = load("res://Scenes/microchip.tscn").instantiate()
	chip.cost = _cost
	chip.effect = _effect
	chip.duration = _duration
	chip.base_duration = _base_duration
	chip.active = _active
	return chip

func reduce_duration(interval: float):
	duration = duration - interval
	if duration <= 0:
		active = false

func activate(energy: int):
	if energy >= cost:
		active = true
		duration = base_duration
		return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
