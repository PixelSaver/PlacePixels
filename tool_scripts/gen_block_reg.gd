@tool
extends EditorScript

func _run():
	var output = "const BLOCK_FILES = [\n"
	var dir = DirAccess.open("res://resources/blocks/")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tres"):
				output += '\t"%s",\n' % file_name
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	output += "]\n"
	print(output)
	print("Copy the above array into your BlockRegistry script")
