@tool
extends EditorScript

func _run():
	var blocks_dir: String = "res://resources/blocks/"
	var output_path: String = "res://scriptsnscenes/block_ids.gd"
	var dir := DirAccess.open(blocks_dir)

	if dir == null:
		push_error("Failed to open blocks directory: %s" % blocks_dir)
		return

	# Collect all blocks
	var blocks: Array = []
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if file_name.ends_with(".tres"):
			var block := load(blocks_dir + file_name)
			if block:
				blocks.append(block)
	dir.list_dir_end()

	# Sort by ID
	blocks.sort_custom(func(a, b): return a.id < b.id)

	# Build the output file content
	var output_lines: Array[String] = [
		"# block_ids.gd",
		"# AUTO-GENERATED — DO NOT EDIT MANUALLY",
		"# Run tools/generate_block_constants.gd to regenerate",
		"class_name BlockIDs",
		""
	]

	for block in blocks:
		var const_name: String = block.block_name.strip_edges().to_upper().replace(" ", "_")
		output_lines.append("const %s = %d" % [const_name, block.id])

	var output_text: String = "\n".join(output_lines)

	# Undo/Redo setup
	var undo_redo = get_editor_interface().get_editor_undo_redo()

	var prev_text := ""
	if FileAccess.file_exists(output_path):
		var old_file := FileAccess.open(output_path, FileAccess.READ)
		if old_file:
			prev_text = old_file.get_as_text()
			old_file.close()

	# Only create an undo action if the file actually changed
	if prev_text != output_text:
		undo_redo.create_action("Generate Block IDs")
		undo_redo.add_do_method(self, "_write_file", output_path, output_text)
		undo_redo.add_undo_method(self, "_write_file", output_path, prev_text)
		undo_redo.commit_action()
		print("✓ Generated block constants at: %s" % output_path)
		print("✓ Total blocks: %d" % blocks.size())
	else:
		print("✓ Block constants already up to date")

	# Refresh the file system
	get_editor_interface().get_resource_filesystem().scan()


func _write_file(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(text)
		file.close()
