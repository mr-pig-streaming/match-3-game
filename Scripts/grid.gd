class_name Grid
extends Node2D

signal end_turn

var x_offset = 96
var y_offset = 112
var sprite_width = 64
var sprite_height = 64
var width = 8
var height = 9

var first_touch: Vector2
var final_touch: Vector2
var moved: bool = false
var refill_caused_by_virus = false

var total_matched: int = 0
var round_matched: int = 0
var active: bool = true
var challenge_level: bool = false

var perk_multiplier = 1.0
var temp_multiplier = 1.0

var score_multiplier = [0, 1, 1, 1, 1.25, 1.6, 2.17, 3, 4.25, 6.11, 8.9, 13.09, 19.42]

var squares_to_drop = []

var active_effects = []

var debuff_effects = []

var match_type

enum MATCH_TYPE {STANDARD, DIAGONAL, QUEEN, TETRIS}

# Every Tetris piece, in each orientation
var TETRIS_O = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0), Vector2(1, 1)]
var TETRIS_T_0 = [Vector2(0, 0), Vector2(-1 ,0), Vector2(1, 0), Vector2(0, 1)]
var TETRIS_T_90 = [Vector2(0, 0), Vector2(0, -1), Vector2(0, 1), Vector2(1, 0)]
var TETRIS_T_180 = [Vector2(0, 0), Vector2(-1 ,0), Vector2(1, 0), Vector2(0, -1)]
var TETRIS_T_270 = [Vector2(0, 0), Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0)]
var TETRIS_I_0 = [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(3, 0)]
var TETRIS_I_90 = [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(0, 3)]
var TETRIS_S_0 = [Vector2(0, 0), Vector2(1, 0), Vector2(1, -1), Vector2(2, -1)]
var TETRIS_S_90 = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 2)]
var TETRIS_Z_0 = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(2, 1)]
var TETRIS_Z_90 = [Vector2(0, 0), Vector2(0, 1), Vector2(-1, 1), Vector2(-1, 2)]
var TETRIS_J_0 = [Vector2(0, 0), Vector2(1, 0), Vector2(1, -1), Vector2(1, -2)]
var TETRIS_J_90 = [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(2, 1)]
var TETRIS_J_180 = [Vector2(0, 0), Vector2(0, -1), Vector2(0, -2), Vector2(1, -2)]
var TETRIS_J_270 = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(2, 1)]
var TETRIS_L_0 = [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(1, 2)]
var TETRIS_L_90 = [Vector2(0, 0), Vector2(1, 0), Vector2(2, 0), Vector2(2, -1)]
var TETRIS_L_180 = [Vector2(0, 0), Vector2(0, 1), Vector2(0, 2), Vector2(1, 2)]
var TETRIS_L_270 = [Vector2(0, 0), Vector2(0, -1), Vector2(1, -1), Vector2(2, -1)]

var tetris_pieces = [TETRIS_O, TETRIS_T_0, TETRIS_T_90, TETRIS_T_180, TETRIS_T_270, TETRIS_I_0,
					 TETRIS_I_90, TETRIS_S_0, TETRIS_S_90, TETRIS_Z_0, TETRIS_Z_90,
					 TETRIS_J_0, TETRIS_J_90, TETRIS_J_180, TETRIS_J_270,
					 TETRIS_L_0, TETRIS_L_90, TETRIS_L_180, TETRIS_L_270]

# Indicates if we need to collapse columns after a match
var collapse_needed: bool
@onready var collapse_timer = $Collapse_Timer
@onready var clear_timer = $Clear_Timer
@onready var refill_timer = $Refill_Timer

var possible_pieces = [
	preload("res://Scenes/blue_piece.tscn"),
	preload("res://Scenes/green_piece.tscn"),
	preload("res://Scenes/orange_piece.tscn"),
	preload("res://Scenes/purple_piece.tscn"),
	preload("res://Scenes/red_piece.tscn"),
	preload("res://Scenes/yellow_piece.tscn")
]

var colourblind_pieces = [
	preload("res://Scenes/blue_piece.tscn"),
	preload("res://Scenes/orange_piece.tscn"),
	preload("res://Scenes/purple_piece.tscn"),
	preload("res://Scenes/red_piece.tscn"),
	preload("res://Scenes/yellow_piece.tscn"),
]

var null_piece = preload("res://Scenes/null_piece.tscn")
var stone_piece = preload("res://Scenes/stone_piece.tscn")
var sand_piece = preload("res://Scenes/sand_piece.tscn")
var metal_piece = preload("res://Scenes/metal_piece.tscn")
var virus_piece = preload("res://Scenes/virus_piece.tscn")
var gold_piece = preload("res://Scenes/gold_piece.tscn")
var diamond_piece = preload("res://Scenes/diamond_piece.tscn")
var rainbow_piece = preload("res://Scenes/rainbow_piece.tscn")
var rotate_piece = preload("res://Scenes/rotate_piece.tscn")

