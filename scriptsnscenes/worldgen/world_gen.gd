extends Node
class_name WorldGen

var chunk: Chunk

func _ready():
	await BlockRegistry.blocks_loaded
	chunk = Chunk.new(Vector3i.ZERO)
	add_child(chunk)

	_generate_flat_world()
	chunk.build_mesh()


func _generate_flat_world():
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
