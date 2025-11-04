extends Node

## Stores blocks by name: "stone" -> Block resource; dynamically loaded
var blocks_by_name: Dictionary = {}
## Stores blocks by ID: 0 -> Block resource; dynamically loaded
var blocks_by_id: Dictionary = {}

func load_blocks():
	# Load all .tres files from res://blocks/
	var dir = DirAccess.open("res://assets/blocks/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tres"):
				var block: Block = load("res://blocks/" + file_name)
				register_block(block)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	print("Loaded %d blocks" % blocks_by_name.size())

func register_block(block: Block):
	if block.id in blocks_by_id:
		push_error("Duplicate block ID: %d for block '%s'" % [block.id, block.block_name])
		return
	
	blocks_by_name[block.block_name] = block
	blocks_by_id[block.id] = block

func get_block(block_name: String) -> Block:
	return blocks_by_name.get(block_name)

func get_block_by_id(id: int) -> Block:
	return blocks_by_id.get(id)

## Get block ID by name
func get_id(block_name: String) -> int:
	var block = get_block(block_name)
	return block.id if block else -1