var special_pieces = [sand_piece, stone_piece, metal_piece]
var hard_pieces = [sand_piece, stone_piece, metal_piece]
var all_indexes = range(width * height)
var rotate_squares = [
	Vector2(2, 1),
	Vector2(5, 1),
	Vector2(1, 4),
	Vector2(6, 4),
	Vector2(2, 7),
	Vector2(5, 7)
]

var all_pieces = []

var num_specials = 0
var special_indexes = []
var range_specials = 0
var special_chance: float = 0.0
var num_debuffs: int = 0

var exclusions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	total_matched = 0
	round_matched = 0
	all_indexes = range(width, width * (height - 1))
	var left_edge = range(width, width * (height - 1), width)
	var right_edge = range(width * 2 - 1, width * (height - 1), width)
	for l in left_edge:
		all_indexes.erase(l)
	for r in right_edge:
		all_indexes.erase(r)
	match_type = MATCH_TYPE.STANDARD
	all_pieces = setup_array()
	setup_pieces()
	challenge_level = false

func setup_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null_piece.instantiate());
	return array;

func clear_board():
	for i in width:
		for j in height:
			if (all_pieces[i][j] != null):
				all_pieces[i][j].queue_free()
	all_pieces = setup_array()

func remove_setup_matches():
	var refill_pieces = possible_pieces
	if (active_effects.has("COLOURBLIND")):
		refill_pieces = colourblind_pieces
	var k = randi_range(0, refill_pieces.size() - 1)
	for i in width:
		for j in height:
			if (all_pieces[i][j].matched):
				var piece: Piece = refill_pieces[k].instantiate()
				while (all_pieces[i][j].matches(piece.colour)):
					piece.queue_free()
					k = (k + 1) % (refill_pieces.size())
					piece = refill_pieces[k].instantiate()
				all_pieces[i][j].queue_free()
				all_pieces[i][j] = piece
				all_pieces[i][j].matched = false
				add_child(all_pieces[i][j])
				move_child(all_pieces[i][j], 0)
				all_pieces[i][j].position = grid_to_pixel(i, j)
				k = (k + 1) % (refill_pieces.size())

func setup_pieces():
	remove_exclusion_zones()
	for i in width:
		for j in height:
			var k = randi_range(0, possible_pieces.size() - 1)
			var piece: Piece = possible_pieces[k].instantiate()
			while (match_at(i, j, piece.colour)):
				print("Match found, replacing...")
				piece.queue_free()
				k = (k + 1) % (possible_pieces.size())
				piece = possible_pieces[k].instantiate()
			all_pieces[i][j] = piece
			add_child(piece)
			move_child(piece, 0)
			piece.position = grid_to_pixel(i, j)
			if (piece is VirusPiece):
				var lifetime = randi_range(2, 4)
				piece.update_life(lifetime)
				piece.time_expired.connect(increment_debuff)
	if (active_effects.has("COLOURBLIND")):
		recolour_green_to_red()
		print("Recoloured...")
	while (check_for_matches()):
		remove_setup_matches()
	#unmatch_all()
	#add_exclusion_zones()
	total_matched = 0
	round_matched = 0

func add_exclusion_zones():
	for i in range(5):
		#Generate a random location, make it an exclusion zone
		var x = randi_range(0, width - 1)
		var y = randi_range(0, height - 1)
		var exclusion_pos = grid_to_pixel(x, y)
		var exclusion = preload("res://Scenes/exclusion_zone.tscn").instantiate()
		exclusion.position = exclusion_pos
		add_child(exclusion)
		exclusions.append(exclusion)
	recolour_for_exclusion()

func remove_exclusion_zones():
	for e in exclusions:
		remove_child(e)
	exclusions = []
	recolour_for_exclusion()

func recolour_for_exclusion():
	for x in width:
		for y in height:
			if "X" in all_pieces[x][y].colour:
				all_pieces[x][y].colour = all_pieces[x][y].colour.substr(1)
	for e in exclusions:
		var grid_position = pixel_to_grid(e.position.x, e.position.y)
		all_pieces[grid_position.x][grid_position.y].colour = "X" + all_pieces[grid_position.x][grid_position.y].colour

