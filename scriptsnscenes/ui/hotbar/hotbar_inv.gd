extends Panel
class_name HotbarInventorySlot

@export var texture_rect : TextureRect
@export var highlight_mod : Control
var stored_block : Block
var duration := 0.5
var t : Tween

func _ready() -> void:
	self.pivot_offset = size/2.
	unhover_anim()

func display_block(block_id:int):
	if block_id >= BlockIDs.RANGE: return
	stored_block = BlockRegistry.get_block_by_id(block_id)
	#texture_rect.texture = stored_block.get_inv_texture()
	texture_rect.texture = load("res://assets/images/white_pix.png")
	texture_rect.modulate = stored_block.inventory_texture

func hover_anim():
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_parallel(true).set_trans(Tween.TRANS_QUINT)
	t.tween_property(highlight_mod, "modulate:a", 1., duration)
	t.tween_property(self, "scale", Vector2.ONE * 1.1, duration)
	t.tween_property(texture_rect, "modulate:a", 1., duration)

func unhover_anim():
	if t: t.kill()
	t = create_tween().set_ease(Tween.EASE_OUT)
	t.set_parallel(true).set_trans(Tween.TRANS_QUINT)
	t.tween_property(highlight_mod, "modulate:a", .0, duration)
	t.tween_property(self, "scale", Vector2.ONE, duration)
	t.tween_property(texture_rect, "modulate:a", 0.8, duration)
