extends Node
class_name WorldGen

## Dictionary<Vector2i, Chunk>
var loaded_chunks : Dictionary = {}

func _ready():
	Global.world_gen = self
	await BlockRegistry.blocks_loaded
	for x in range(-2,2):
		for y in range(-2,2):
			add_chunk(Vector2i(x, y))
	
	for chunk in loaded_chunks.values():
		_generate_flat_world(chunk)
	for chunk in loaded_chunks.values():
		chunk.build_mesh(_get_neighbor_chunks(chunk.chunk_position))
	
	Global.player_chunk_update.connect(_on_player_chunk_update)

## Adds a chunk to the world, and returns the chunk. 
## If there is a chunk in that position already, return that chunk
## Done in Chunk space, so its technically Vector2i(floor(global_vec.x/CHUNK_SIZE), floor(global_vec.z/CHUNK_SIZE)
func add_chunk(pos: Vector2i) -> Chunk:
	if not loaded_chunks.has(pos):
		var new_chunk = Chunk.new(pos)
		new_chunk.chunk_position = pos
		new_chunk.position = Vector3i(pos.x*Chunk.CHUNK_SIZE, 0, pos.y*Chunk.CHUNK_SIZE)
		add_child(new_chunk)
		loaded_chunks[pos] = new_chunk
		return new_chunk
	else:
		return loaded_chunks[pos]

## Return chunk given chunk-space coordinates
func get_chunk(pos: Vector2i) -> Chunk:
	if loaded_chunks.has(pos):
		return loaded_chunks[pos]
	return add_chunk(pos)
## Return chunk given global_coordinates
func get_chunk_global(global_pos: Vector3i) -> Chunk:
	var pos = Chunk.global_to_chunk_coords(global_pos)
	return get_chunk(pos)

## Generate a simple flat world for the given chunk
func _generate_flat_world(chunk: Chunk):
	# Fill bottom 2 blocks with stone (id = 1), rest air (0)
	for x in range(Chunk.CHUNK_SIZE):
		for z in range(Chunk.CHUNK_SIZE):
			for y in range(2):
				chunk.set_block(Vector3i(x, y, z), 1)

	# Add some random blocks above ground for testing
	for i in range(50):
		var rx = randi() % Chunk.CHUNK_SIZE
		var ry = 2 + randi() % 6
		var rz = randi() % Chunk.CHUNK_SIZE
		chunk.set_block(Vector3i(rx, ry, rz), 1)

# Helper: gather neighboring chunks for proper face culling
func _get_neighbor_chunks(center_pos: Vector2i) -> Dictionary:
	var neighbors := {}
	for dx in [-1,0,1]:
		for dz in [-1,0,1]:
			var pos = center_pos + Vector2i(dx, dz)
			if loaded_chunks.has(pos):
				neighbors[pos] = loaded_chunks[pos]
	return neighbors

func _on_player_chunk_update(new_chunk:Chunk):
	var chunks_in_render: Array[Vector2i] = []

	for dx in range(-Settings.render_distance, Settings.render_distance + 1):
		for dz in range(-Settings.render_distance, Settings.render_distance + 1):
			if dx*dx + dz*dz <= Settings.render_distance * Settings.render_distance:
				chunks_in_render.append(new_chunk.chunk_position + Vector2i(dx, dz))
	
	print("All chunks to render: %s" % str(chunks_in_render))
	
	var to_unload: Array[Vector2i] = []
	for pos in loaded_chunks.keys():
		if pos not in chunks_in_render:
			to_unload.append(pos)

	for pos in to_unload:
		_unload_chunk(pos)
	
	for chunk_pos in chunks_in_render:
		_load_chunk(chunk_pos)
	
	print("Loaded chunks: %s" % str(loaded_chunks.keys()))
	

func _load_chunk(chunk_pos:Vector2i):
	if loaded_chunks.has(chunk_pos): return
	var added_chunk = add_chunk(chunk_pos)
	_generate_flat_world(added_chunk)
	added_chunk.build_mesh()
func _unload_chunk(chunk_pos:Vector2i):
	var chunk = loaded_chunks[chunk_pos]
	loaded_chunks.erase(chunk_pos)
	chunk.queue_free()