func shuffle():
	var indexes = range(72)
	var pieces_copy = copy_grid()
	var fixed_positions = []
	for x in range(width):
		for y in range(height):
			if (all_pieces[x][y].fixed):
				var index = y * width + x
				indexes.erase(index)
				fixed_positions.append(Vector2(x, y))
	indexes.shuffle()
	# Insert the fixed points back into their correct locations
	for f in fixed_positions:
		var index = int(f.y * width + f.x)
		indexes.insert(index, index)
	clear_board()
	# Copy each item from the copy grid to  a new location in all_pieces, then move them
	for i in range(72):
		var original_x = i % width
		var original_y = i / width
		#if (fixed_positions.has(Vector2(original_x, original_y))):
		#	all_pieces[original_x][original_y] = pieces_copy[original_x][original_y]
		#	continue
		var new_x = indexes[i] % width
		var new_y = indexes[i] / width
		all_pieces[new_x][new_y] = pieces_copy[original_x][original_y]
		add_child(all_pieces[new_x][new_y])
		move_child(all_pieces[new_x][new_y], 0)
		all_pieces[new_x][new_y].move_to(grid_to_pixel(new_x, new_y))
	recolour_for_exclusion()

func copy_grid():
	var empty = setup_array()
	for x in width:
		for y in height:
			empty[x][y] = all_pieces[x][y].clone()
	return empty

func increment_debuff():
	num_debuffs += 1

func unmatch_all():
	for i in width:
		for j in height:
			all_pieces[i][j].matched = false

# Determines if there is a match at the given position
func match_at(x, y, colour):
	# Stone and virus pieces don't match
	if (colour == "Stone" || colour == "Virus" || colour == "XStone" || colour == "XVirus"):
		return false
	# If we've already marked this as matched for any reason, then return true
	if (all_pieces[x][y].matched):
		return true
	if (match_type == MATCH_TYPE.STANDARD):
		return standard_match(x, y, colour)
	elif (match_type == MATCH_TYPE.DIAGONAL):
		return diagonal_match(x, y, colour)
	elif (match_type == MATCH_TYPE.QUEEN):
		return standard_match(x, y, colour) || diagonal_match(x, y, colour)
	elif (match_type == MATCH_TYPE.TETRIS):
		return tetris_match(x, y, colour)

func diagonal_match(x, y, colour):
	if (colour == null):
		return false
	# 6 possibilites for a match
	# bottom in a positive diagonal
	if (x < width - 2 && y < height - 2 && all_pieces[x + 1][y + 1].matches(colour) && all_pieces[x + 2][y + 2].matches(colour) && all_pieces[x + 1][y + 1].matches(all_pieces[x + 2][y + 2].colour)):
		return true
	# non-glass middle in a positive diagonal
	if (x < width - 1 && x >= 1 && y < height - 1 && y >= 1 && all_pieces[x - 1][y - 1].matches(colour) && all_pieces[x + 1][y + 1].matches(colour) && all_pieces[x - 1][y - 1].matches(all_pieces[x + 1][y + 1].colour)):
		return true
	# top in a positive diagonal
	if (x >= 2 && y >= 2 && all_pieces[x - 1][y - 1].matches(colour) && all_pieces[x - 2][y - 2].matches(colour) && all_pieces[x - 2][y - 2].matches(all_pieces[x - 1][y - 1].colour)):
		return true
	# bottom in a negative diagonal
	if (x >= 2 && y < height - 2 && all_pieces[x - 1][y + 1].matches(colour) && all_pieces[x - 2][y + 2].matches(colour) && all_pieces[x - 2][y + 2].matches(all_pieces[x - 1][y + 1].colour)):
		return true
	# non-glass middle in a negative diagonal
	if (x < width - 1 && x >= 1 && y < height - 1 && y >= 1 && all_pieces[x - 1][y + 1].matches(colour) && all_pieces[x + 1][y - 1].matches(colour) && all_pieces[x - 1][y + 1].matches(all_pieces[x + 1][y - 1].colour)):
		return true
	# top in a negative diagonal
	if (x < width - 2 && y >= 2 && all_pieces[x + 1][y - 1].matches(colour) && all_pieces[x + 2][y - 2].matches(colour) && all_pieces[x + 1][y - 1].matches(all_pieces[x + 2][y - 2].colour)):
		return true
	return false

func standard_match(x, y, colour):
	return horizontal_match(x, y, colour) || vertical_match(x, y, colour)

func horizontal_match(x, y, colour):
	if (colour == null):
		return false
	# left block in a horizontal
	if (x < width - 2 && all_pieces[x + 1][y].matches(colour) && all_pieces[x + 2][y].matches(colour) && all_pieces[x + 1][y].matches(all_pieces[x + 2][y].colour)):
		return true
	# non-glass middle block in a horizontal
	if (x < width - 1 && x >= 1 && all_pieces[x - 1][y].matches(colour) && all_pieces[x + 1][y].matches(colour) && all_pieces[x - 1][y].matches(all_pieces[x + 1][y].colour)):
		return true
	# right block in a horizontal
	if (x >= 2 && all_pieces[x - 1][y].matches(colour) && all_pieces[x - 2][y].matches(colour) && all_pieces[x - 1][y].matches(all_pieces[x - 2][y].colour)):
		return true
	return false

