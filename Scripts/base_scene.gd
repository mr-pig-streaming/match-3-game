extends Node2D

enum GAME_STATE {MENU, IN_GAME, COMPLETE}

var game_state
var save_state = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	game_state = GAME_STATE.MENU
	var menu = preload("res://Scenes/menu.tscn").instantiate()
	get_node("/root/BaseScene/AudioManager").play_menu_music()
	add_child(menu)
	menu.position = Vector2(500, 300)
	menu.get_node("New Game").pressed.connect(new_game)
	menu.get_node("QuitGameButton").pressed.connect(quit_game)
	menu.get_node("LoadGameButton").pressed.connect(load_game)
	pass # Replace with function body.

func quit_game():
	get_tree().quit()

func save_game():
	var save_string = save_state + "\n" + get_node("Globals").globals_to_json()
	print(save_string)
	var file = FileAccess.open("test_save.txt", FileAccess.WRITE)
	file.store_string(save_string)
	file.close()

func load_game():
	print("Loading game")
	var file = FileAccess.open("test_save.txt", FileAccess.READ)
	var content = file.get_as_text()
	print(content)
	var save_lines = content.split("\n")
	if save_lines[0] == "IN_RUN":
		load_gameboard(save_lines.slice(1, 12))
	if save_lines[0] == "BLACK_MARKET":
		load_blackmarket(save_lines.slice(1,8))

func load_gameboard(save_lines):
	get_node("AudioManager").play_click()
	print("Load Game")
	var tween: Tween = create_tween()
	tween.tween_property(get_node("ShutterSprite"),"position", Vector2(640, 360), 0.3).set_ease(Tween.EASE_OUT)
	tween.play()
	await get_tree().create_timer(1.5).timeout
	
	get_node("Menu").queue_free()
	var game_board: GameBoard = preload("res://Scenes/game_board.tscn").instantiate()
	get_node("Globals").json_to_globals(save_lines.slice(5, 11))
	game_board.name = "gameboard"
	add_child(game_board)
	game_board.setup_from_file(save_lines)
	game_board.set_max_turns(get_node("Globals").max_turns)
	game_board.game_finished.connect(end_game)
	get_node("/root/BaseScene/AudioManager").end_menu_music()
	get_node("/root/BaseScene/AudioManager").play_puzzle_music()
	game_state = GAME_STATE.IN_GAME
	
	var tween2: Tween = create_tween()
	tween2.tween_property(get_node("ShutterSprite"),"position", Vector2(640, -640), 0.3).set_ease(Tween.EASE_OUT)
	tween2.play()

func load_blackmarket(save_lines):
	var tween: Tween = create_tween()
	tween.tween_property(get_node("ShutterSprite"),"position", Vector2(640, 360), 0.3).set_ease(Tween.EASE_OUT)
	tween.play()
	await get_tree().create_timer(1.5).timeout
	
	get_node("Menu").queue_free()
	get_node("/root/BaseScene/AudioManager").end_menu_music()
	get_node("Globals").json_to_globals(save_lines.slice(1, 7))
	var market: BlackMarket = preload("res://Scenes/black_market.tscn").instantiate()
	market.set_num_diamonds(int(save_lines[0]))
	add_child(market)
	get_node("/root/BaseScene/AudioManager").play_market_music()
	market.get_node("NewRunButton").pressed.connect(new_run)
	
	var tween2: Tween = create_tween()
	tween2.tween_property(get_node("ShutterSprite"),"position", Vector2(640, -640), 0.3).set_ease(Tween.EASE_OUT)
	tween2.play()

func new_game():
	get_node("AudioManager").play_click()
	print("New Game")
	var tween: Tween = create_tween()
	tween.tween_property(get_node("ShutterSprite"),"position", Vector2(640, 360), 0.3).set_ease(Tween.EASE_OUT)
	tween.play()
	await get_tree().create_timer(1.5).timeout
	
	get_node("Menu").queue_free()
	var game_board: GameBoard = preload("res://Scenes/game_board.tscn").instantiate()
	game_board.name = "gameboard"
	add_child(game_board)
	game_board.setup_from_scratch()
	game_board.set_num_turns(get_node("Globals").max_turns)
	game_board.set_max_turns(get_node("Globals").max_turns)
	game_board.game_finished.connect(end_game)
	get_node("/root/BaseScene/AudioManager").end_menu_music()
	get_node("/root/BaseScene/AudioManager").play_puzzle_music()
	game_state = GAME_STATE.IN_GAME
	
	var tween2: Tween = create_tween()
	tween2.tween_property(get_node("ShutterSprite"),"position", Vector2(640, -640), 0.3).set_ease(Tween.EASE_OUT)
	tween2.play()
	
	pass

func end_game(game_state):
	print(game_state)
	if (game_state == "LOSE"):
		var tween: Tween = create_tween()
		tween.tween_property(get_node("ShutterSprite"),"position", Vector2(640, 360), 0.3).set_ease(Tween.EASE_OUT)
		tween.play()
		await get_tree().create_timer(1.5).timeout
		
		get_node("/root/BaseScene/AudioManager").end_puzzle_music()
		var diamonds = get_node("gameboard").diamonds
		get_node("gameboard").queue_free()
		# Go to the black market between runs
		var market: BlackMarket = preload("res://Scenes/black_market.tscn").instantiate()
		market.set_num_diamonds(diamonds)
		add_child(market)
		get_node("/root/BaseScene/AudioManager").play_market_music()
		market.get_node("NewRunButton").pressed.connect(new_run)
		
		var tween2: Tween = create_tween()
		tween2.tween_property(get_node("ShutterSprite"),"position", Vector2(640, -640), 0.3).set_ease(Tween.EASE_OUT)
		tween2.play()
	if (game_state == "WIN"):
		var tween: Tween = create_tween()
		tween.tween_property(get_node("ShutterSprite"),"position", Vector2(640, 360), 0.3).set_ease(Tween.EASE_OUT)
		tween.play()
		await get_tree().create_timer(1.5).timeout
		
		get_node("/root/BaseScene/AudioManager").end_puzzle_music()
		get_node("gameboard").queue_free()
		var message: Label = Label.new()
		message.text = "You won! Huzzah!"
		message.position = Vector2(600, 350)
		add_child(message)
		
		var tween2: Tween = create_tween()
		tween2.tween_property(get_node("ShutterSprite"),"position", Vector2(640, -640), 0.3).set_ease(Tween.EASE_OUT)
		tween2.play()

func new_run():
	get_node("AudioManager").play_click()
	print("New Run")
	var tween: Tween = create_tween()
	tween.tween_property(get_node("ShutterSprite"),"position", Vector2(640, 360), 0.3).set_ease(Tween.EASE_OUT)
	tween.play()
	await get_tree().create_timer(1.5).timeout
	
	get_node("BlackMarket").queue_free()
	get_node("/root/BaseScene/AudioManager").end_market_music()
	var game_board: GameBoard = preload("res://Scenes/game_board.tscn").instantiate()
	add_child(game_board)
	game_board.setup_from_scratch()
	game_board.set_num_turns(get_node("Globals").max_turns)
	game_board.set_max_turns(get_node("Globals").max_turns)
	game_board.game_finished.connect(end_game)
	game_board.name = "gameboard"
	get_node("/root/BaseScene/AudioManager").play_puzzle_music()
	game_state = GAME_STATE.IN_GAME
	
	var tween2: Tween = create_tween()
	tween2.tween_property(get_node("ShutterSprite"),"position", Vector2(640, -640), 0.3).set_ease(Tween.EASE_OUT)
	tween2.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
