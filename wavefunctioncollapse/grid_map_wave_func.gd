@tool
extends GridMap

# Godot ne supporte pas les types nested, c'est triste mais on fait un tool button pour nous aider
#@export var adjacency : Array[Array]
@export var adjacency : Dictionary[Globals.Blocks, AdjacencyRessource]
@export_tool_button("Step") var step_action = step

var dict_grid_map : Dictionary[Vector3i, Array] = {}


func get_cell_neighbor(cell_coords : Vector3i) -> Dictionary[Vector3i, Globals.Blocks]:
	var neighbor : Dictionary[Vector3i, Globals.Blocks]
	var delta : Vector3i
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			for dz in [-1, 0, 1]:
				delta = Vector3i(dx, dy, dz)
				if delta == Vector3i(0, 0, 0): continue
				var cell_item = get_cell_item(delta)
				neighbor[delta] = cell_item
	
	return neighbor

func get_proba():
	var used_cells := get_used_cells()
	print("used_cells")
	print(used_cells)
	dict_grid_map = {}
	#var adjacent_cells : Dictionary[Vector3i, bool] = {} # Cells sur la bordure
	var used_cells_hah_set : Dictionary[Vector3i, bool] = {} # For fast look up
	for cell in used_cells:
		used_cells_hah_set.set(cell, true)
		
	for cell_coords in used_cells:
		var neighbors := get_cell_neighbor(cell_coords)
		var current_cell := get_cell_item(cell_coords)
		var adj_at_cell_coords := adjacency[current_cell].get_adjacency_dict()
		#print("adj_at_cell_coords")
		#print(adj_at_cell_coords)
		
		for diff_n in neighbors:
			var neighbor_pos = cell_coords + diff_n
			if used_cells_hah_set.get(neighbor_pos): continue
			
			if not neighbor_pos in dict_grid_map:
				dict_grid_map.set(neighbor_pos, [])
				dict_grid_map[neighbor_pos].resize(Globals.Blocks.size())
				dict_grid_map[neighbor_pos].fill(1.0)
				
			var proba_neighbor = dict_grid_map[neighbor_pos]
			#print(adj_at_cell_coords[diff_n])
			for block in range(dict_grid_map[neighbor_pos].size()):
				if block in adj_at_cell_coords[diff_n]:
					dict_grid_map[neighbor_pos][block] *= adj_at_cell_coords[diff_n][block]
				else:
					dict_grid_map[neighbor_pos][block] *= 0.0
					
			
			#for block in range(proba_neighbor.size()):
				#var proba_adj = adj_at_cell_coords[diff_n][current_cell] if\
				#current_cell in adj_at_cell_coords[diff_n] else 0.0
				#dict_grid_map[neighbor_pos][block] *= proba_adj
	
	# Normalisation des probas
	for cell_cooords in dict_grid_map:
		var probas_array = dict_grid_map[cell_cooords]
		var sum = probas_array.reduce(func(a, b): return a+b)
		for block in range(probas_array.size()):
			if sum < 0.001:
				dict_grid_map[cell_cooords][block] = 1.0 / Globals.Blocks.size()
			else:
				dict_grid_map[cell_cooords][block] /= sum

	print(dict_grid_map)
	print("----\n---\n---\n---")

# Oui on utilise Shanon comme des sigma, les autres betas sur internet disent "entropy = nb de possibilites", mais on est sigma ici
func calculate_entropy(cell_coords : Vector3i):
	var proba_array := dict_grid_map[cell_coords]
	print(proba_array)
	var entropy = 0.0
	for prob in proba_array:
		entropy += -(prob+0.001) * log(prob+0.001) # I'm afraid of log(0) guys
	return entropy
	
func weighted_random_choice_index(weights: Array[float]) -> int:
	if weights.is_empty():
		printerr("weighted_random_choice_index: Input weights array cannot be empty.")
		return -1

	var total_weight: float = 0.0
	for w in weights:
		if w < 0.0:
			printerr("weighted_random_choice_index: Weights cannot be negative.")
			return -1 
		total_weight += w

	if total_weight <= 0.0:
		return randi() % weights.size()

	var rnd: float = randf() * total_weight
	for i in range(weights.size()):
		var w = weights[i]
		rnd -= w
		if rnd <= 0.0:
			return i

	# Fallback (due to potential float inaccuracies)
	return weights.size() - 1

func step():
	get_proba()
	print(dict_grid_map)
	var lowest_entropy = 100.0
	var best_cell_coords : Vector3i
	for cell_coords in dict_grid_map.keys():
		var entropy = calculate_entropy(cell_coords)
		print("cell_coords {} entropy {}".format([cell_coords, entropy], "{}"))
		if entropy < lowest_entropy:
			lowest_entropy = entropy
			best_cell_coords = cell_coords
	
	var arr_float : Array[float] = Array(dict_grid_map[best_cell_coords], TYPE_FLOAT, "", null)
	var best_cell = weighted_random_choice_index(arr_float)
	
	
	if not best_cell in Globals.ShouldRotate:
		set_cell_item(best_cell_coords, best_cell)
	else:
		# Rotate 90 degrees around the Y-axis
		var rotation_axis = Vector3.UP
		var rotation_angle_rad = deg_to_rad(90)
		var desired_basis = Basis.IDENTITY.rotated(rotation_axis, rotation_angle_rad)
		var orientation_index = get_orthogonal_index_from_basis(desired_basis)

		set_cell_item(best_cell_coords, best_cell, orientation_index)
		
	
