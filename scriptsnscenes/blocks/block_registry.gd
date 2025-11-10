extends Node

signal blocks_loaded
## Stores blocks by name: "stone" -> Block resource; dynamically loaded
var blocks_by_name: Dictionary = {}
## Stores blocks by ID: 0 -> Block resource; dynamically loaded
var blocks_by_id: Dictionary = {}

const BLOCK_FILES = [
	"air.tres",
	"dirt.tres",
	"grass.tres",
	"stone.tres",
]

func load_blocks():
	for file_name in BLOCK_FILES:
		var block: Block = load("res://resources/blocks/" + file_name)
		if block:
			register_block(block)
		else:
			push_error("Failed to load block: %s" % file_name)
	
	blocks_loaded.emit()
	print("Blocks loaded: %d blocks" % blocks_by_name.size())

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
