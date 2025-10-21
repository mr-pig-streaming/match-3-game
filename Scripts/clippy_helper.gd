extends "res://Scripts/helper.gd"

var lines = [
	"Hi! I'm Clippy, your helpful corporate assistant! Ask me anything!",
	"Feel free to make suggestions! We'll feel free to ignore you and reconsider your employment",
	"Did you know that most employees finish their endenture after only 1472.6 years? Good luck!"
]

var active_lines = []
var numbers = range(5)

# Called when the node enters the scene tree for the first time.
func _ready():
	numbers.shuffle()
	active_lines = lines.duplicate()
	active_lines.shuffle()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func act():
	if numbers[0] == 0:
		var line = active_lines.pop_front()
		get_node("OutputLabel").clear()
		get_node("OutputLabel").push_color(Color.WHITE)
		get_node("OutputLabel").push_outline_color(Color.BLACK)
		get_node("OutputLabel").push_outline_size(4)
		get_node("OutputLabel").push_font_size(24)
		get_node("OutputLabel").append_text(line)
		if (active_lines.is_empty()):
			active_lines = lines.duplicate()
			active_lines.shuffle()
	numbers.pop_front()
	if numbers.is_empty():
		numbers = range(0, 5)
		numbers.shuffle()
