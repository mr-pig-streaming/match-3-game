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
var vertical_matched: int = 0
var horizontal_matched: int = 0
var cross_matched: int = 0
var positive_diagonal_matched: int = 0
var negative_diagonal_matched: int = 0
var diag_cross_matched: int = 0
var active: bool = true
var challenge_level: bool = false
var boss_level: bool = false

var perk_multiplier = 1.0
var temp_multiplier = 1.0

var score_multiplier = [0, 1, 1, 1, 1.25, 1.6, 2.17, 3, 4.25, 6.11, 8.9, 13.09, 19.42]

var squares_to_drop = []

var active_effects = []

var debuff_effects = []

var debuff_colours = []

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

# Detecting a corner is the best way to detect a cross match
var CORNER_0 = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)]
var CORNER_90 = [Vector2(0, 0), Vector2(-1, 0), Vector2(0, 1)]
var CORNER_180 = [Vector2(0, 0), Vector2(-1, 0), Vector2(0, -1)]
var CORNER_270 = [Vector2(0, 0), Vector2(0, -1), Vector2(1, 0)]

var corners = [CORNER_0, CORNER_90, CORNER_180, CORNER_270]

var DCORNER_0 = [Vector2(0, 0), Vector2(-1, -1), Vector2(1, -1)]
var DCORNER_90 = [Vector2(0, 0), Vector2(1, -1), Vector2(1, 1)]
var DCORNER_180 = [Vector2(0, 0), Vector2(1, 1), Vector2(-1, 1)]
var DCORNER_270 = [Vector2(0, 0), Vector2(-1, -1), Vector2(-1, 1)]

var diag_corners = [DCORNER_0, DCORNER_90, DCORNER_180, DCORNER_270]

# Indicates if we need to collapse columns after a match
var collapse_needed: bool
var new_target_needed = false
@onready var collapse_timer = $Collapse_Timer
@onready var clear_timer = $Clear_Timer
@onready var refill_timer = $Refill_Timer

# Dictionary to keep track of the likelihood of various pieces
var possible_pieces = {
	"red": 1.0,
	"orange": 1.0,
	"yellow": 1.0,
	"green": 1.0,
	"blue": 1.0,
	"purple": 1.0,
	"energy": 0.2
}


