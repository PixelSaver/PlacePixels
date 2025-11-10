extends Node
class_name WorldGen

## Dictionary<Vector2i, Chunk>
var loaded_chunks : Dictionary = {}
var rebuild_queue: Array[Vector2i] = []
const MAX_REBUILDS_PER_FRAME = 1
var noise : FastNoiseLite

func _ready():
	_setup_noise()
	Global.world_gen = self
	await BlockRegistry.blocks_loaded
	for x in range(-2,2):
		for y in range(-2,2):
			add_chunk(Vector2i(x, y))

	for chunk in loaded_chunks.values():
		_generate_noise_world(chunk)

	#await get_tree().process_frame
	for chunk in loaded_chunks.values():
		chunk.build_mesh(_get_neighbor_chunks(chunk.chunk_position))
	
	Global.player_chunk_update.connect(_on_player_chunk_update)
	
	# Spawn player above ground
	var zchunk = get_chunk(Vector2i.ZERO) as Chunk
	var idx = 0
	var local_player_pos = Chunk.to_chunk_space(Global.player.global_position)
	while zchunk.get_block_id(Vector3i(local_player_pos.x, idx, local_player_pos.z)) != 0:
		idx += 1
	Global.player.global_position = Vector3i(local_player_pos.x, idx, local_player_pos.z)
	
	delete_folder_recursive("user://worlds/%s" % Settings.world_name)

func _setup_noise():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX       # or TYPE_PERLIN, etc.
	noise.frequency = 0.01                              # controls scale of features
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM # fractal for multi‑octave
	noise.fractal_octaves = 4
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5

func _process(_delta: float) -> void:
	for i in min(MAX_REBUILDS_PER_FRAME, rebuild_queue.size()):
		var chunk_pos = rebuild_queue.pop_front()
		if loaded_chunks.has(chunk_pos):
			await get_tree().process_frame
			if loaded_chunks.has(chunk_pos):
				loaded_chunks[chunk_pos].build_mesh(_get_neighbor_chunks(chunk_pos))


## Adds a chunk to the world, and returns the chunk.
## If there is a chunk in that position already, return that chunk
## Done in Chunk space, so its technically Vector2i(floor(global_vec.x/CHUNK_SIZE), floor(global_vec.z/CHUNK_SIZE)
func add_chunk(pos: Vector2i) -> Chunk:
	if loaded_chunks.has(pos):
		return loaded_chunks[pos]

	var new_chunk = Chunk.new(pos)
	new_chunk.chunk_position = pos
	new_chunk.position = Vector3i(pos.x * Chunk.CHUNK_SIZE, 0, pos.y * Chunk.CHUNK_SIZE)
	add_child(new_chunk)
	loaded_chunks[pos] = new_chunk
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
func _generate_noise_world(chunk: Chunk):
	if not noise: await get_tree().process_frame
	for x in range(Chunk.CHUNK_SIZE):
		for z in range(Chunk.CHUNK_SIZE):
			if not chunk: continue
			# Get noise value (-1..1), map to a height
			var n = noise.get_noise_2d(x + chunk.global_position.x, z + chunk.global_position.z)
			var height = int((n + 1) * 10)  # scale to 0-10 blocks

			for y in range(height):
				var block_id = BlockIDs.STONE  # default
				
				if y == height - 1:
					block_id = BlockIDs.GRASS  # top block
				elif y >= height - 4:
					block_id = BlockIDs.DIRT  # dirt layers under grass
				
				chunk.set_block(Vector3i(x, y, z), block_id)

## Helper: gather neighboring chunks for proper face culling
func _get_neighbor_chunks(center_pos: Vector2i) -> Dictionary:
	var neighbors := {}
	for dx in [-1,0,1]:
		for dz in [-1,0,1]:
			var pos = center_pos + Vector2i(dx, dz)
			if loaded_chunks.has(pos):
				neighbors[pos] = loaded_chunks[pos]
	return neighbors

func _on_player_chunk_update(player_chunk_pos:Vector2i):
	var chunks_in_render: Array[Vector2i] = []

	for dx in range(-Settings.render_distance, Settings.render_distance + 1):
		for dz in range(-Settings.render_distance, Settings.render_distance + 1):
			if dx*dx + dz*dz <= Settings.render_distance * Settings.render_distance:
				chunks_in_render.append(player_chunk_pos + Vector2i(dx, dz))


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
		if not loaded_chunks.has(chunk_pos):
			rebuild_queue.append(chunk_pos)
			#loaded_chunks[chunk_pos].build_mesh(_get_neighbor_chunks(chunk_pos))

func delete_folder_recursive(folder_path: String) -> void:
	var dir = DirAccess.open(folder_path)
	if dir == null:
		print("Folder does not exist: ", folder_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = folder_path + "/" + file_name
			if dir.current_is_dir():
				# Recursively delete subfolder
				delete_folder_recursive(full_path)
			else:
				dir.remove(file_name) # removing file inside opened folder
		file_name = dir.get_next()
	dir.list_dir_end()
	
	# Close current DirAccess and remove the folder itself
	dir = null
	var parent_dir = DirAccess.open(folder_path.get_base_dir())
	if parent_dir:
		parent_dir.remove(folder_path.get_file())
		#parent_dir.
	print("Deleted folder and all contents: ", folder_path)

func _load_chunk(chunk_pos:Vector2i):
	if loaded_chunks.has(chunk_pos):
		return
	var added_chunk = add_chunk(chunk_pos)
	if added_chunk.load_chunk(Settings.world_name):
		added_chunk.build_mesh(_get_neighbor_chunks(chunk_pos))
	else:
		_generate_noise_world(added_chunk)
func _unload_chunk(chunk_pos:Vector2i):
	if not loaded_chunks.has(chunk_pos):
		return
	var chunk = loaded_chunks[chunk_pos]
	chunk.save_chunk(Settings.world_name)
	loaded_chunks.erase(chunk_pos)
	remove_child(chunk)
	chunk.queue_free()
