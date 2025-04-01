@tool
extends GridMap
# Moralement c'est un labyrinthe 2D, mais les graphiques sont en 3D
# Le code sera comme tile_map_layer_maze mais avec des gridmaps au lieu des tilemaps

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


const TILE_FLOOR = 1
const TILE_WALL = 0

var current_pos = Vector3i(0, 0, 0)
var undo_stack : Array[Vector3i]
var explored : Dictionary[Vector3i, bool]

func set_grid(pos : Vector3i, val : int):
	assert(pos.x >= 0 && pos.x < WIDTH, "x has bad value, x is {}, but should be beetwen 0 and {}".format([pos.x, WIDTH], "{}"))
	assert(pos.z >= 0 && pos.z <  HEIGHT, "z has bad value, z is {}, but should be beetwen 0 and {}".format([pos.z, HEIGHT], "{}"))
	set_cell_item(pos, val) #Fonction de gridmap
	
# Renvoie une direction possible depuis une position dans le labyrinte
func get_random_possible_dir(current_pos : Vector3i):
	var all_dir = [2*Vector3i.FORWARD, 2*Vector3i.LEFT, 2*Vector3i.RIGHT, 2*Vector3i.BACK]
	var possible_dir = []
	for dir in all_dir:
		var next_pos = current_pos + dir
		var can_be_explored = not explored.get(next_pos) \
		&& next_pos.x >= 0 && next_pos.x < WIDTH && next_pos.z >= 0 && next_pos.z < HEIGHT
		
		if can_be_explored:
			possible_dir.append(dir)
	
	if possible_dir.is_empty():
		return null
	
	return possible_dir.pick_random()

# Va dans la direction dir, pour agrandir le labyrinthe
func path_move(dir : Vector3i) -> void:
	var next_pos = current_pos + dir
	var passway = current_pos + dir / 2
	set_grid(passway, TILE_FLOOR)
	set_grid(next_pos, TILE_FLOOR)
	explored[next_pos] = true
	undo_stack.append(next_pos)
	current_pos = next_pos

# Initialize le labyrinthe
func init_maze() -> void:
	print("init map")
	current_pos = Vector3i(0, 0, 0)
	undo_stack = [current_pos]
	explored = {}
	clear() # fonction de GridMap, clear les tiles
	
	current_pos = Vector3i(0, 0, 0)
	explored[current_pos] = true
	for x in range(WIDTH):
		for z in range(HEIGHT):
			set_cell_item(Vector3i(x, 0, z), TILE_WALL) # fonction de GridMap

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
