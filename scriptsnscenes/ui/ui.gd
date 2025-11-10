extends CanvasLayer
class_name UI

@export var fps_label : RichTextLabel
@export_category("Hotbar")
@export var hotbar_inv_cont : Container
@export var block_label : RichTextLabel
var hotbar_inv_slots : Array[HotbarInventorySlot] = []
var hover_idx : int = 0

func _ready() -> void:
	Global.ui = self
	await BlockRegistry.blocks_loaded
	var children = hotbar_inv_cont.get_children()
	for i in range(children.size()):
		var child = children[i]
		if child is HotbarInventorySlot: 
			hotbar_inv_slots.append(child)
			child.display_block(i)
	hotbar_inv_slots[hover_idx].hover_anim()
	
	block_label.text = hotbar_inv_slots[hover_idx].stored_block.block_name
	block_label.text.capitalize()
	
## Returns the block hovered in hotbar
func get_held_block_id():
	var b_name = hotbar_inv_slots[hover_idx].stored_block.block_name
	return BlockRegistry.get_id(b_name)

func _input(event: InputEvent) -> void:
	if (event.is_action("scroll_down") or event.is_action("scroll_up")) and event.pressed:
		var prev_slot = hotbar_inv_slots[hover_idx]

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			hover_idx += 1
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			hover_idx -= 1

		hover_idx = wrapi(hover_idx, 0, hotbar_inv_slots.size())
	
		var slot = hotbar_inv_slots[hover_idx]
		
		slot.hover_anim()
		block_label.text = slot.stored_block.block_name
		block_label.text.capitalize()
		prev_slot.unhover_anim()

func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())
