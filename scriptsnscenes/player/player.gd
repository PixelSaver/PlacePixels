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
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += GRAVITY * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
	
	move_and_slide()


var up_down_deadzone : float = 1e-7
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotation.y -= event.relative.x * mouse_sensitivity
		var rot_y = head.rotation.x - event.relative.y * mouse_sensitivity
		rot_y = clamp(rot_y, -PI/2.+up_down_deadzone, PI/2.-up_down_deadzone)
		head.rotation.x = rot_y
