@tool
extends Resource
class_name AdjacencyRessource

var adjacency_dict : Dictionary[Vector3i, Dictionary]

@export_category("Up")
@export var Top : Dictionary[Globals.Blocks, float]
@export var TopForward : Dictionary[Globals.Blocks, float]
@export var TopBackward : Dictionary[Globals.Blocks, float]
@export var TopRight : Dictionary[Globals.Blocks, float]
@export var TopLeft : Dictionary[Globals.Blocks, float]
@export var TopRightForward : Dictionary[Globals.Blocks, float]
@export var TopLeftForward : Dictionary[Globals.Blocks, float]
@export var TopRightBackward : Dictionary[Globals.Blocks, float]
@export var TopLeftBackward : Dictionary[Globals.Blocks, float]
@export_category("")
@export var Forward : Dictionary[Globals.Blocks, float]
@export var Backward : Dictionary[Globals.Blocks, float]
@export var Right : Dictionary[Globals.Blocks, float]
@export var Left : Dictionary[Globals.Blocks, float]
@export var RightForward : Dictionary[Globals.Blocks, float]
@export var LeftForward : Dictionary[Globals.Blocks, float]
@export var RightBackward : Dictionary[Globals.Blocks, float]
@export var LeftBackward : Dictionary[Globals.Blocks, float]
@export_category("Down")
@export var Down : Dictionary[Globals.Blocks, float]
@export var DownForward : Dictionary[Globals.Blocks, float]
@export var DownBackward : Dictionary[Globals.Blocks, float]
@export var DownRight : Dictionary[Globals.Blocks, float]
@export var DownLeft : Dictionary[Globals.Blocks, float]
@export var DownRightForward : Dictionary[Globals.Blocks, float]
@export var DownLeftForward : Dictionary[Globals.Blocks, float]
@export var DownRightBackward : Dictionary[Globals.Blocks, float]
@export var DownLeftBackward : Dictionary[Globals.Blocks, float]

func get_adjacency_dict() -> Dictionary[Vector3i, Dictionary]:
	print("GETTING ADJACENCY")
	adjacency_dict = {
		Vector3i(0, 1, 0): Top,
		Vector3i(0, 1, 1): TopForward,
		Vector3i(0, 1, -1): TopBackward,
		Vector3i(1, 1, 0): TopRight,
		Vector3i(-1, 1, 0): TopLeft,
		Vector3i(1, 1, 1): TopRightForward,
		Vector3i(-1, 1, 1): TopLeftForward,
		Vector3i(1, 1, -1): TopRightBackward,
		Vector3i(-1, 1, -1): TopLeftBackward,
		Vector3i(0, 0, 1): Forward,
		Vector3i(0, 0, -1): Backward,
		Vector3i(1, 0, 0): Right,
		Vector3i(-1, 0, 0): Left,
		Vector3i(1, 0, 1): RightForward,
		Vector3i(-1, 0, 1): LeftForward,
		Vector3i(1, 0, -1): RightBackward,
		Vector3i(-1, 0, -1): LeftBackward,
		Vector3i(0, -1, 0): Down,
		Vector3i(0, -1, 1): DownForward,
		Vector3i(0, -1, -1): DownBackward,
		Vector3i(1, -1, 0): DownRight,
		Vector3i(-1, -1, 0): DownLeft,
		Vector3i(1, -1, 1): DownRightForward,
		Vector3i(-1, -1, 1): DownLeftForward,
		Vector3i(1, -1, -1): DownRightBackward,
		Vector3i(-1, -1, -1): DownLeftBackward,
	}
	return adjacency_dict
