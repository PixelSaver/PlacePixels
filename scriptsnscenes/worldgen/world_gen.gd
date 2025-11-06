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
	if loaded_chunks.has(pos):
		print("⚠️⚠️⚠️ add_chunk called for %s but it ALREADY EXISTS in loaded_chunks!" % str(pos))
		print("   Existing chunk: %s" % str(loaded_chunks[pos]))
		print("   Stack trace:")
		print_stack()
		return loaded_chunks[pos]
	
	print("Creating NEW chunk at %s" % str(pos))
	var new_chunk = Chunk.new(pos)
	new_chunk.chunk_position = pos
	new_chunk.position = Vector3i(pos.x * Chunk.CHUNK_SIZE, 0, pos.y * Chunk.CHUNK_SIZE)
	add_child(new_chunk)
	loaded_chunks[pos] = new_chunk
	print("  Chunk added to scene tree, children count: %d" % get_child_count())
	return new_chunk

## Return chunk given chunk-space coordinates
func get_chunk(pos: Vector2i):
	if loaded_chunks.has(pos):
		return loaded_chunks[pos]
	return null
## Return chunk given global_coordinates
func get_chunk_global(global_pos: Vector3i) -> Chunk:
	var pos = Chunk.global_to_chunk_coords(global_pos)
	return get_chunk(pos)

## Return chunk given chunk-space coordinates but will make one if none exists yet
func get_or_create_chunk(pos: Vector2i) -> Chunk:
	if loaded_chunks.has(pos):
		return loaded_chunks[pos]
	return add_chunk(pos)
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

func _on_player_chunk_update(player_chunk_pos:Vector2i):
	print("=== PLAYER MOVED TO CHUNK %s ===" % str(player_chunk_pos))
	print("Currently loaded before update: %s" % str(loaded_chunks.keys()))
	var chunks_in_render: Array[Vector2i] = []

	for dx in range(-Settings.render_distance, Settings.render_distance + 1):
		for dz in range(-Settings.render_distance, Settings.render_distance + 1):
			if dx*dx + dz*dz <= Settings.render_distance * Settings.render_distance:
				chunks_in_render.append(player_chunk_pos + Vector2i(dx, dz))
	
	print("All chunks to render: %s" % str(chunks_in_render))
	
	var to_unload: Array[Vector2i] = []
	for pos in loaded_chunks.keys():
		if pos not in chunks_in_render:
			to_unload.append(pos)

	for pos in to_unload:
		_unload_chunk(pos)
	
	var newly_loaded: Array[Vector2i] = []
	for chunk_pos in chunks_in_render:
		if not loaded_chunks.has(chunk_pos):
			_load_chunk(chunk_pos)
			newly_loaded.append(chunk_pos)
	
	var chunks_to_rebuild: Dictionary = {}
	for chunk_pos in newly_loaded:
		# Mark this chunk and all its neighbors for rebuild
		chunks_to_rebuild[chunk_pos] = true
		for dx in [-1, 0, 1]:
			for dz in [-1, 0, 1]:
				var neighbor_pos = chunk_pos + Vector2i(dx, dz)
				if loaded_chunks.has(neighbor_pos):
					chunks_to_rebuild[neighbor_pos] = true
	for chunk_pos in chunks_to_rebuild.keys():
		if loaded_chunks.has(chunk_pos):
			loaded_chunks[chunk_pos].build_mesh(_get_neighbor_chunks(chunk_pos))
	
	print("Loaded chunks: %s" % str(loaded_chunks.keys()))
	

func _load_chunk(chunk_pos:Vector2i):
	if loaded_chunks.has(chunk_pos): 
		print("Tried to load chunk %s but it already exists!" % str(chunk_pos))
		return
	print("Loading chunk %s" % str(chunk_pos))
	var added_chunk = add_chunk(chunk_pos)
	_generate_flat_world(added_chunk)
func _unload_chunk(chunk_pos:Vector2i):
	if not loaded_chunks.has(chunk_pos):
		return
		print("Tried to unload chunk %s but it doesn't exist!" % str(chunk_pos))
	print("Unloading chunk %s" % str(chunk_pos))
	var chunk = loaded_chunks[chunk_pos]
	loaded_chunks.erase(chunk_pos)
	remove_child(chunk)
	chunk.queue_free()
