extends CanvasLayer

@export var fps_label : RichTextLabel

func _process(delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())
