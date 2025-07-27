class_name TerrainBiome extends Resource

@export_category("Terrain Biome")
@export var biome_name : String = "New Biome"

@export_group("Noise")
@export var noise : FastNoiseLite

@export_group("Noise Modifiers")
@export var exponential_modifier : bool = false
