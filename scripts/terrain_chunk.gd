@tool
class_name TerrainChunk extends MeshInstance3D

@export_group("Mesh Settings")
@export_range(4.0, 256.0, 4.0) var chunk_resolution : int = 32:
	set(new_resolution):
		chunk_resolution = new_resolution
		if is_inside_tree():
			terrain_manager.generate_terrain(self)
@export_range(4.0, 128.0, 4.0) var chunk_height : float = 64.0:
	set(new_height):
		chunk_height = new_height
		if is_inside_tree():
			terrain_manager.generate_terrain(self)

@export_group("Terrain Biome")
@export var terrain_biome : TerrainBiome

@export_group("Components")
@export var terrain_manager : TerrainManager
var previous_position : Vector3 = Vector3.ZERO
