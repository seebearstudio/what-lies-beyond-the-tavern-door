@tool
class_name TerrainWater extends MeshInstance3D

@export_group("Water Settings")
@export var depth : float = 10.0:
	set(new_depth):
		depth = new_depth
		if is_inside_tree():
			terrain_manager.update_depth(self)

@export var oscillation_speed : float = 0.8
@export var wave_amplitude : float = 0.1

@export_group("Components")
@export var terrain_manager : TerrainManager
@export var water_area3D : Area3D
