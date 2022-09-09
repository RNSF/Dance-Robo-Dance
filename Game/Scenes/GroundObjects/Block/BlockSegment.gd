extends "../GroundObject.gd"

onready var sound := $Sound;

func update_sprite():
	for object in connected_objects:
		var vector = object.grid_position-grid_position;
		var sprite_name = str(vector.x)+str(vector.y);
		if(sprites.has_node(sprite_name)):
			sprites.get_node(sprite_name).visible = true;
	for corner in [Vector2(1, 1), Vector2(-1, 1),Vector2(1, -1),Vector2(-1, -1)]:
		var corner_node = sprites.get_node(str(corner.x)+str(corner.y));
		print(corner)
		corner_node.visible = (corner_node.visible 
		and sprites.get_node(str(corner.x)+str(0)).visible
		and sprites.get_node(str(0)+str(corner.y)).visible);

func move(end_pos: Vector2, tile_type: String, override_move_time := move_time) -> void:
	.move(end_pos, tile_type, override_move_time);
	Global.screen_shake(5, 0.1);