var colourblind_pieces = [
	preload("res://Scenes/blue_piece.tscn"),
	preload("res://Scenes/orange_piece.tscn"),
	preload("res://Scenes/purple_piece.tscn"),
	preload("res://Scenes/red_piece.tscn"),
	preload("res://Scenes/yellow_piece.tscn"),
	preload("res://Scenes/energy_piece.tscn")
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
var bomb_piece = preload("res://Scenes/bomb_piece.tscn")
var bonus_piece = preload("res://Scenes/bonus_piece.tscn")

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

# The rows and columns with conveyers
var conveyers_right = []
var conveyers_left = []
var conveyers_down = []
var conveyers_up = []

# Areas that are to be obscured
var obscured_blocks = []

# The target locations. Exclusive to boss levels
var targets = []

var helper_move = false

# Used for boss levels
var bombs_matched = 0
var bonuses_matched = 0

var test_y_offset = 0

# The number of energy blocks that have been matched
var energy_matched = 0

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

func random_piece(total_weights):
	var k = randf_range(0, total_weights)
	var piece
	for colour in possible_pieces:
		k -= possible_pieces[colour]
		if k <= 0:
			match colour:
				"red": piece = preload("res://Scenes/red_piece.tscn").instantiate()
				"orange": piece = preload("res://Scenes/orange_piece.tscn").instantiate()
				"yellow": piece = preload("res://Scenes/yellow_piece.tscn").instantiate()
				"green": piece = preload("res://Scenes/green_piece.tscn").instantiate()
				"blue": piece = preload("res://Scenes/blue_piece.tscn").instantiate()
				"purple": piece = preload("res://Scenes/purple_piece.tscn").instantiate()
				"energy": piece = preload("res://Scenes/energy_piece.tscn").instantiate()
			return piece

func remove_setup_matches():
	var total_weights = 0.0
	for p in possible_pieces:
		total_weights += possible_pieces[p]
	for i in width:
		for j in height:
			if (all_pieces[i][j].matched):
				var piece = random_piece(total_weights)
				while (all_pieces[i][j].matches(piece.colour)):
					piece.queue_free()
					piece = random_piece(total_weights)
				all_pieces[i][j].queue_free()
				all_pieces[i][j] = piece
				all_pieces[i][j].matched = false
				add_child(all_pieces[i][j])
				move_child(all_pieces[i][j], 0)
				all_pieces[i][j].position = grid_to_pixel(i, j)

func setup_pieces():
	remove_obscured()
	remove_exclusion_zones()
	remove_conveyers()
	# Calculate the total weights of all possible pieces
	var total_weights = 0.0
	for p in possible_pieces:
		total_weights += possible_pieces[p]
	for i in width:
		for j in height:
			var piece = random_piece(total_weights)
			while (match_at(i, j, piece.colour)):
				print("Match found, removing...")
				piece = random_piece(total_weights)
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
	#add_obscured()
	total_matched = 0
	round_matched = 0

func setup_for_boss():
	add_target(randi_range(0, width - 1), randi_range(0, height - 1))
	for i in range(5):
		var x = randi_range(0, width - 1)
		var y = randi_range(0, height - 1)
		all_pieces[x][y].queue_free()
		var new_piece = bomb_piece.instantiate()
		new_piece.position = grid_to_pixel(x, y)
		all_pieces[x][y] = new_piece
		add_child(new_piece)
	for i in range(4):
		var x = randi_range(0, width - 1)
		var y = randi_range(0, height - 1)
		all_pieces[x][y].queue_free()
		var new_piece = bonus_piece.instantiate()
		new_piece.position = grid_to_pixel(x, y)
		all_pieces[x][y] = new_piece
		add_child(new_piece)

func add_target(x, y):
	var target = preload("res://Scenes/target.tscn").instantiate()
	target.x = x
	target.y = y
	target.position = grid_to_pixel(x, y)
	add_child(target)
	move_child(target, -1)
	target.timeout.connect(timeout_target)
	targets.append(target)

func timeout_target():
	var removed_targets = []
	for i in range(targets.size()):
		var t = targets[i]
		if t.time <= 0:
			if (all_pieces[t.x][t.y].colour == "bomb"):
				bombs_matched += 1
			if (all_pieces[t.x][t.y].colour == "bonus"):
				bonuses_matched += 1
			t.queue_free()
			removed_targets.append(i)
	# Remove the targets (in reverse order to avoid index issues)
	removed_targets.reverse()
	for i in removed_targets:
		var x = targets[i].x
		var y = targets[i].y
		all_pieces[x][y].move_to_bag()
		#all_pieces[x][y].queue_free()
		all_pieces[x][y] = null_piece.instantiate()
		# Check the row above - if it is not empty, then we need to collapse the columns
		if (y > 0 && all_pieces[x][y - 1].colour != "null"):
			collapse_needed = true
			new_target_needed = true
		if (collapse_needed):
			collapse_timer.start()
		# If we are in the top row, we don't need a collapse but we do need to refill
		if (y == 0):
			refill_timer.start()
			new_target_needed = true
		targets.remove_at(i)

func add_obscured():
	for i in range(5):
		var x = randi_range(0, width - 1)
		var y = randi_range(0, height - 1)
		var obscure_pos = grid_to_pixel(x, y)
		var obscured = preload("res://Scenes/obscured_zone.tscn").instantiate()
		obscured.position = obscure_pos
		add_child(obscured)
		move_child(obscured, -1)
		obscured_blocks.append(obscured)

func remove_obscured():
	for o in obscured_blocks:
		remove_child(o)
	obscured_blocks = []

func remove_conveyers():
	conveyers_left.clear()
	conveyers_right.clear()

func add_conveyer_left(row):
	conveyers_left.append(row)
	for x in range(width):
		var position = grid_to_pixel(x, row)
		var sprite = Sprite2D.new()
		sprite.texture = preload("res://Art/arrow.png")
		sprite.rotation_degrees = 180
		sprite.position = position
		add_child(sprite)
		move_child(sprite, -1)

func add_conveyer_right(row):
	conveyers_right.append(row)
	for x in range(width):
		var position = grid_to_pixel(x, row)
		var sprite = Sprite2D.new()
		sprite.texture = preload("res://Art/arrow.png")
		sprite.position = position
		add_child(sprite)
		move_child(sprite, -1)

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

func run_conveyers():
	for y in conveyers_right:
		var temp_orig
		var temp_target = all_pieces[0][y]
		for x in range(width):
			temp_orig = temp_target
			var target = (x + 1) % width
			temp_target = all_pieces[target][y]
			all_pieces[target][y] = temp_orig
			all_pieces[target][y].move_to(grid_to_pixel(target, y))
	for y in conveyers_left:
		var temp_orig
		var temp_target = all_pieces[6][y]
		var indexes = range(width + 1)
		indexes.reverse()
		for x in indexes:
			temp_orig = temp_target
			var target = (x - 1 + width) % width
			print("Moving " + str(x) + " to " + str(target))
			temp_target = all_pieces[target][y]
			all_pieces[target][y] = temp_orig
			all_pieces[target][y].move_to(grid_to_pixel(target, y))
	recolour_for_exclusion()

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

func get_neighbours(x, y, all_eight = false):
	var neighbours = []
	if (match_type == MATCH_TYPE.STANDARD || match_type == MATCH_TYPE.TETRIS || match_type == MATCH_TYPE.QUEEN || all_eight):
		if (x > 0):
			neighbours.append(Vector2(x - 1, y))
		if (x < width - 1):
			neighbours.append(Vector2(x + 1, y))
		if (y > 0):
			neighbours.append(Vector2(x, y - 1))
		if (y < height - 1):
			neighbours.append(Vector2(x, y + 1))
	if (match_type == MATCH_TYPE.DIAGONAL  || match_type == MATCH_TYPE.QUEEN || all_eight):
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

func move_pieces_helper(position1, position2):
	var direction: Vector2 = position2 - position1
	if (direction.length() == 1 || active_effects.has("TRANSLOCATOR")):
		get_node("/root/BaseScene/AudioManager").play_swish()
		var piece1 = all_pieces[position1.x][position1.y]
		var piece2 = all_pieces[position2.x][position2.y]
		piece1.move_to(grid_to_pixel(position2.x, position2.y))
		piece2.move_to(grid_to_pixel(position1.x, position1.y))
		all_pieces[position1.x][position1.y] = piece2
		all_pieces[position2.x][position2.y] = piece1
		recolour_for_exclusion()

func move_pieces(position1, position2, moved_by_helper = false):
	helper_move = moved_by_helper
	var direction: Vector2 = position2 - position1
	if (direction.length() == 1 || active_effects.has("TRANSLOCATOR")):
		get_node("/root/BaseScene/AudioManager").play_swish()
		if (!active_effects.has("TIME_STOP") && !moved_by_helper):
			get_parent().reduce_turns(1)
		var piece1 = all_pieces[position1.x][position1.y]
		var piece2 = all_pieces[position2.x][position2.y]
		piece1.move_to(grid_to_pixel(position2.x, position2.y))
		piece2.move_to(grid_to_pixel(position1.x, position1.y))
		all_pieces[position1.x][position1.y] = piece2
		all_pieces[position2.x][position2.y] = piece1
		recolour_for_exclusion()
		rotate_blocks()
		run_conveyers()
		if (check_for_matches()):
			active = false
			clear_timer.start()
		else:
			if (challenge_level):
				get_parent().check_win_challenge(count_challenge_blocks())
			else:
				get_parent().check_win(total_matched)
			countdown_targets()
			countdown_viruses()
			if (!moved_by_helper):
				end_turn.emit(moved)
				print("Reducing energy by 1")
				get_parent().reduce_effect_duration(1)
				get_parent().update_turn_counter()
	recolour_for_exclusion()

func recheck_matches():
	if (check_for_matches()):
		active = false
		clear_timer.start()
	elif (helper_move == false):
		countdown_viruses()
		countdown_targets()
		end_turn.emit(moved)

func crack_hard_blocks():
	for i in width:
		for j in height:
			if (all_pieces[i][j].matched):
			# If any neighbour is stone or virus, reduce its durability and crack it
				var neighbours = get_neighbours(i, j)
				for n in neighbours:
					if (all_pieces[n.x][n.y].colour == "Stone" || all_pieces[n.x][n.y].colour == "Virus" || all_pieces[n.x][n.y].colour == "XStone" || all_pieces[n.x][n.y].colour == "XVirus"):
						all_pieces[n.x][n.y].durability -= 1
						all_pieces[n.x][n.y].crack_piece()

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
				# If this colour isn't debuffed, add to the match count
				if (all_pieces[i][j].colour == "energy"):
					energy_matched += 1
				elif (!debuff_colours.has(all_pieces[i][j].colour)):
					round_matched += 1
					colour_count(all_pieces[i][j])
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
		if event is InputEventKey and event.is_pressed() and event.keycode == KEY_C:
			run_conveyers()
		if event is InputEventKey and event.is_pressed() and event.keycode == KEY_Q:
			active_effects.append("TRANSLOCATOR")
		if event is InputEventKey and event.is_pressed() and event.keycode == KEY_B:
			active_effects.append("MATCH_TYPE_DIAGONAL")
			process_effects()
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
					get_parent().get_node("SideBoard/Helper").act()
					move_pieces(first_touch, final_touch)

func rotate_blocks():
	for x in width:
		for y in height:
			if (all_pieces[x][y].colour == "rotate" || all_pieces[x][y].colour == "Xrotate"):
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
	recolour_for_exclusion()


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
	var total_weights = 0.0
	for p in possible_pieces:
		total_weights += possible_pieces[p]
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
				var piece: Piece = random_piece(total_weights)
				while (match_at(i, j, piece.colour)):
					piece = random_piece(total_weights)
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

func colour_count(piece):
	match (piece.colour):
		"red":
			get_parent().red_matched += 1
		"orange":
			get_parent().orange_matched += 1
		"yellow":
			get_parent().yellow_matched += 1
		"green":
			get_parent().green_matched += 1
		"blue":
			get_parent().blue_matched += 1
		"purple":
			get_parent().purple_matched += 1

func count_matches():
	for i in width:
		for j in height:
			if (all_pieces[i][j].matched):
				round_matched += 1
				colour_count(all_pieces[i][j])
	cross_matched += count_corners()
	vertical_matched += count_vertical_matches()
	horizontal_matched += count_horizontal_matches()

func count_vertical_matches():
	var v = 0
	for i in width:
		var col_matches = 0
		for j in height:
			if (all_pieces[i][j].matched && all_pieces[i][j].colour != "BLANK"):
				col_matches += 1
		if (col_matches >= 3):
			v += col_matches
	return v

func count_horizontal_matches():
	var h = 0
	for j in height:
		var row_matches = 0
		for i in width:
			if (all_pieces[i][j].matched && all_pieces[i][j].colour != "BLANK"):
				row_matches += 1
		if (row_matches >= 3):
			h += row_matches
	return h

# The way the blocks count, positive diagonal is this way: \
func count_positive_diagonal_matches():
	var p = 0
	for c in range(height * -1, width, 1):
		var diag_matches = 0
		for x in width:
			# Formula y = mx + c. The c is the offset from the centre diagonal. m is 1 for a perfect diagonal
			var y = x + c
			if (y >= height || y < 0): continue
			if (all_pieces[x][y].matched && all_pieces[x][y].colour != "BLANK"):
				diag_matches += 1
		if (diag_matches >= 3):
			p += diag_matches
	return p

# The way the blocks count, negative diagonal is this way: /
func count_negative_diagonal_matches():
	var n = 0
	for c in range(0, width + height, 1):
		var diag_matches = 0
		for x in width:
			# Formula y = mx + c. The c is the offset from the centre diagonal. m is -1 for a perfect diagonal
			var y = -1 * x + c
			if (y >= height || y < 0): continue
			if (all_pieces[x][y].matched && all_pieces[x][y].colour != "BLANK"):
				diag_matches += 1
		if (diag_matches >= 3):
			n += diag_matches
	return n

func count_corners():
	for i in width:
		for j in height:
			var corner = check_for_corner_at(i, j)
			if (corner[0]):
				var col_matches = 0
				var row_matches = 0
				var corner_matches = 0
				var x = corner[1].x
				var y = corner[1].y
				var colour = corner[2]
				# Count the vertical and horizontal components of this cross match
				for h in height:
					if (all_pieces[x][h].matched && all_pieces[x][h].matches(colour)):
						col_matches += 1
						all_pieces[x][h].colour = "BLANK"
				for w in width:
					if (all_pieces[w][y].matched && all_pieces[w][y].matches(colour)):
						row_matches += 1
						all_pieces[w][y].colour = "BLANK"
				if (col_matches >= 3):
					corner_matches += col_matches
				# Only need 2 on the horizontal since the corner will have been recoloured
				if (row_matches >= 2):
					corner_matches += row_matches
				return corner_matches
	return 0

func check_for_corner_at(x, y):
	# For each shape, shift it to the x & y...
	for shape in corners:
		var shifted_shape = []
		for square in shape:
			shifted_shape.append(Vector2(square.x + x, square.y + y))
		# If any square is outside the grid, this position is invalid so don't check it
		if contains_invalid(shifted_shape):
			continue
		# Make sure all squares in the corner are matched
		var matched = true
		for square in shifted_shape:
			if (!all_pieces[square.x][square.y].matched):
				matched = false
		# Make sure all corner squares have the same colour
		var colour = all_pieces[shifted_shape[0].x][shifted_shape[0].y].colour
		for square in shifted_shape:
			if (!all_pieces[square.x][square.y].matches(colour)):
				matched = false
		if (matched == false):
			# This shape has at least one non-match
			continue
		return [true, shifted_shape[0], colour]
	return [false, null, null]

func count_diag_corners():
	for i in width:
		for j in height:
			var corner = check_for_diag_corner_at(i, j)
			if (corner[0]):
				print("Found corner match at " + str(corner[1]))
				var pos_matches = 0
				var neg_matches = 0
				var corner_matches = 0
				var x = corner[1].x
				var y = corner[1].y
				var colour = corner[2]
				# Count the positive and negative components of this cross match
				var positive_c = y - x
				for w in width:
					# Formula y = mx + c. The c is the offset from the centre diagonal. m is 1 for a perfect diagonal
					var h = w + positive_c
					if (h >= height || h < 0): continue
					if (all_pieces[w][h].matched && all_pieces[w][h].colour != "BLANK"):
						pos_matches += 1
						all_pieces[w][h].colour = "BLANK"
				var negative_c = y + x
				for w in width:
					# Formula y = mx + c. The c is the offset from the centre diagonal. m is -1 for a perfect diagonal
					var h = -1 * w + negative_c
					if (h >= height || h < 0): continue
					if (all_pieces[w][h].matched && all_pieces[w][h].colour != "BLANK"):
						neg_matches += 1
						all_pieces[w][h].colour = "BLANK"
				if (pos_matches >= 3):
					corner_matches += pos_matches
				# Only need 2 on the negative since the corner will have been recoloured
				if (neg_matches >= 2):
					corner_matches += neg_matches
				return corner_matches
	return 0

func check_for_diag_corner_at(x, y):
	# For each shape, shift it to the x & y...
	for shape in diag_corners:
		var shifted_shape = []
		for square in shape:
			shifted_shape.append(Vector2(square.x + x, square.y + y))
		# If any square is outside the grid, this position is invalid so don't check it
		if contains_invalid(shifted_shape):
			continue
		# Make sure all squares in the corner are matched
		var matched = true
		for square in shifted_shape:
			if (!all_pieces[square.x][square.y].matched):
				matched = false
		# Make sure all corner squares have the same colour
		var colour = all_pieces[shifted_shape[0].x][shifted_shape[0].y].colour
		for square in shifted_shape:
			if (!all_pieces[square.x][square.y].matches(colour)):
				matched = false
		if (matched == false):
			# This shape has at least one non-match
			continue
		return [true, shifted_shape[0], colour]
	return [false, null, null]

func spawn_special_blocks():
	print("Spawning specials")
	for x in width:
		for y in height:
			# If this piece is matched...
			if (all_pieces[x][y].matched):
				# Count how many neighbours are matched
				var neighbours = get_neighbours(x, y)
				var matched_neighbours = 0
				for n in neighbours:
					if all_pieces[n.x][n.y].matched:
						matched_neighbours += 1
				# If at least 3 neighbours are matched...
				if (matched_neighbours == 3):
					all_pieces[x][y].matched = false
					all_pieces[x][y].special = true
					all_pieces[x][y].get_node("Sparkle").visible = true
					all_pieces[x][y].get_node("Sparkle").material.set_shader_parameter("surface", all_pieces[x][y].get_node("Sprite2D").texture)
					# Assign the colour which was previously removed
					if all_pieces[x][y] is RedPiece:
						all_pieces[x][y].colour = "red"
					if all_pieces[x][y] is OrangePiece:
						all_pieces[x][y].colour = "orange"
					if all_pieces[x][y] is YellowPiece:
						all_pieces[x][y].colour = "yellow"
					if all_pieces[x][y] is GreenPiece:
						all_pieces[x][y].colour = "green"
					if all_pieces[x][y] is BluePiece:
						all_pieces[x][y].colour = "blue"
					if all_pieces[x][y] is PurplePiece:
						all_pieces[x][y].colour = "purple"
					if all_pieces[x][y] is RainbowPiece:
						all_pieces[x][y].colour = "redorangeyellowgreenbluepurple"
					print("New special block. Colour: " + all_pieces[x][y].colour)
				if (matched_neighbours >= 4):
					if (match_type == MATCH_TYPE.STANDARD || match_type == MATCH_TYPE.QUEEN || match_type == MATCH_TYPE.TETRIS):
						var x_pos = x_offset + x * 64 + 32
						var y_pos = y_offset + y * 64 - 32
						get_node("HorizontalLightning").position = Vector2(0, y_pos)
						get_node("HorizontalLightning").visible = true
						get_node("VerticalLightning").position = Vector2(x_pos, 0)
						get_node("VerticalLightning").visible = true
						for c in width:
							if (all_pieces[c][y].fixed):
								pass
							elif (all_pieces[c][y].colour == "Stone" || all_pieces[c][y].colour == "Virus" || all_pieces[c][y].colour == "XStone" || all_pieces[c][y].colour == "XVirus"):
								all_pieces[c][y].durability -= 1
								all_pieces[c][y].crack_piece()
							elif (!all_pieces[c][y].matched):
								all_pieces[c][y].matched = true
								round_matched += 1
								colour_count(all_pieces[c][y])
						for r in height:
							if (all_pieces[x][r].fixed):
								pass
							elif (all_pieces[x][r].colour == "Stone" || all_pieces[x][r].colour == "Virus" || all_pieces[x][r].colour == "XStone" || all_pieces[x][r].colour == "XVirus"):
								all_pieces[x][r].durability -= 1
								all_pieces[x][r].crack_piece()
							elif (!all_pieces[x][r].matched):
								all_pieces[x][r].matched = true
								round_matched += 1
								colour_count(all_pieces[x][r])
					if (match_type == MATCH_TYPE.DIAGONAL || match_type == MATCH_TYPE.QUEEN):
						var positive_c = y - x
						for w in width:
							# Formula y = mx + c. The c is the offset from the centre diagonal. m is 1 for a perfect diagonal
							var r = w + positive_c
							if (r >= height || r < 0): continue
							if (all_pieces[w][r].fixed):
								pass
							elif (all_pieces[w][r].colour == "Stone" || all_pieces[w][r].colour == "Virus" || all_pieces[w][r].colour == "XStone" || all_pieces[w][r].colour == "XVirus"):
								all_pieces[w][r].durability -= 1
								all_pieces[w][r].crack_piece()
							elif (!all_pieces[w][r].matched):
								all_pieces[w][r].matched = true
								round_matched += 1
								colour_count(all_pieces[w][r])
						var y_pos = (positive_c - 1) * 64 + 32
						get_node("PosDiagonalLightning").visible = true
						get_node("PosDiagonalLightning").position = Vector2(0, y_pos)
						var negative_c = y + x
						for w in width:
							# Formula y = mx + c. The c is the offset from the centre diagonal. m is 1 for a perfect diagonal
							var r = -w + negative_c
							if (r >= height || r < 0): continue
							if (all_pieces[w][r].fixed):
								pass
							elif (all_pieces[w][r].colour == "Stone" || all_pieces[w][r].colour == "Virus" || all_pieces[w][r].colour == "XStone" || all_pieces[w][r].colour == "XVirus"):
								all_pieces[w][r].durability -= 1
								all_pieces[w][r].crack_piece()
							elif (!all_pieces[w][r].matched):
								all_pieces[w][r].matched = true
								round_matched += 1
								colour_count(all_pieces[w][r])
						y_pos = (negative_c - 8) * 64 + 32
						get_node("NegDiagonalLightning").visible = true
						get_node("NegDiagonalLightning").position = Vector2(720, y_pos)
					get_node("Lightning_Timer").start(0.5)
	recolour_for_exclusion()

func match_special_blocks():
	for x in width:
		for y in height:
			# If this piece is matched and special...
			if (all_pieces[x][y].matched && all_pieces[x][y].special):
				var neighbours = get_neighbours(x, y, true)
				for n in neighbours:
					if (all_pieces[n.x][n.y].fixed):
						pass
					elif (all_pieces[n.x][n.y].colour == "Stone" || all_pieces[n.x][n.y].colour == "Virus" || all_pieces[n.x][n.y].colour == "XStone" || all_pieces[n.x][n.y].colour == "XVirus"):
						all_pieces[n.x][n.y].durability -= 1
						all_pieces[n.x][n.y].crack_piece()
					elif (!all_pieces[n.x][n.y].matched):
						all_pieces[n.x][n.y].matched = true
						round_matched += 1
						colour_count(all_pieces[n.x][n.y])

func _on_collapse_timer_timeout():
	collapse_columns()
	collapse_needed = false

func _on_clear_timer_timeout():
	cross_matched = count_corners()
	vertical_matched += count_vertical_matches()
	horizontal_matched += count_horizontal_matches()
	diag_cross_matched = count_diag_corners()
	positive_diagonal_matched = count_positive_diagonal_matches()
	negative_diagonal_matched = count_negative_diagonal_matches()
	spawn_special_blocks()
	crack_hard_blocks()
	match_special_blocks()
	clear_matches()
	clear_broken()
	var pitch_shift = 0.7 + (round_matched / 10.0)
	get_node("/root/BaseScene/AudioManager").play_match(pitch_shift)

func _on_refill_timer_timeout():
	print("Energy Matched: " + str(energy_matched))
	refill_board()
	countdown_targets()
	if (new_target_needed):
		# Add a new target for the removed one
		add_target(randi_range(0, width - 1), randi_range(0, height - 1))
		new_target_needed = false
	countdown_viruses()
	var multiplier = score_multiplier[min(round_matched, 12)] * perk_multiplier * temp_multiplier
	temp_multiplier = 1.0
	var base_score = round_matched * multiplier * 100
	print("Base score = " + str(base_score))
	var total_efficiency = 1.0
	for v in vertical_matched - 2:
		#base_score *= get_parent().vertical_multiplier
		total_efficiency = total_efficiency * get_parent().vertical_multiplier
	for h in horizontal_matched - 2:
		#base_score *= get_parent().horizontal_multiplier
		total_efficiency = total_efficiency * get_parent().horizontal_multiplier
	for c in cross_matched - 2:
		#base_score *= get_parent().cross_multiplier
		total_efficiency = total_efficiency * get_parent().cross_multiplier
	for p in positive_diagonal_matched - 2:
		#base_score *= get_parent().positive_diag_multiplier
		total_efficiency = total_efficiency * get_parent().positive_diag_multiplier
	for n in negative_diagonal_matched - 2:
		#base_score *= get_parent().negative_diag_multiplier
		total_efficiency = total_efficiency * get_parent().negative_diag_multiplier
	for x in diag_cross_matched:
		#base_score *= get_parent().cross_diag_multiplier
		total_efficiency = total_efficiency * get_parent().cross_diag_multiplier
	print("Efficieny multiplier = " + str(total_efficiency))
	# Give some energy back depending on the efficiency multiplier
	var bonus_energy = 0
	if total_efficiency >= 1:
		bonus_energy = 1 - (1 / total_efficiency)
	print("Bonus energy = " + str(bonus_energy))
	print("Turns left = " + str(get_parent().turns_left))
	get_parent().add_turns(bonus_energy)
	get_parent().update_turn_counter()
	print("Reducing energy by " + str((1 - bonus_energy)))
	get_parent().reduce_effect_duration(1 - bonus_energy)
	if (round_matched >= 3):
		get_parent().add_diamonds(round_matched - 3)
		get_parent().add_score(base_score)
		total_matched += round_matched
	if (energy_matched >= 3):
		get_parent().add_turns(energy_matched - 2)
	energy_matched = 0
	print("Total matched: " + str(total_matched))
	
	if (challenge_level):
		get_parent().check_win_challenge(count_challenge_blocks())
	elif (boss_level):
		get_parent().check_win_boss(bombs_matched, bonuses_matched)
	else:
		get_parent().check_win(total_matched)
	# If the refill is caused by a virus, we don't need to age the perks/debuffs
	if (refill_caused_by_virus):
		end_turn.emit(false)
	elif (helper_move == false):
		end_turn.emit(moved)
	moved = false
	refill_caused_by_virus = false
	round_matched = 0
	vertical_matched = 0
	horizontal_matched = 0
	positive_diagonal_matched = 0
	negative_diagonal_matched = 0
	diag_cross_matched = 0
	active = true

func _on_lightning_timer_timeout():
	get_node("HorizontalLightning").visible = false
	get_node("VerticalLightning").visible = false
	get_node("PosDiagonalLightning").visible = false
	get_node("NegDiagonalLightning").visible = false

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

func countdown_targets():
	if (active_effects.has("TIME_STOP")):
		return
	print("Counting down targets...")
	for t in targets:
		var x = t.x
		var y = t.y
		if (all_pieces[x][y].colour == "bomb" || all_pieces[x][y].colour == "bonus"):
			all_pieces[x][y].matched = true
			# Make sure it expires this turn
			t.time = 1
		t.countdown()

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

func set_level(level, challenge = false, challenge_debuffs = "", boss = false):
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
		# THIS IS NO LONGER HOW CHALLENGE LEVELS ARE IMPLEMENTED. VARIOUS DEBUFFS CAN BE INCLUDED
		#if (level >= 6):
		#	var num_lines = min((level - 3) / 3, 5)
		#	var all_lines = range(8)
		#	all_lines.shuffle()
		#	var lines = all_lines.slice(0, num_lines)
		#	for i in range(lines.size()):
		#		if i % 2 == 0:
		#			exclude_row(lines[i])
		#		else:
		#			exclude_column(lines[i])
		var debuff_indexes = all_indexes.duplicate()
		debuff_indexes.shuffle()
		var debuff_num = 0
		var num_debuffs = len(challenge_debuffs) / 2
		for i in num_debuffs:
			var type = challenge_debuffs[i * 2]
			var value = challenge_debuffs[i * 2 + 1]
			if (type == "I"):
				for v in int(value):
					var debuff_position = debuff_indexes[debuff_num]
					var x = debuff_position % width
					var y = debuff_position / width
					var exclusion_pos = grid_to_pixel(x, y)
					var exclusion = preload("res://Scenes/exclusion_zone.tscn").instantiate()
					exclusion.position = exclusion_pos
					add_child(exclusion)
					exclusions.append(exclusion)
					debuff_num += 1
			if (type == "H"):
				for v in int(value):
					var debuff_position = debuff_indexes[debuff_num]
					var x = debuff_position % width
					var y = debuff_position / width
					var obscure_pos = grid_to_pixel(x, y)
					var obscured = preload("res://Scenes/obscured_zone.tscn").instantiate()
					obscured.position = obscure_pos
					add_child(obscured)
					move_child(obscured, -1)
					obscured_blocks.append(obscured)
					debuff_num += 1
			if (type == "D"):
				match value:
					"R":
						debuff_colours.append("red")
					"O":
						debuff_colours.append("orange")
					"Y":
						debuff_colours.append("yellow")
					"G":
						debuff_colours.append("green")
					"B":
						debuff_colours.append("blue")
					"P":
						debuff_colours.append("purple")
		challenge_level = true
	if (boss):
		print("Boss level started")
		setup_for_boss()
		boss_level = true

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
