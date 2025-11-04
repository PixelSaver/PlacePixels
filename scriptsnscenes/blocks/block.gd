extends Resource
class_name Block

@export var id : int = 0
@export var block_name : String = ""
@export var is_transparent : bool = false
@export var is_solid : bool = true
@export var break_time : float = 1.0
@export_category("Textures")
## Up, Down, Sides
@export var block_colors : Array[Colors]
#TODO
@export_category("Sounds")
#TODO
