extends MeshInstance3D
class_name Chunk

const CHUNK_SIZE = 16
const CHUNK_HEIGHT = 256

var blocks : Array = []
var chunk_position : Vector3i = Vector3i.ZERO

var default_block : Block 

# Face vertices for cube (send help)
const VERTICES = {
	"top": [   
		Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 1, 1)
	],
	"bottom": [
		Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0)
	],
	"left": [  
		Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(0, 0, 1)
	],
	"right": [ 
		Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(1, 1, 0), Vector3(1, 0, 0)
	],
	"front": [ 
		Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 0, 1)
	],
	"back": [  
		Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 1, 0), Vector3(0, 0, 0)
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
var vertex_count := 0

func _init(pos: Vector3i = Vector3i.ZERO):
	default_block = BlockRegistry.get_block("air")
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

## Set the block at the local coords x, y, z of the chunk, given the ID
func set_block(x: int, y: int, z: int, block_type: int):
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_HEIGHT and z >= 0 and z < CHUNK_SIZE:
		blocks[x][y][z] = BlockRegistry.get_block_by_id(block_type)
		return
	assert("One of x y z failed in set_block: (%s, %s, %s)" % [x, y, z])

## Get the block at the local coords x, y, z of the chunk
func get_block(x: int, y: int, z: int) -> Block:
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_HEIGHT and z >= 0 and z < CHUNK_SIZE:
		return blocks[x][y][z]
	assert("One of x y z failed in get_block: (%s, %s, %s)" % [x, y, z])
	return default_block

## Check if block is transparent 
func is_block_transparent(block_id: int) -> bool:
	return BlockRegistry.get_block_by_id(block_id).is_transparent

## Generate mesh for this chunk with face culling
func build_mesh():
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	surface_tool.set_material(mat)	
	vertex_count = 0
	
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_HEIGHT):
			for z in range(CHUNK_SIZE):
				assert(default_block != null, "default_block is null!")
				var block = blocks[x][y][z]
				if block.id == default_block.id:
					continue
				
				var block_pos = Vector3(x, y, z)
				
				# Check each face and add if exposed
				if is_face_visible(x, y + 1, z): _add_face(surface_tool, block_pos, "top", block.id)
				if is_face_visible(x, y - 1, z): _add_face(surface_tool, block_pos, "bottom", block.id)
				if is_face_visible(x - 1, y, z): _add_face(surface_tool, block_pos, "left", block.id)
				if is_face_visible(x + 1, y, z): _add_face(surface_tool, block_pos, "right", block.id)
				if is_face_visible(x, y, z + 1): _add_face(surface_tool, block_pos, "front", block.id)
				if is_face_visible(x, y, z - 1): _add_face(surface_tool, block_pos, "back", block.id)
	
	mesh = surface_tool.commit()
	create_trimesh_collision()

## Check if a face should be rendered (adjacent block is transparent)
func is_face_visible(x: int, y: int, z: int) -> bool:
	var adjacent_block = get_block(x, y, z)
	return is_block_transparent(adjacent_block.id)

## Add a single face to the mesh
func _add_face(surface_tool: SurfaceTool, pos: Vector3, face: String, block_type: int):
	var verts = VERTICES[face]
	var normal = NORMALS[face]
	var offset = vertex_count
	
	# Add vertices in correct order for triangle strip
	for i in range(4):
		surface_tool.set_normal(normal)
		surface_tool.set_uv(UVS[i])
		surface_tool.set_color(_get_block_color(block_type, face))
		surface_tool.add_vertex(pos + verts[i])
	
	vertex_count += 4
	
	# Two triangles per face
	surface_tool.add_index(offset + 0)
	surface_tool.add_index(offset + 1)
	surface_tool.add_index(offset + 2)
	
	surface_tool.add_index(offset + 0)
	surface_tool.add_index(offset + 2)
	surface_tool.add_index(offset + 3)

func _get_block_color(block_id:int, face:String):
	return BlockRegistry.get_block_by_id(block_id).block_colors[0] if BlockRegistry.get_block_by_id(block_id).block_colors[0] else Color.RED

## ME WHEN I ACTUALLY TRY TO MAKE THIS GO FARTHER THAN SIEGE

## Serialize chunk to dictionary for saving
func serialize() -> Dictionary:
	return {
		"position": chunk_position,
		"blocks": blocks
	}

## Load chunk from saved data
func deserialize(data: Dictionary):
	chunk_position = data.get("position", Vector3i.ZERO)
	blocks = data.get("blocks", [])
