extends Resource
class_name Block

@export var id : int = 0
@export var block_name : String = ""
@export var is_transparent : bool = false
@export var is_solid : bool = true
@export var break_time : float = 1.0
@export_category("Textures")
## Up, Down, Sides
@export var block_colors : Array[Color]
#TODO Change this to be texture instead of color
@export var inventory_texture : Color
#TODO
@export_category("Sounds")
#TODO

func get_inv_texture():
	#if inventory_texture is Texture:
		#return inventory_texture
	#else:
		var img: Image = load("res://assets/images/white_pix.png")
		return ImageTexture.create_from_image(img)
