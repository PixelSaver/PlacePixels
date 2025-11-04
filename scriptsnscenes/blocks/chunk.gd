extends MeshInstance3D
class_name Chunk

const CHUNK_SIZE = 16
const CHUNK_HEIGHT = 256

var blocks : Array = []
var chunk_position : Vector3i = Vector3i.ZERO

@onready var default_block = BlockRegistry.get_block("air")

# Face vertices for cube (send help)
const VERTICES = {
	"top": [
		Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 1, 0)
	],
	"bottom": [
		Vector3(0, 0, 1), Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1)
	],
	"left": [
		Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(0, 1, 0)
	],
	"right": [
		Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(1, 1, 1)
	],
	"front": [
		Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(0, 1, 1)
	],
	"back": [
		Vector3(1, 0, 0), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(1, 1, 0)
	]
}
const NORMALS = {
	"top": Vector3.UP,
	"bottom": Vector3.DOWN,
	"left": Vector3.LEFT,
	"right": Vector3.RIGHT,
	"front": Vector3.FORWARD,
	"back": Vector3.BACK
}
# UV coordinates for block faces (placeholder since no texture atlas yupeuypep)
const UVS = [
	Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)
]

func _init(pos: Vector3i = Vector3i.ZERO):
	chunk_position = pos
	_initialize_blocks()

## Initialize 3D array for block storage
func _initialize_blocks():
	blocks = []
	for x in range(CHUNK_SIZE):
		blocks.append([])
		for y in range(CHUNK_HEIGHT):
			blocks[x].append([])
			for z in range(CHUNK_SIZE):
				blocks[x][y].append(default_block)
				#TODO Figure out if i want .duplicate() for every instance??

## Set the block at the local coords x, y, z of the chunk
func set_block(x: int, y: int, z: int, block_type: int):
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_HEIGHT and z >= 0 and z < CHUNK_SIZE:
		blocks[x][y][z] = block_type
		return
	assert("One of x y z failed in set_block: (%s, %s, %s)" % [x, y, z])

## Get the block at the local coords x, y, z of the chunk
func get_block(x: int, y: int, z: int) -> int:
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_HEIGHT and z >= 0 and z < CHUNK_SIZE:
		return blocks[x][y][z]
	assert("One of x y z failed in get_block: (%s, %s, %s)" % [x, y, z])
	return default_block

## Check if block is transparent 
func is_block_transparent(block_id: int) -> bool:
	return BlockRegistry.get_block_by_id(block_id).is_transparent

func build_mesh():
	"""Generate mesh for this chunk with face culling"""
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_HEIGHT):
			for z in range(CHUNK_SIZE):
				var block_type = blocks[x][y][z]
				
				# Skip air blocks
				if block_type == default_block:
					continue
				
				var block_pos = Vector3(x, y, z)
				
				# Check each face and add if exposed
				if is_face_visible(x, y + 1, z):
					_add_face(surface_tool, block_pos, "top", block_type)
				if is_face_visible(x, y - 1, z):
					_add_face(surface_tool, block_pos, "bottom", block_type)
				if is_face_visible(x - 1, y, z):
					_add_face(surface_tool, block_pos, "left", block_type)
				if is_face_visible(x + 1, y, z):
					_add_face(surface_tool, block_pos, "right", block_type)
				if is_face_visible(x, y, z + 1):
					_add_face(surface_tool, block_pos, "front", block_type)
				if is_face_visible(x, y, z - 1):
					_add_face(surface_tool, block_pos, "back", block_type)
	
	surface_tool.generate_normals()
	mesh = surface_tool.commit()

	create_trimesh_collision()

## Check if a face should be rendered (adjacent block is transparent)
func is_face_visible(x: int, y: int, z: int) -> bool:
	var adjacent_block = get_block(x, y, z)
	return is_block_transparent(adjacent_block)

func _add_face(surface_tool: SurfaceTool, pos: Vector3, face: String, block_type: int):
	"""Add a single face to the mesh"""
	var verts = VERTICES[face]
	var normal = NORMALS[face]
	
	# Add vertices in correct order for triangle strip
	for i in range(4):
		surface_tool.set_normal(normal)
		surface_tool.set_uv(UVS[i])
		surface_tool.set_color(_get_block_color(block_type, face))
		surface_tool.add_vertex(pos + verts[i])
	
	# Two triangles per face
	var offset = surface_tool.get_vertex_count() - 4
	surface_tool.add_index(offset + 0)
	surface_tool.add_index(offset + 1)
	surface_tool.add_index(offset + 2)
	
	surface_tool.add_index(offset + 0)
	surface_tool.add_index(offset + 2)
	surface_tool.add_index(offset + 3)

func _get_block_color(block_id:int, face:String):
	#TODO Fix and actually read color?
	return Color.BEIGE