func vertical_match(x, y, colour):
	if (colour == null):
		return false
	# bottom block in a vertical
	if (y < height - 2 && all_pieces[x][y + 1].matches(colour) && all_pieces[x][y + 2].matches(colour) && all_pieces[x][y + 1].matches(all_pieces[x][y + 2].colour)):
		return true
	# non-glass middle block in a vertical
	if (y < height - 1 && y >= 1 && all_pieces[x][y - 1].matches(colour) && all_pieces[x][y + 1].matches(colour) && all_pieces[x][y - 1].matches(all_pieces[x][y + 1].colour)):
		return true
	# top block in a vertical
	if (y >= 2 && all_pieces[x][y - 1].matches(colour) && all_pieces[x][y - 2].matches(colour) && all_pieces[x][y - 2].matches(all_pieces[x][y - 1].colour)):
		return true
	return false

func tetris_match(x, y, colour):
	# For each shape, shift it to the x & y...
	for shape in tetris_pieces:
		var shifted_shape = []
		for square in shape:
			shifted_shape.append(Vector2(square.x + x, square.y + y))
		# If any square is outside the grid, this position is invalid so don't check it
		if contains_invalid(shifted_shape):
			continue
		# Make sure all if the squares are the same colour
		var colours_match = true
		for square in shifted_shape:
			if (!all_pieces[square.x][square.y].matches(colour) || all_pieces[square.x][square.y].matched):
				colours_match = false
		if (colours_match == false):
			# This shape has at least one non-match
			continue
		# If they all match, then we have a match - still need to figure out how to handle overlaps
		for square in shifted_shape:
			all_pieces[square.x][square.y].matched = true
		return true
	return false

func contains_invalid(positions):
	for v: Vector2 in positions:
		if (v.x < 0 || v.x >= width || v.y < 0 || v.y >= height):
			return true
	return false

func get_neighbours(x, y):
	var neighbours = []
	if (match_type == MATCH_TYPE.STANDARD || match_type == MATCH_TYPE.TETRIS || match_type == MATCH_TYPE.QUEEN):
		if (x > 0):
			neighbours.append(Vector2(x - 1, y))
		if (x < width - 1):
			neighbours.append(Vector2(x + 1, y))
		if (y > 0):
			neighbours.append(Vector2(x, y - 1))
		if (y < height - 1):
			neighbours.append(Vector2(x, y + 1))
	if (match_type == MATCH_TYPE.DIAGONAL  || match_type == MATCH_TYPE.QUEEN):
		if (x > 0 && y > 0):
			neighbours.append(Vector2(x - 1, y - 1))
		if (x > 0 && y < height - 1):
			neighbours.append(Vector2(x - 1, y + 1))
		if (x < width - 1 && y > 0):
			neighbours.append(Vector2(x + 1, y - 1))
		if (x < width - 1 && y < height - 1):
			neighbours.append(Vector2(x + 1, y + 1))
	return neighbours

func grid_to_pixel(x, y):
	var pixel_x = x_offset + (x * sprite_width)
	var pixel_y = y_offset + (y * sprite_height)
	return Vector2(pixel_x, pixel_y)

func pixel_to_grid(pixel_x, pixel_y):
	var grid_x = round((pixel_x - x_offset) / sprite_width);
	var grid_y = round((pixel_y - y_offset) / sprite_height);
	return Vector2(grid_x, grid_y);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func move_pieces(position1, position2):
	var direction: Vector2 = position2 - position1
	if (direction.length() == 1 || active_effects.has("TRANSLOCATOR")):
		get_node("/root/BaseScene/AudioManager").play_swish()
		if (!active_effects.has("TIME_STOP")):
			get_parent().reduce_turns(1)
		var piece1 = all_pieces[position1.x][position1.y]
		var piece2 = all_pieces[position2.x][position2.y]
		piece1.move_to(grid_to_pixel(position2.x, position2.y))
		piece2.move_to(grid_to_pixel(position1.x, position1.y))
		all_pieces[position1.x][position1.y] = piece2
		all_pieces[position2.x][position2.y] = piece1
		recolour_for_exclusion()
		rotate_blocks()
		if (check_for_matches()):
			active = false
			clear_timer.start()
		else:
			if (challenge_level):
				get_parent().check_win_challenge(count_challenge_blocks())
			else:
				get_parent().check_win(total_matched)
			countdown_viruses()
			end_turn.emit(moved)
	recolour_for_exclusion()

