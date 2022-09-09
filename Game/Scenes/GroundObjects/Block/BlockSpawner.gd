extends TileMap


export var block_segment_scene : PackedScene;

func initialize() -> void:
	position += cell_size/2;
	var parent := get_parent();
	var block_segments := {};
	if(parent):
		for cell in get_used_cells():
			var block_segment := block_segment_scene.instance();
			parent.add_child(block_segment);
			block_segment.global_position = global_position + cell*cell_size;
			block_segments[cell] = block_segment;
		for cell in block_segments:
			block_segments[cell].connected_objects = block_segments.values();
		parent.remove_child(self);
		queue_free();
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
