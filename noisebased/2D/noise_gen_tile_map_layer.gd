@tool
extends TileMapLayer

# ---------------------
# Definir les variables
# ---------------------

# largeur, longeur de la map
@export var WIDTH : int
@export var HEIGHT : int

# Les boutons
@export_tool_button("All") var all_action = generate_map

func generate_map():
	return