func recheck_matches():
	if (check_for_matches()):
		active = false
		clear_timer.start()
	else:
		countdown_viruses()
		end_turn.emit(moved)

func clear_matches():
	for i in width:
		for j in height:
			if (all_pieces[i][j].matched):
				all_pieces[i][j].move_to_bag()
				#all_pieces[i][j].queue_free()
				all_pieces[i][j] = null_piece.instantiate()
				# Check the row above - if it is not empty, then we need to collapse the columns
				if (j > 0 && all_pieces[i][j - 1].colour != "null"):
					collapse_needed = true
				# If any neighbour is stone or virus, reduce its durability and crack it
				var neighbours = get_neighbours(i, j)
				for n in neighbours:
					if (all_pieces[n.x][n.y].colour == "Stone" || all_pieces[n.x][n.y].colour == "Virus" || all_pieces[n.x][n.y].colour == "XStone" || all_pieces[n.x][n.y].colour == "XVirus"):
						all_pieces[n.x][n.y].durability -= 1
						all_pieces[n.x][n.y].crack_piece()
	if (collapse_needed):
		collapse_timer.start()
	else:
		refill_timer.start()

func clear_broken():
	for i in width:
		for j in height:
			if ((all_pieces[i][j].colour == "Stone" || all_pieces[i][j].colour == "Virus" || all_pieces[i][j].colour == "XStone" || all_pieces[i][j].colour == "XVirus") && all_pieces[i][j].broken):
				all_pieces[i][j].move_to_bag()
				# Check the effect to handle gold and diamond pieces
				if ((all_pieces[i][j].colour == "Stone" || all_pieces[i][j].colour == "XStone") && all_pieces[i][j].effect == "GOLD"):
					print("Gold piece broken...")
					temp_multiplier *= 2
				if ((all_pieces[i][j].colour == "Stone" || all_pieces[i][j].colour == "XStone") && all_pieces[i][j].effect == "DIAMOND"):
					print("Diamond piece broken...")
					get_parent().add_diamonds(5)
				#all_pieces[i][j].queue_free()
				all_pieces[i][j] = null_piece.instantiate()
				# Check the row above - if it is not empty, then we need to collapse the columns
				if (j > 0 && all_pieces[i][j - 1].colour != "null"):
					collapse_needed = true

func check_for_matches():
	if (active_effects.has("TIME_STOP")):
		return false
	var matches_found = false
	if (debuff_effects.has("MATCH_TYPE_3") && round_matched >= 3):
		return matches_found
	for i in width:
		for j in height:
			if (all_pieces[i][j].colour != "null" && match_at(i, j, all_pieces[i][j].colour)):
				all_pieces[i][j].matched = true
				matches_found = true
				round_matched += 1
			# If we are working with max 3, then return immediately if we have 3 matches
			if (debuff_effects.has("MATCH_TYPE_3") && round_matched >= 3):
				return matches_found
	return matches_found

func in_grid(position: Vector2):
	if (position.x < 0 || position.x >= width || position.y < 0 || position.y >= height):
		return false
	return true

func toggle_visibility():
	for i in range(width):
		for j in range(height):
			all_pieces[i][j].visible = !all_pieces[i][j].visible

func _input(event):
	if (active):
		if event is InputEventKey and event.is_pressed() and event.keycode == KEY_V:
			toggle_visibility()
		if event is InputEventKey and event.is_pressed() and event.keycode == KEY_S:
			shuffle()
		if event is InputEventKey and event.is_pressed() and event.keycode == KEY_R:
			rotate_blocks()
		if event is InputEventMouseButton and event.is_pressed():
			var pos = get_global_mouse_position()
			first_touch = pixel_to_grid(pos.x, pos.y)
		if event is InputEventMouseButton and event.is_released():
			var pos = get_global_mouse_position()
			final_touch = pixel_to_grid(pos.x, pos.y)
			if (in_grid(first_touch) && in_grid(final_touch)):
				if (!all_pieces[first_touch.x][first_touch.y].fixed &&
					!all_pieces[final_touch.x][final_touch.y].fixed &&
					all_pieces[first_touch.x][first_touch.y].colour != "Stone" && 
					all_pieces[final_touch.x][final_touch.y].colour != "Stone" &&
					all_pieces[first_touch.x][first_touch.y].colour != "XStone" && 
					all_pieces[final_touch.x][final_touch.y].colour != "XStone" &&
					all_pieces[first_touch.x][first_touch.y].colour != "Virus" && 
					all_pieces[final_touch.x][final_touch.y].colour != "Virus" &&
					all_pieces[first_touch.x][first_touch.y].colour != "XVirus" && 
					all_pieces[final_touch.x][final_touch.y].colour != "XVirus"):
					moved = true
					move_pieces(first_touch, final_touch)

