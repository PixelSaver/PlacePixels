extends Node

var world_gen : WorldGen
var player : Player
signal player_chunk_update(new_chunk:Chunk)
var player_chunk : Chunk :
	set(val):
		if val == player_chunk: return
		player_chunk_update.emit(val)
		print("Player entered new chunk, %s" % val.chunk_position)
		player_chunk = val
