extends MeshInstance3D
class_name Chunk

const CHUNK_SIZE = 16
const CHUNK_HEIGHT = 256

## Stores non-air blocks
var blocks : Dictionary = {}
var chunk_position : Vector2i = Vector2i.ZERO
## Array of positions where the blocks have been updated
var dirty_blocks : Array[Vector3i] = []

var default_block_id := 0 

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

func _init(pos: Vector2i = Vector2i.ZERO):
	chunk_position = pos
	#if OS.is_debug_build():
		#visualize_chunk_boundary()

## Set the block at the local coords x, y, z of the chunk, given the ID
func set_block(pos: Vector3i, block_id: int):
	if not _inside(pos): return
	if block_id == default_block_id:
		blocks.erase(pos)
	else:
		blocks[pos] = block_id
	mark_block_dirty(pos)

## Get the block id at the local coords x, y, z of the chunk
func get_block_id(pos: Vector3i) -> int:
	return blocks.get(pos, default_block_id)

#func set_block(x: int, y: int, z: int, block_type: int):
	#if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_HEIGHT and z >= 0 and z < CHUNK_SIZE:
		#blocks[x][y][z] = BlockRegistry.get_block_by_id(block_type)
		#return
	#assert("One of x y z failed in set_block: (%s, %s, %s)" % [x, y, z])

#func get_block(x: int, y: int, z: int) -> Block:
	#if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_HEIGHT and z >= 0 and z < CHUNK_SIZE:
		#return blocks[x][y][z]
	#assert("One of x y z failed in get_block: (%s, %s, %s)" % [x, y, z])
	#return default_block

## Check if block is transparent 
func is_block_transparent(block_id: int) -> bool:
	return BlockRegistry.get_block_by_id(block_id).is_transparent

## Generate mesh for this chunk with face culling
func build_mesh(neighbor_chunks: Dictionary = {}):
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	surface_tool.set_material(mat)
	vertex_count = 0

	for pos_key in blocks.keys():
		var block_id = blocks[pos_key]
		var pos = pos_key

		if is_face_visible_global(pos + Vector3i(0,1,0), neighbor_chunks): _add_face(surface_tool, pos, "top", block_id)
		if is_face_visible_global(pos + Vector3i(0,-1,0), neighbor_chunks): _add_face(surface_tool, pos, "bottom", block_id)
		if is_face_visible_global(pos + Vector3i(-1,0,0), neighbor_chunks): _add_face(surface_tool, pos, "left", block_id)
		if is_face_visible_global(pos + Vector3i(1,0,0), neighbor_chunks): _add_face(surface_tool, pos, "right", block_id)
		if is_face_visible_global(pos + Vector3i(0,0,1), neighbor_chunks): _add_face(surface_tool, pos, "front", block_id)
		if is_face_visible_global(pos + Vector3i(0,0,-1), neighbor_chunks): _add_face(surface_tool, pos, "back", block_id)

	mesh = surface_tool.commit()
	create_trimesh_collision()

## Checks if a block face should be visible, including neighbor chunks
func is_face_visible_global(pos: Vector3i, neighbor_chunks: Dictionary) -> bool:
	if pos.y < 0 or pos.y >= CHUNK_HEIGHT:
		return true

	if pos.x >= 0 and pos.x < CHUNK_SIZE and pos.z >= 0 and pos.z < CHUNK_SIZE:
		return is_block_transparent(get_block_id(pos))

	# Check neighbor chunk if needed
	var chunk_offset = Vector2i(
		(1 if (pos.x < 0 or pos.x >= CHUNK_SIZE) else 0),
		(1 if (pos.z < 0 or pos.z >= CHUNK_SIZE) else 0)
	)
	if chunk_offset != Vector2i.ZERO:
		var neighbor_key = chunk_position + chunk_offset
		if neighbor_chunks.has(neighbor_key):
			var neighbor = neighbor_chunks[neighbor_key]
			var nx = (pos.x + CHUNK_SIZE) % CHUNK_SIZE
			var nz = (pos.z + CHUNK_SIZE) % CHUNK_SIZE
			return is_block_transparent(neighbor.get_block_id(Vector3i(nx, pos.y, nz)))
		return true # treat missing neighbor as air

	return true

## Add a single face to the mesh
func _add_face(surface_tool: SurfaceTool, pos: Vector3i, face: String, block_id: int):
	var verts = VERTICES[face]
	var normal = NORMALS[face]
	var offset = vertex_count
	var block = BlockRegistry.get_block_by_id(block_id)

	for i in range(4):
		surface_tool.set_normal(normal)
		surface_tool.set_uv(UVS[i])
		#surface_tool.set_color(block.get_color(face))
		surface_tool.set_color(block.block_colors[0])
		surface_tool.add_vertex(Vector3(pos.x, pos.y, pos.z) + verts[i])

	vertex_count += 4

	surface_tool.add_index(offset + 0)
	surface_tool.add_index(offset + 1)
	surface_tool.add_index(offset + 2)
	
	surface_tool.add_index(offset + 0)
	surface_tool.add_index(offset + 2)
	surface_tool.add_index(offset + 3)