func rotate_blocks():
	for x in width:
		for y in height:
			if (all_pieces[x][y].colour == "rotate"):
				all_pieces[x][y].rotate_piece()
				var all_neighbours = []
				all_neighbours.append(Vector2(x - 1, y - 1))
				all_neighbours.append(Vector2(x, y - 1))
				all_neighbours.append(Vector2(x + 1, y - 1))
				all_neighbours.append(Vector2(x + 1, y))
				all_neighbours.append(Vector2(x + 1, y + 1))
				all_neighbours.append(Vector2(x, y + 1))
				all_neighbours.append(Vector2(x - 1, y + 1))
				all_neighbours.append(Vector2(x - 1, y))
				
				var temp_piece = all_pieces[all_neighbours[0].x][all_neighbours[0].y]
				for index in range(8):
					print(all_neighbours[index])
					var from_position = all_neighbours[index]
					var to_position = all_neighbours[(index + 1) % 8]
					var current_piece = temp_piece
					temp_piece = all_pieces[to_position.x][to_position.y]
					all_pieces[to_position.x][to_position.y] = current_piece
					current_piece.move_to(grid_to_pixel(to_position.x, to_position.y))


func collapse_columns():
	for i in width:
		# Start from the bottom, move up
		for j in range(height - 1, 0, -1):
			# If this spot is empty...
			if (all_pieces[i][j].colour == "null"):
				# Look above until we find a non blank
				for k in range(j - 1, -1, -1):
					# If we find a non-blank no-fixed piece, move it to this location
					if (all_pieces[i][k].colour != "null" && all_pieces[i][k].fixed == false):
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null_piece.instantiate()
						all_pieces[i][j].move_to(grid_to_pixel(i, j))
						break
	recolour_for_exclusion()
	if (check_for_matches()):
		clear_timer.start()
	else:
		refill_timer.start()

func remove_refill_matches():
	var refill_pieces = possible_pieces
	if (active_effects.has("COLOURBLIND")):
		refill_pieces = colourblind_pieces
	var k = randi_range(0, refill_pieces.size() - 1)
	for square: Vector2 in squares_to_drop:
		var i = square.x
		var j = square.y
		if (all_pieces[i][j].matched):
			print("Refill match at " + str(i) + ", " + str(j))
			var piece: Piece = refill_pieces[k].instantiate()
			while (all_pieces[i][j].colour == piece.colour):
				print("Colours match, trying another")
				k = (k + 1) % (refill_pieces.size())
				piece = refill_pieces[k].instantiate()
			all_pieces[i][j].queue_free()
			all_pieces[i][j] = piece
			all_pieces[i][j].matched = false
			add_child(piece)
			move_child(piece, 0)
			k = (k + 1) % (refill_pieces.size())

func drop_refill_pieces():
	var k = 0
	for position in squares_to_drop:
		var x = position.x
		var y = position.y
		k += 1
		all_pieces[x][y].position = grid_to_pixel(x, y - 1)
		all_pieces[x][y].move_to(grid_to_pixel(x, y))
	get_node("Dust_Emitter").restart()

func refill_board():
	for i in width:
		for j in height:
			if (all_pieces[i][j].colour == "null" || all_pieces[i][j].colour == "Xnull"):
				# Check if we need to place a special block
				if (randf() <= special_chance):
					all_pieces[i][j].queue_free()
					var index = randi_range(0, range_specials - 1)
					var piece: Piece = special_pieces[index].instantiate()
					all_pieces[i][j] = piece
					squares_to_drop.append(Vector2(i, j))
					add_child(piece)
					move_child(piece, 0)
					continue
				# Place a normal coloured block
				var k = randi_range(0, possible_pieces.size() - 1)
				var piece: Piece = possible_pieces[k].instantiate()
				while (match_at(i, j, piece.colour)):
					k = (k + 1) % (possible_pieces.size() - 1)
					piece = possible_pieces[k].instantiate()
				squares_to_drop.append(Vector2(i, j))
				all_pieces[i][j] = piece
				add_child(piece)
				move_child(piece, 0)
	if (active_effects.has("COLOURBLIND")):
		recolour_green_to_red()
	while (check_for_matches()):
		print("Matches found after recolouring")
		remove_refill_matches()
		unmatch_all()
	drop_refill_pieces()
	recolour_for_exclusion()
	squares_to_drop = []

func count_matches():
	for i in width:
		for j in height:
			if (all_pieces[i][j].matched):
				round_matched += 1

func _on_collapse_timer_timeout():
	collapse_columns()
	collapse_needed = false

