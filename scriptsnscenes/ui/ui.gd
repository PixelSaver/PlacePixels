extends CanvasLayer

@export var fps_label : RichTextLabel
@export_category("Hotbar")
@export var hotbar_inv_cont : Container
var hotbar_inv_slots : Array[HotbarInventorySlot] = []
var hover_idx : int = 0

func _ready() -> void:
	for child in hotbar_inv_cont.get_children():
		if child is HotbarInventorySlot: 
			hotbar_inv_slots.append(child)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var prev_slot = hotbar_inv_slots[hover_idx]

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			hover_idx += 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			hover_idx -= 1

		hover_idx = wrapi(hover_idx, 0, hotbar_inv_slots.size())
	
		var slot = hotbar_inv_slots[hover_idx]
		slot.hover_anim()
		prev_slot.unhover_anim()

func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())
