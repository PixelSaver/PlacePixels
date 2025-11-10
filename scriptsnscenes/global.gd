extends Node

var world_gen : WorldGen
var player : Player
signal player_chunk_update(new_chunk:Vector2i)
var player_chunk : Vector2i :
	set(val):
		if val == player_chunk: return
		print("Player entered new chunk, %s" % val)
		player_chunk = val

var ui : UI
