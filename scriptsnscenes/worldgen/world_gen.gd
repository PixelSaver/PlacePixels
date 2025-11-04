extends Node
class_name WorldGen

## Dictionary<Vector3i, Chunk>
var loaded_chunks :Dictionary = {}

func _ready():
	Global.world_gen = self
	await BlockRegistry.blocks_loaded
	var chunk = add_chunk(Vector2i.ZERO)

	_generate_flat_world(chunk)
	chunk.build_mesh()

## Adds a chunk to the world, and returns the chunk. If there is a chunk in that position already, return that chunk
func add_chunk(pos: Vector2i) -> Chunk:
	if not loaded_chunks.has(pos):
		var new_chunk = Chunk.new(pos)
		add_child(new_chunk)
		loaded_chunks.set(pos, new_chunk)
		return new_chunk
	else: return loaded_chunks.get(pos)

## Return chunk given x, y in chunk space
func get_chunk(pos: Vector2i) -> Chunk:
	if loaded_chunks.has(pos):
		return loaded_chunks.get(pos)
	return add_chunk(pos)

func _generate_flat_world(chunk:Chunk):
	# Fill bottom 32 blocks with stone (id = 1), rest air (0)
	for x in range(Chunk.CHUNK_SIZE):
		for z in range(Chunk.CHUNK_SIZE):
			for y in range(2): # Ground height
				chunk.set_block(x, y, z, 1)

	# Add some random blocks so you can see culling
	for i in range(50):
		var rx = randi() % Chunk.CHUNK_SIZE
		var ry = 2 + randi() % 6
		var rz = randi() % Chunk.CHUNK_SIZE
		chunk.set_block(rx, ry, rz, 1)
