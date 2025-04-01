@tool
extends TileMapLayer

# ---------------------
# Definir les variables
# ---------------------

# largeur, longeur du labyrinte
@export var WIDTH : int
@export var HEIGHT : int

# Les boutons
@export_tool_button("Init") var init_action = init_maze
@export_tool_button("Step") var step_action = generate_maze_step
@export_tool_button("All") var all_action = generate_map_all
@export_tool_button("All with wait") var all_wait_action = generate_map_all_wait

const TILE_FLOOR = Vector2i(0, 0)
const TILE_WALL = Vector2i(1, 0)
var current_pos = Vector2i(0, 0)

var undo_stack : Array[Vector2i] = [current_pos] # Pile des positions explores, on depopera la pile pour le backtracking
var explored : Dictionary[Vector2i, bool] # Stock les positions explores
# Pas besoin d'init a false pour explored, contrairement python la valeur d'une cle pas dans le dico, est null. Qui est interprete comme false en gdscript

# ---------------------
# Fonctions utilitaires
# ---------------------

func set_tile(pos : Vector2i, val : Vector2i) -> void:
	assert(pos.x >= 0 && pos.x < WIDTH, "x has bad value, x is {}, but should be beetwen 0 and {}".format([pos.x, WIDTH], "{}"))
	assert(pos.y >= 0 && pos.y <  HEIGHT, "y has bad value, y is {}, but should be beetwen 0 and {}".format([pos.y, HEIGHT], "{}"))
	set_cell(pos, 0, val)

# Renvoie une direction possible depuis une position dans le labyrinte
func get_random_possible_dir(current_pos : Vector2i):
	var all_dir = [2*Vector2i.UP, 2*Vector2i.DOWN, 2*Vector2i.RIGHT, 2*Vector2i.LEFT]
	var possible_dir = []
	for dir in all_dir:
		var next_pos = current_pos + dir
		var can_be_explored = not explored.get(next_pos) \
		&& next_pos.x >= 0 && next_pos.x < WIDTH && next_pos.y >= 0 && next_pos.y < HEIGHT
		
		if can_be_explored:
			possible_dir.append(dir)
	
	if possible_dir.is_empty():
		return null
	
	return possible_dir.pick_random()

# Va dans la direction dir, pour agrandir le labyrinthe
func path_move(dir : Vector2i) -> void:
	var next_pos = current_pos + dir
	var passway = current_pos + dir / 2
	set_tile(passway, TILE_FLOOR)
	set_tile(next_pos, TILE_FLOOR)
	explored[next_pos] = true
	undo_stack.append(next_pos)
	current_pos = next_pos

# Initialize le labyrinthe
func init_maze() -> void:
	print("init map")
	current_pos = Vector2i(0, 0)
	undo_stack = [current_pos]
	explored = {}
	clear() # fonction de TileMapLayer, clear les tiles
	
	current_pos = Vector2i(0, 0)
	explored[current_pos] = true
	for x in range(WIDTH):
		for y in range(HEIGHT):
			set_cell(Vector2i(x, y), 0, TILE_WALL) # fonction de TileMapLayer

func _ready() -> void:
	print("ready")
	
# ----------------------------------
# Fonctions appeles par les boutons
# ----------------------------------

func generate_maze_step() -> void:
	var next_dir = get_random_possible_dir(current_pos)
	
	# Si pas de voisins (next_dir est vide), alors on va en arriere
	while not next_dir:
		print("going back")
		current_pos = undo_stack.pop_back()
		next_dir = get_random_possible_dir(current_pos)
			
	print("path move")
	path_move(next_dir)

func generate_map_all() -> void:
	while not undo_stack.is_empty():
		generate_maze_step()
		
func generate_map_all_wait() -> void:
	while not undo_stack.is_empty():
		generate_maze_step()
		await get_tree().create_timer(0.01).timeout