## Return the chunk position for a given global position
static func global_to_chunk_coords(global_vec:Vector3i) -> Vector2i:
	return Vector2(float(global_vec.x)/float(CHUNK_SIZE), float(global_vec.z)/float(CHUNK_SIZE)).floor()
static func chunk_to_global_coords(chunk_coords:Vector3i, chunk:Chunk) -> Vector3i:
	return Vector3i(chunk_coords.x + chunk.chunk_position.x, chunk_coords.y, chunk_coords.z + chunk.chunk_position.y)

func mark_block_dirty(pos: Vector3i):
	dirty_blocks.append(pos)

func _process(_delta):
	if dirty_blocks.size() > 0:
		_rebuild_dirty_blocks()

func _rebuild_dirty_blocks():
	if dirty_blocks.size() == 0: return
	dirty_blocks.clear()
	build_mesh()
	# Remove the previous collision shape lol
	if self.get_children().size() > 0:
		for child in get_children():
			if child is StaticBody3D or child is CollisionShape3D:
				remove_child(child)
				child.queue_free()
	create_trimesh_collision()
	
	# I GIVE UP EVERYTHING BELOW CAN DIE
	#return
	#var positions = dirty_blocks.duplicate()
	#dirty_blocks.clear()
#
	#var surface_tool = SurfaceTool.new()
	#surface_tool.create_from(mesh, 0)
	##surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
#
	#var mat = StandardMaterial3D.new()
	#mat.vertex_color_use_as_albedo = true
	#surface_tool.set_material(mat)
#
	#vertex_count = 0
#
	## We will only emit faces around dirty blocks and their neighbors
	#var visited := {}
#
	#for p in positions:
		#for o in [
			#Vector3i(0,0,0),
			#Vector3i(1,0,0), Vector3i(-1,0,0),
			#Vector3i(0,1,0), Vector3i(0,-1,0),
			#Vector3i(0,0,1), Vector3i(0,0,-1)
		#]:
			#var np = p + o
			#if not _inside(np):
				#continue
			#var key = str(np)
			#if visited.has(key):
				#continue
			#visited[key] = true
#
			#var block = blocks[np.x][np.y][np.z]
			#if block.id == default_block.id:
				#continue
#
			#var world_pos = Vector3(np.x, np.y, np.z)
#
			## same visibility rules as full chunk mesh
			#if is_face_visible(np.x, np.y+1, np.z): _add_face(surface_tool, world_pos, "top", block.id)
			#if is_face_visible(np.x, np.y-1, np.z): _add_face(surface_tool, world_pos, "bottom", block.id)
			#if is_face_visible(np.x-1, np.y, np.z): _add_face(surface_tool, world_pos, "left", block.id)
			#if is_face_visible(np.x+1, np.y, np.z): _add_face(surface_tool, world_pos, "right", block.id)
			#if is_face_visible(np.x, np.y, np.z+1): _add_face(surface_tool, world_pos, "front", block.id)
			#if is_face_visible(np.x, np.y, np.z-1): _add_face(surface_tool, world_pos, "back", block.id)
#
	#mesh = surface_tool.commit()
#
	## Only create collision if mesh contains geometry
	#if mesh and mesh.get_surface_count() > 0:
		#create_trimesh_collision()

func visualize_chunk_boundary():
	# Remove previous boundary visualizers
	for child in get_children():
		if child.name == "ChunkBoundary":
			remove_child(child)
			child.queue_free()

	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "ChunkBoundary"

	var cube_mesh = BoxMesh.new()
	cube_mesh.size = Vector3(Chunk.CHUNK_SIZE, Chunk.CHUNK_HEIGHT, Chunk.CHUNK_SIZE)
	mesh_instance.mesh = cube_mesh

	# Use wireframe material for visualization
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0, 1, 0, 0.2)  # semi-transparent green
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.flags_transparent = true
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.flags_albedo_from_vertex_color = false
	mesh_instance.material_override = mat

	# Center the cube around the chunk
	mesh_instance.transform.origin = Vector3(Chunk.CHUNK_SIZE / 2., Chunk.CHUNK_HEIGHT / 2., Chunk.CHUNK_SIZE / 2.)

	add_child(mesh_instance)

## Turns the global position into local chunk coordinates
static func to_chunk_space(global_pos:Vector3i) -> Vector3i:
	return Vector3i(global_pos.x%CHUNK_SIZE, global_pos.y, global_pos.z%CHUNK_SIZE)

func _inside(p: Vector3i) -> bool:
	return p.x >= 0 and p.x < CHUNK_SIZE \
		and p.y >= 0 and p.y < CHUNK_HEIGHT \
		and p.z >= 0 and p.z < CHUNK_SIZE

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
