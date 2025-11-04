extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 10
const GRAVITY = Vector3.DOWN * 20

@export var mouse_sensitivity: float = 0.01
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@export var ray : RayCast3D
#var is_crouched : bool = false


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


var up_down_deadzone : float = 1e-7
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotation.y -= event.relative.x * mouse_sensitivity
		var rot_y = head.rotation.x - event.relative.y * mouse_sensitivity
		rot_y = clamp(rot_y, -PI/2.+up_down_deadzone, PI/2.-up_down_deadzone)
		head.rotation.x = rot_y
	elif Input.is_action_just_pressed("left_click"):
		pass

## Raycast function using Digital Differential Analyzer
func raycast_block(chunk: Chunk, origin: Vector3, direction: Vector3, max_distance: float = 100.0) -> Vector3i:
	var pos = origin - chunk.global_transform.origin
	var step = Vector3i(
		1 if direction.x > 0 else -1,
		1 if direction.y > 0 else -1,
		1 if direction.z > 0 else -1,
	)

	var t_max = Vector3()
	var t_delta = Vector3()

	# current voxel
	var voxel = Vector3i(pos)

	# compute t_max and t_delta for each axis
	for axis in ["x","y","z"]:
		if direction[axis] != 0:
			var voxel_boundary = float(voxel[axis] + (1 if step[axis] > 0 else 0))
			t_max[axis] = (voxel_boundary - pos[axis]) / direction[axis]
			t_delta[axis] = abs(1 / direction[axis])
		else:
			t_max[axis] = INF
			t_delta[axis] = INF

	var traveled = 0.0
	while traveled < max_distance:
		# check if block exists and is solid
		var block = chunk.get_block(voxel.x, voxel.y, voxel.z)
		if block.id != chunk.default_block.id:
			return voxel  # hit a solid block

		# step to next voxel
		if t_max.x < t_max.y and t_max.x < t_max.z:
			voxel.x += step.x
			traveled = t_max.x
			t_max.x += t_delta.x
		elif t_max.y < t_max.z:
			voxel.y += step.y
			traveled = t_max.y
			t_max.y += t_delta.y
		else:
			voxel.z += step.z
			traveled = t_max.z
			t_max.z += t_delta.z

	return Vector3i.ZERO