func _on_clear_timer_timeout():
	clear_matches()
	clear_broken()
	var pitch_shift = 0.7 + (round_matched / 10.0)
	get_node("/root/BaseScene/AudioManager").play_match(pitch_shift)

func _on_refill_timer_timeout():
	refill_board()
	countdown_viruses()
	var multiplier = score_multiplier[min(round_matched, 12)] * perk_multiplier * temp_multiplier
	temp_multiplier = 1.0
	get_parent().add_diamonds(round_matched - 3)
	get_parent().add_score(round_matched * multiplier * 100)
	print("This round: " + str(round_matched * multiplier * 100))
	total_matched += round_matched
	print("Total matched: " + str(total_matched))
	if (challenge_level):
		get_parent().check_win_challenge(count_challenge_blocks())
	else:
		get_parent().check_win(total_matched)
	# If the refill is caused by a virus, we don't need to age the perks/debuffs
	if (refill_caused_by_virus):
		end_turn.emit(false)
	else:
		end_turn.emit(moved)
	moved = false
	refill_caused_by_virus = false
	round_matched = 0
	active = true

func count_challenge_blocks():
	var num_blocks = 0
	for i in width:
		for j in height:
			if ((all_pieces[i][j].colour == "Stone" || all_pieces[i][j].colour == "XStone") && (all_pieces[i][j].effect == "GOLD" || all_pieces[i][j].effect == "DIAMOND")):
				num_blocks += 1
			if (all_pieces[i][j].colour == "Virus"):
				num_blocks += 1
	return num_blocks

func activate_debuffs():
	for i in num_debuffs:
		print("Activating debuff")
		get_parent().activate_debuff()

func crack_all_blocks():
	active = false
	for i in range(width):
		for j in range(height):
			if (all_pieces[i][j].colour == "Stone" || all_pieces[i][j].colour == "XStone"):
				all_pieces[i][j].durability -= 1
				all_pieces[i][j].crack_piece()
				if (all_pieces[i][j].durability <= 0):
					collapse_needed = true
	clear_broken()
	if (collapse_needed):
		collapse_timer.start()
	else:
		active = true

func harden_all_blocks():
	for i in range(width):
		for j in range(height):
			if (all_pieces[i][j].colour == "Stone" || all_pieces[i][j].colour == "XStone"):
				all_pieces[i][j].durability += 1
				print("Hardening at " + str(i) + ", " + str(j))
				all_pieces[i][j].harden_piece()

func spawn_hard_blocks():
	var num_blocks = 5
	for i in range(num_blocks):
		var x = randi_range(0, width - 1)
		var y = randi_range(0, height - 1)
		var hard_index = randi_range(0, hard_pieces.size() - 1)
		all_pieces[x][y].queue_free()
		var piece: Piece = hard_pieces[hard_index].instantiate()
		all_pieces[x][y] = piece
		add_child(piece)
		move_child(piece, 0)
		piece.position = grid_to_pixel(x, y)

func spawn_rainbow_blocks():
	var num_blocks = 5
	for i in range(num_blocks):
		var x = randi_range(0, width - 1)
		var y = randi_range(0, height - 1)
		all_pieces[x][y].queue_free()
		var piece: Piece = rainbow_piece.instantiate()
		all_pieces[x][y] = piece
		add_child(piece)
		move_child(piece, 0)
		piece.position = grid_to_pixel(x, y)

func set_match_type(new_type):
	match_type = new_type

func process_effects():
	# Default match type, can be replaced by effects
	match_type = MATCH_TYPE.STANDARD
	perk_multiplier = 1.0
	debuff_effects = []
	for effect in active_effects:
		match effect:
			"MATCH_TYPE_DIAGONAL":
				match_type = MATCH_TYPE.DIAGONAL
			"MATCH_TYPE_TETRIS":
				match_type = MATCH_TYPE.TETRIS
			"MATCH_TYPE_QUEEN":
				match_type = MATCH_TYPE.QUEEN
			"MATCH_TYPE_CHAOS":
				var index = randi_range(0, 2)
				if (index == 0):
					match_type = MATCH_TYPE.STANDARD
				if (index == 1):
					match_type = MATCH_TYPE.DIAGONAL
				if (index == 2):
					match_type = MATCH_TYPE.TETRIS
			"MULTIPLIER_TYPE_2":
				perk_multiplier *= 2
			"MATCH_TYPE_3":
				debuff_effects.append("MATCH_TYPE_3")
			"HALF":
				perk_multiplier *= 0.5
			"COLOURBLIND":
				recolour_green_to_red()

func recolour_green_to_red():
	for i in range(width):
		for j in range(height):
			if (all_pieces[i][j] is GreenPiece):
				all_pieces[i][j].colour = "red"

