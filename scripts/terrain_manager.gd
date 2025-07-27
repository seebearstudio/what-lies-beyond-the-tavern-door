@tool
class_name TerrainManager extends Node

@export var regenerate : bool = false

const PLANE_SIZE : int = 256
var time : float = 0.0

func _ready() -> void:
	initialize()

func _process(_delta: float) -> void:
	handle_regeneration()
	handle_chunk_offset()

func _physics_process(delta: float) -> void:
	handle_time(delta)
	for child in get_children():
		if child is TerrainWater:
			handle_oscillation(child)

func initialize() -> void:
	for child in get_children():
		if child is TerrainChunk:
			if is_inside_tree():
				child.terrain_biome.noise = FastNoiseLite.new()
				child.previous_position = child.position
				generate_terrain(child)

func handle_oscillation(_water : TerrainWater) -> void:
	_water.position.y = sin(time * _water.oscillation_speed) * _water.wave_amplitude

func handle_time(_delta: float) -> void:
	time += _delta
	if time > 60.0:
		time = 0.0

func handle_regeneration() -> void:
	if regenerate:
		regenerate = false
		for child in get_children():
			if child is TerrainChunk:
				generate_terrain(child)

func handle_chunk_offset() -> void:
	for child in get_children():
		if child is TerrainChunk:
			if not child.previous_position == child.position:
				child.previous_position = child.position
				child.terrain_biome.noise.offset = Vector3(child.position.x,child.position.z,0)
				generate_terrain(child)

func generate_terrain(_chunk : TerrainChunk) -> void:
	if is_inside_tree():
		update_mesh(_chunk,_chunk.chunk_resolution,_chunk.chunk_height,_chunk.terrain_biome.noise)
		generate_collider(_chunk)

func update_mesh(_mesh_instance : MeshInstance3D, _resolution : int,_chunk_height : float = 0.0, _noise : FastNoiseLite = null) -> void:
	var plane : PlaneMesh = PlaneMesh.new()
	plane.subdivide_depth = _resolution
	plane.subdivide_width = _resolution
	plane.size = Vector2(PLANE_SIZE,PLANE_SIZE)
	
	var plane_arrays := plane.get_mesh_arrays()
	var vertex_array : PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_VERTEX]
	var normal_array : PackedVector3Array = plane_arrays[ArrayMesh.ARRAY_NORMAL]
	var tangent_array : PackedFloat32Array = plane_arrays[ArrayMesh.ARRAY_TANGENT]
	
	for i in vertex_array.size():
		var vertex := vertex_array[i]
		var normal := Vector3.UP
		var tangent := Vector3.RIGHT

		if _noise and not _noise == null:
			vertex.y = get_height(_mesh_instance,_noise,vertex.x,vertex.z)
			normal = get_normal(_mesh_instance,_noise,vertex.x,vertex.z)
			tangent = normal.cross(Vector3.UP)

		vertex_array[i] = vertex
		normal_array[i] = normal
		tangent_array[4 * i] = tangent.x
		tangent_array[4 * i + 1] = tangent.y
		tangent_array[4 * i + 2] = tangent.z

	var array_mesh := ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, plane_arrays)
	_mesh_instance.mesh = array_mesh

func get_height(_chunk : TerrainChunk,_noise : FastNoiseLite,_x : float,_y : float) -> float:
	var new_height : float = _noise.get_noise_2d(_x,_y) * _chunk.chunk_height
	return new_height

func modify_noise(_new_height : float) -> float:
	# <TODO> Add means to modify noise value to create mountain ranges, plateaus, etcs.
	return _new_height

func get_normal(_chunk : TerrainChunk,_noise : FastNoiseLite,_x : float,_y : float) -> Vector3:
	var epsilon : float = float(PLANE_SIZE) / _chunk.chunk_height
	var normal : Vector3 = Vector3(
		(get_height(_chunk,_noise,_x + epsilon,_y) - get_height(_chunk,_noise,_x - epsilon,_y)) / (2.0 * epsilon),
		1.0,
		(get_height(_chunk,_noise,_x,_y + epsilon) - get_height(_chunk,_noise,_x,_y - epsilon)) / (2.0 * epsilon)
	)
	return normal.normalized()

func generate_collider(_chunk : TerrainChunk) -> void:
	if _chunk.get_child_count() > 0:
		for child in _chunk.get_children():
			child.queue_free()
	_chunk.create_trimesh_collision()
