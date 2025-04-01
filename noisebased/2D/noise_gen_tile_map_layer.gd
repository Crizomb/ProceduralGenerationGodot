@tool
extends TileMapLayer

# ---------------------
# Definir les variables
# ---------------------

@export var Map : MapRessource # Non-natif, voir map_ressource.gd et map_ressource.tres

# Les boutons
@export_tool_button("Generate map") var generate_action = generate_map


func get_tile_mean(world_coords : Vector2i) -> float:
	var height_mean := 0.0
	for dx in range(tile_set.tile_size.x):
		for dy in range(tile_set.tile_size.y):
			height_mean += Map.NoiseTexture.noise.get_noise_2d(world_coords.x+dx, world_coords.y+dy)
	
	#print(height_mean)
	height_mean = height_mean / (tile_set.tile_size.x * tile_set.tile_size.y)
	height_mean = (height_mean + 1) / 2
	#print(height_mean)
	return height_mean
	
func place_cell_from_height(coords : Vector2i, height : float) -> void:
	if height < Map.DeepWater:
		# Le 3 eme parametre de set_cell (atlas_coords) est un identificateur de la tile qu'on met
		# 0, 0 et la tile en haut a gauche (coresspond a la tile bleu fonce de SpriteSheet.png)
		set_cell(coords, 0, Vector2i(0, 0))
	elif height < Map.Water:
		set_cell(coords, 0, Vector2i(1, 0))
	elif height < Map.Sand:
		set_cell(coords, 0, Vector2i(2, 0))
	elif height < Map.Grass:
		set_cell(coords, 0, Vector2i(3, 0))
	elif height < Map.Soil:
		set_cell(coords, 0, Vector2i(4, 0))
	elif height < Map.Mountain:
		set_cell(coords, 0, Vector2i(5, 0))
	elif height < Map.HighMountain:
		set_cell(coords, 0, Vector2i(6, 0))
	else: 
		set_cell(coords, 0, Vector2i(7, 0)) # Neige
		

func generate_map():
	clear()
	var nb_tile_x = Map.NoiseTexture.width / tile_set.tile_size.x
	var nb_tile_y = Map.NoiseTexture.height / tile_set.tile_size.y
	
	for tx in range(0, nb_tile_x):
		for ty in range(0, nb_tile_y):
			var world_coords = Vector2i(tx, ty) * tile_set.tile_size # Multiplication component par component
			var tiles_coords = Vector2i(tx, ty)
			place_cell_from_height(tiles_coords, get_tile_mean(world_coords))
