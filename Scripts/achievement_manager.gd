class_name AchievementManager
extends Node2D

# the list of all achievements - name, description, if it is unlocked
var achievements = [
	["Test", "Test Description", false],
	["Combo Master", "Achieve a combo of 10 or more pieces", false]
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func unlock_achievement(name):
	for a in achievements:
		if (a[0] == name && a[2] == false):
			a[2] = true
			# TBD: Unlock with the Steam SDK
			get_node("Sprite2D/TitleLabel").push_bold()
			get_node("Sprite2D/TitleLabel").push_font_size(18)
			get_node("Sprite2D/TitleLabel").append_text("[center]" + a[0] + "[/center]")
			get_node("Sprite2D/DescriptionLabel").append_text("[center]" + a[1] + "[/center]")
			var tween = create_tween()
			tween.tween_property(get_node("Sprite2D"), "scale", Vector2(1.0, 1.0), 0.7).set_trans(Tween.TRANS_ELASTIC)
			tween.play()
			get_node("/root/BaseScene/AudioManager").play_achievement()
			await get_tree().create_timer(5.0).timeout
			var tween2 = create_tween()
			tween2.tween_property(get_node("Sprite2D"), "scale", Vector2(0.0, 0.0), 0.7).set_trans(Tween.TRANS_ELASTIC)
			tween2.play()
