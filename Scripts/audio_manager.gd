class_name AudioManager
extends Node2D

var click_playing: bool = false
var puzzle_music_playing: bool = false
var market_music_playing: bool = false
var menu_music_playing: bool = false
var swish_playing: bool = false
var match_playing: bool = false
var powerup_playing: bool = false
var powerdown_playing: bool = false
var crack_playing: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func play_click():
	if (!click_playing):
		click_playing = true
		get_node("ClickPlayer").play()
		get_node("ClickPlayer").finished.connect(end_click)

func end_click():
	click_playing = false

func play_puzzle_music():
	if (!puzzle_music_playing):
		puzzle_music_playing = true
		get_node("PuzzleMusicPlayer").play()

func end_puzzle_music():
	get_node("PuzzleMusicPlayer").stop()
	puzzle_music_playing = false

func play_market_music():
	if (!market_music_playing):
		market_music_playing = true
		get_node("BlackMarketMusicPlayer").play()

func end_market_music():
	get_node("BlackMarketMusicPlayer").stop()
	market_music_playing = false

func play_menu_music():
	if (!menu_music_playing):
		menu_music_playing = true
		get_node("MenuMusicPlayer").play()

func end_menu_music():
	get_node("MenuMusicPlayer").stop()
	menu_music_playing = false

func play_swish():
	if (!swish_playing):
		swish_playing = true
		get_node("SwishPlayer").play()
		get_node("SwishPlayer").finished.connect(end_swish)

func end_swish():
	swish_playing = false

func play_match(pitch_shift):
	match_playing = true
	get_node("MatchPlayer").pitch_scale = pitch_shift
	get_node("MatchPlayer").play()
	get_node("MatchPlayer").finished.connect(end_match)

func end_match():
	match_playing = false

func play_powerup():
	if (!powerup_playing):
		powerup_playing = true
		get_node("PowerUpPlayer").play()
		get_node("PowerUpPlayer").finished.connect(end_powerup)

func end_powerup():
	powerup_playing = false

func play_powerdown():
	if (!powerdown_playing):
		powerdown_playing = true
		get_node("PowerDownPlayer").play()
		get_node("PowerDownPlayer").finished.connect(end_powerdown)

func end_powerdown():
	powerdown_playing = false

func play_crack():
	if (!crack_playing):
		crack_playing = true
		get_node("CrackPlayer").play()
		get_node("CrackPlayer").finished.connect(end_crack)

func end_crack():
	crack_playing = false