func correct_colours():
	for i in range(width):
		for j in range(height):
			if (all_pieces[i][j] is GreenPiece):
				all_pieces[i][j].colour = "green"

func add_effect(effect):
	active_effects.append(effect)
	process_effects()

func remove_effect(effect):
	active_effects.erase(effect)
	process_effects()

func countdown_viruses():
	if (active_effects.has("TIME_STOP")):
		return
	for i in width:
		for j in height:
			if (all_pieces[i][j] is VirusPiece):
				all_pieces[i][j].countdown()
				if (all_pieces[i][j].life <= 0):
					all_pieces[i][j].move_to_bag()
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null_piece.instantiate()
					# Check the row above - if it is not empty, then we need to collapse the columns
					if (j > 0 && all_pieces[i][j - 1].colour != "null"):
						collapse_needed = true
	if (collapse_needed):
		refill_caused_by_virus = true
		collapse_timer.start()
	print("Num debuffs: " + str(num_debuffs))
	activate_debuffs()
	num_debuffs = 0

func set_level(level, challenge = false):
	if (level >= 3):
		num_specials = level / 2
		range_specials = min((level - 1) / 2, special_pieces.size())
		special_indexes = all_indexes
		special_indexes.shuffle()
		special_indexes = special_indexes.slice(0, num_specials)
		# Place special tiles for each special index
		for i in special_indexes:
			var row = i % width
			var col = i / width
			all_pieces[row][col].queue_free()
			var index = randi_range(0, range_specials - 1)
			var piece: Piece = special_pieces[index].instantiate()
			all_pieces[row][col] = piece
			add_child(piece)
			move_child(piece, 0)
			piece.position = grid_to_pixel(row, col)
		# The probability of new special blocks spawning
		special_chance = float(num_specials) / float(width * height)
		var num_rotates = min(num_specials - 2, 6)
		num_rotates = max(num_rotates, 0)
		print("Num rotates: " + str(num_rotates))
		rotate_squares.shuffle()
		var rotates = rotate_squares.slice(0, num_rotates)
		for r in rotates:
			all_pieces[r.x][r.y].queue_free()
			var piece = rotate_piece.instantiate()
			all_pieces[r.x][r.y] = piece
			add_child(piece)
			move_child(piece, 0)
			piece.position = grid_to_pixel(r.x, r.y)
	if (challenge):
		print("Challenge level")
		special_indexes = all_indexes
		special_indexes.shuffle()
		for i in (level/3):
			var x = special_indexes[i] % width
			var y = special_indexes[i] / width
			all_pieces[x][y].queue_free()
			var piece = virus_piece.instantiate()
			all_pieces[x][y] = piece
			all_pieces[x][y].update_life(randi_range(2, 4))
			piece.time_expired.connect(increment_debuff)
			add_child(piece)
			move_child(piece, 0)
			piece.position = grid_to_pixel(x, y)
			x = randi_range(0, width - 1)
			y = randi_range(0, height - 1)
			all_pieces[x][y].queue_free()
			piece = gold_piece.instantiate()
			all_pieces[x][y] = piece
			add_child(piece)
			move_child(piece, 0)
			piece.position = grid_to_pixel(x, y)
			x = randi_range(0, width - 1)
			y = randi_range(0, height - 1)
			all_pieces[x][y].queue_free()
			piece = diamond_piece.instantiate()
			all_pieces[x][y] = piece
			add_child(piece)
			move_child(piece, 0)
			piece.position = grid_to_pixel(x, y)
		# Challenge levels >= 6 include certain rows or columns being excluded
		# Maximum of 5 of these rows and columns, since too many would make it literally impossible
		if (level >= 6):
			var num_lines = min((level - 3) / 3, 5)
			var all_lines = range(8)
			all_lines.shuffle()
			var lines = all_lines.slice(0, num_lines)
			for i in range(lines.size()):
				if i % 2 == 0:
					exclude_row(lines[i])
				else:
					exclude_column(lines[i])
		challenge_level = true

func exclude_row(row):
	for x in range(width):
		var y = row
		var exclusion_pos = grid_to_pixel(x, y)
		var exclusion = preload("res://Scenes/exclusion_zone.tscn").instantiate()
		exclusion.position = exclusion_pos
		add_child(exclusion)
		exclusions.append(exclusion)

func exclude_column(col):
	for y in range(height):
		var x = col
		var exclusion_pos = grid_to_pixel(x, y)
		var exclusion = preload("res://Scenes/exclusion_zone.tscn").instantiate()
		exclusion.position = exclusion_pos
		add_child(exclusion)
		exclusions.append(exclusion)
