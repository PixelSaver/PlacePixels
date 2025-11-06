extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 10
const GRAVITY = Vector3.DOWN * 20

@export var mouse_sensitivity: float = 0.01
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@export var ray : RayCast3D
@export var highlight_mesh : MeshInstance3D
#var is_crouched : bool = false
var ray_hit : Vector3i
var ray_chunk : Chunk
var ray_normal : Vector3i
var last_chunk_pos : Vector2i = Vector2i.MIN

func _ready() -> void:
	Global.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += GRAVITY * delta
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var forward := head.basis.z
	forward.y = 0
	forward = forward.normalized()
	var right := head.basis.x
	right.y = 0
	right = right.normalized()
	var direction := (right * input_dir.x + forward * input_dir.y).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	move_and_slide()
	var current_chunk_pos = Chunk.global_to_chunk_coords(Vector3i(self.global_position))
	
	if current_chunk_pos != last_chunk_pos:
		print("Player entered new chunk: %s" % str(current_chunk_pos))
		last_chunk_pos = current_chunk_pos
		Global.player_chunk = current_chunk_pos
		Global.player_chunk_update.emit(current_chunk_pos)

func _process(_delta: float) -> void:
	var res = raycast_block(camera.global_transform.origin, -camera.global_transform.basis.z)
	if res == null:
		ray_chunk = null
		ray_hit = Vector3i.MIN
		ray_normal = Vector3i.ZERO
		highlight_mesh.visible = false
		return
	
	var chunk : Chunk = Global.world_gen.get_chunk(Chunk.global_to_chunk_coords(res.pos))
	
	ray_chunk = chunk
	ray_hit = res.pos
	ray_normal = res.normal
	highlight_mesh.visible = true
	var target : Vector3 = Vector3i(ray_hit.x, ray_hit.y, ray_hit.z)
	highlight_mesh.global_position = target + Vector3.ONE * .5

var up_down_deadzone : float = 1e-7
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotation.y -= event.relative.x * mouse_sensitivity
		var rot_y = head.rotation.x - event.relative.y * mouse_sensitivity
		rot_y = clamp(rot_y, -PI/2.+up_down_deadzone, PI/2.-up_down_deadzone)
		head.rotation.x = rot_y
	elif Input.is_action_just_pressed("left_click"):
		call_deferred("_break_block")
		
		pass
	elif Input.is_action_just_pressed("right_click"):
		call_deferred("_place_block")

func _break_block():
	if ray_chunk == null or ray_hit == Vector3i.MIN: return
	var ray_hit_local = Chunk.to_chunk_space(ray_hit)
	ray_chunk.set_block(ray_hit_local, BlockIDs.AIR)
	ray_chunk.mark_block_dirty(ray_hit_local)

func _place_block():
	var target = ray_hit + ray_normal
	var target_chunk = Global.world_gen.get_chunk_global(target)
	var target_local = Chunk.to_chunk_space(target)
	if target_chunk == null or ray_hit == Vector3i.MIN or ray_normal == Vector3i.ZERO: return
	target_chunk.set_block(target_local, BlockIDs.DIRT)
	target_chunk.mark_block_dirty(target_local)

## Raycast function using Digital Differential Analyzer
func raycast_block(origin: Vector3, direction: Vector3, max_distance: float = 100.0):
	var pos = origin
	var step = Vector3i(
		1 if direction.x > 0 else -1,
		1 if direction.y > 0 else -1,
		1 if direction.z > 0 else -1,
	)

	var t_max = Vector3()
	var t_delta = Vector3()

	var voxel = Vector3i(pos)
	var normal = Vector3.ZERO

	for axis in ["x","y","z"]:
		if direction[axis] != 0:
			var boundary = float(voxel[axis] + (1 if step[axis] > 0 else 0))
			t_max[axis] = (boundary - pos[axis]) / direction[axis]
			t_delta[axis] = abs(1 / direction[axis])
		else:
			t_max[axis] = INF
			t_delta[axis] = INF

	var traveled = 0.0
	while traveled < max_distance:
		var chunk = Global.world_gen.get_chunk_global(voxel)
		if chunk:
			# Convert to chunk-local coordinates
			var local_voxel = Chunk.to_chunk_space(voxel)
			var block_id = chunk.get_block_id(local_voxel)
			if block_id != chunk.default_block_id:
				return {
					"pos": voxel,
					"normal": normal,
					"block_id": block_id
				}

		if t_max.x < t_max.y and t_max.x < t_max.z:
			voxel.x += step.x
			traveled = t_max.x
			t_max.x += t_delta.x
			normal = Vector3(-step.x, 0, 0)
		elif t_max.y < t_max.z:
			voxel.y += step.y
			traveled = t_max.y
			t_max.y += t_delta.y
			normal = Vector3(0, -step.y, 0)
		else:
			voxel.z += step.z
			traveled = t_max.z
			t_max.z += t_delta.z
			normal = Vector3(0, 0, -step.z)

	return null

## get the position of the player (feet) in the local chunk coordinates
func chunk_pos():
	return (transform.origin / Chunk.CHUNK_SIZE).floor()
