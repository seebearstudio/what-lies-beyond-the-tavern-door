@tool
class_name TerrainWater extends MeshInstance3D

@export_group("Water Settings")
@export var oscillation_speed : float = 0.8
@export var wave_amplitude : float = 0.1

@export_group("Components")
@export var terrain_manager : TerrainManager
