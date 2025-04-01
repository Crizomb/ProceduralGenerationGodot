extends Resource
class_name MapRessource

@export_group("Tiles value upper thresold")
@export var DeepWater := 0.3
@export var Water := 0.4
@export var Sand := 0.45
@export var Grass := 0.6
@export var Soil := 0.65
@export var Mountain := 0.75
@export var HighMountain := 0.9

@export_group("Noise Texture")

@export var NoiseTexture : NoiseTexture2D
