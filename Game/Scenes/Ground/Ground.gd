extends TileMap

signal completed;
signal level_number_changed(amount)
signal is_dance_mode_changed(is_dance_mode)
signal player_position_changed(pos)

export var dance_floor_scene : PackedScene;
export var break_scene : PackedScene;
export var exit_scene : PackedScene;
export var break_icon_scene : PackedScene;
export var menu_mode := false;

var grid_objects := {};
var ground_cells := {};
var dance_state := "Low" setget set_dance_state; #Low, Dance
var old_dance_state := dance_state;
var players := [];
var blocks := [];
var robots := [];
var dancers := [];
var dance_floors := [];
var save_states := [];
var break_icons := [];
var top_left := Vector2();
var has_control = true;
var change_level_by = 1;

onready var objects := $Objects;
onready var ground := $Ground;
onready var end_level_timer := $EndLevelTimer;
onready var level_complete_timer := $LevelCompleteTimer;
onready var sound := $Sound;


func _ready() -> void:
	top_left = get_used_rect().position;
	convert_ground();
	grid_objects = find_objects();
	create_save_state();
	self_modulate = Color(0.0, 0.0, 0.0, 0.0);
	for pos in get_used_cells():
		var cell_type = get_cellv(pos);
		set_cellv(pos, -1);
		set_cellv(pos, cell_type);
	for block in blocks:
		block.update_sprite();
	emit_signal("is_dance_mode_changed", false);


func _process(delta: float) -> void:
	if(has_control):
		if(Input.is_action_pressed("prompt")):
			if(Input.is_action_just_pressed("undo")):
				undo();
			elif(Input.is_action_just_pressed("restart")):
				restart();
			elif(Input.is_action_just_pressed("next_level")):
				change_level_by = 1;
				has_control = false;
				despawn();
			elif(Input.is_action_just_pressed("previous_level")):
				change_level_by = -1;
				has_control = false;
				despawn();


func restart():
	var save_state = save_states[0];
	load_save_state(save_states[0]);
	save_states.clear();
	save_states.append(save_state);

func convert_ground() -> void:
	var covered_breaks := [];
	for cell_pos in get_used_cells():
		var cell_type = tile_set.tile_get_name(get_cellv(cell_pos));
		var cell = null;
		if("DanceFloor" in cell_type):
			cell = dance_floor_scene.instance();
			ground.add_child(cell);
			dance_floors.append(cell);
		if("Exit" in cell_type):
			cell = exit_scene.instance();
			ground.add_child(cell);
		if("Break" in cell_type):
			cell = break_scene.instance();
			ground.add_child(cell);
			cell.resting_offset.y = -18;
			var border = "";
			for dir in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
				border += str(int("Break" in tile_set.tile_get_name(get_cellv(cell_pos+dir))));
			cell.border = border;
			if(!(cell_pos in covered_breaks)):
				covered_breaks.append_array(generate_break_icon(cell_pos, cell_type));
				
		if(cell):
			ground_cells[cell_pos] = cell;
			cell.grid_position = cell_pos;
	toggle_cells(true);
	for break_icon in break_icons:
		var ground_cell = ground_cells.get(break_icon.grid_position);
		if(ground_cell):
			var gp = break_icon.global_position;
			remove_child(break_icon);
			ground_cell.add_child(break_icon);
			break_icon.global_position = gp;
			
			break_icon.z_index = 1
		


func toggle_cells(show := true) -> float:
	var max_time := 0.0;
	for pos in ground_cells:
		var time = ((pos.x-top_left.x+pos.y-top_left.y)/64);
		max_time = max(max_time, time);
		if(show):
			ground_cells[pos].spawn_in_timer.start(time);
		else:
			ground_cells[pos].despawn_timer.start(time);
	return max_time

func generate_break_icon(cell_pos, cell_type: String):
	var cov_breaks := [];
	var search_queue := [cell_pos];
	var break_icon := break_icon_scene.instance();
	var top_left = cell_pos;
	var bottom_right = cell_pos;
	add_child(break_icon);
	break_icons.append(break_icon);
	break_icon.cell_type = cell_type;
	while(len(search_queue) > 0):
		var current_cell = search_queue.pop_front();
		cov_breaks.append(current_cell);
		top_left = Vector2(min(top_left.x, current_cell.x), min(top_left.y, current_cell.y));
		bottom_right = Vector2(max(bottom_right.x, current_cell.x), max(bottom_right.y, current_cell.y));
		for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			var bordering_cell := tile_set.tile_get_name(get_cellv(current_cell+dir));
			if(!(current_cell+dir in cov_breaks) and !(current_cell+dir in search_queue) and bordering_cell == cell_type):
				search_queue.append(current_cell+dir);
	break_icon.grid_position = (top_left+bottom_right)/2;
	break_icon.grid_position = Vector2(ceil(break_icon.grid_position.x), ceil(break_icon.grid_position.y))
	break_icon.position = ((top_left+bottom_right)/2+Vector2(0.5, 0.5))*cell_size - Vector2(0, 18);
	
	
	return cov_breaks;


func find_objects() -> Dictionary:
	var objs = {};
	for object in objects.get_children():
		if("Spawner" in object.name):
			object.initialize();
			continue;
	
	for object in objects.get_children():
		var grid_pos = (object.position/cell_size).floor();
		object.grid_position = grid_pos;
		update_object_offset(object, object.grid_position, object.grid_position);
		object.connect("move_requested", self, "_on_GroundObject_move_requested");
		if(object.type_id == "Robot"):
			object.connect("is_dancing_updated", self, "_on_Robot_is_dancing_updated");
			robots.append(object);
			object.previous_tile_type = tile_set.tile_get_name(get_cellv(grid_pos));
		elif(object.type_id == "Player"):
			players.append(object);
			emit_signal("player_position_changed", grid_pos);
		elif(object.type_id == "Block"):
			blocks.append(object);
		elif(object.type_id == "Dancer"):
			dancers.append(object);
			object.connect("death_completed", self, "_on_Dancer_death_completed")
		if(not objs.has(grid_pos)):
			objs[grid_pos] = object;
		else:
			object.queue_free();
			print("ERROR FINDING OBJECTS, 2 OBJECTS ON SAME TILE");
		if(ground_cells.has(grid_pos)):
			ground_cells[grid_pos].connect("offset_updated", object, "_on_GroundCell_offset_updated");
			ground_cells[grid_pos].connect("modulate_updated", object, "_on_GroundCell_modulate_updated");
			object.offset = ground_cells[grid_pos].offset;
		else:
			object.queue_free();
	return objs;

func _on_GroundObject_move_requested(object, start_pos: Vector2, end_pos: Vector2, move_time: float) -> void:
	move_object(object, start_pos, end_pos, move_time);


func _on_GroundObject_grid_position_changed(object, old_pos: Vector2, new_pos: Vector2) -> void:
	if(grid_objects[old_pos] == object):
		grid_objects.erase(old_pos);
	grid_objects[new_pos] = object;
	update_object_offset(object, old_pos, new_pos);
	if(object.type_id == "Player"):
		emit_signal("player_position_changed", new_pos);


func update_object_offset(object, old_pos: Vector2, new_pos: Vector2):
	ground_cells[old_pos].disconnect("offset_updated", object, "_on_GroundCell_offset_updated");
	ground_cells[old_pos].disconnect("modulate_updated", object, "_on_GroundCell_modulate_updated");
	ground_cells[new_pos].connect("offset_updated", object, "_on_GroundCell_offset_updated");
	ground_cells[new_pos].connect("modulate_updated", object, "_on_GroundCell_modulate_updated");
	object.offset = ground_cells[new_pos].offset;
	object.modulate = ground_cells[new_pos].modulate;

func can_move_object(object, original_object, start_pos: Vector2, end_pos: Vector2, move_time: float, objects_to_move = []):
	objects_to_move.append(object);
	for connected_object in object.connected_objects:
		if(connected_object in objects_to_move):
			continue;
		objects_to_move = can_move_object(connected_object, original_object, start_pos, end_pos, move_time, objects_to_move);
		if(objects_to_move == null):
			return null;
	
	if(get_cellv(object.grid_position+end_pos-start_pos) == INVALID_CELL):
		return null;
	
	for cell_type in object.cant_be_pushed_on:
		if(cell_type in tile_set.tile_get_name(get_cellv(object.grid_position+end_pos-start_pos))):
			return null
	
	var object_in_way = grid_objects.get(object.grid_position+end_pos-start_pos);
	
	if(object_in_way):
		if(object_in_way in objects_to_move):
			return objects_to_move
		if(object.type_id in object_in_way.pushable_by and original_object.type_id in object_in_way.pushable_by):
			return can_move_object(object_in_way, original_object, object_in_way.grid_position, end_pos-start_pos+object_in_way.grid_position, move_time, objects_to_move);
		else:
			if(object.type_id == "Robot" and object_in_way.type_id == "Dancer"):
				object.killing = true;
				return objects_to_move
			return null;
	else:
		return objects_to_move;

func move_object(object, start_pos: Vector2, end_pos: Vector2, move_time: float):
	var objects_to_move = can_move_object(object, object, start_pos, end_pos, move_time);
	var objects_to_add := {};
	var objects_to_erase := {};
	var block_sound_played := false;
	"""
	if(objects_to_move is String):
		if(objects_to_move == "die"):
			var dancer = grid_objects[end_pos];
			if(dancer):
				dancer.alive = false;
			succesful_move(object, object.grid_position, end_pos, move_time);
			return
	"""
	if(objects_to_move):
		if(object.type_id == "Player"):
			emit_signal("player_position_changed", end_pos);
		if(object.type_id == "Player" and dance_state == "Low"):
			create_save_state();
		for object in objects_to_move:
			if(!block_sound_played and object.type_id == "Block"):
				object.sound.play("Move"+str(randi()%5));
				block_sound_played = true;
			objects_to_add[end_pos-start_pos+object.grid_position] = object;
			objects_to_erase[object.grid_position] = object;
			var end = end_pos-start_pos+object.grid_position;
			ground_cells[object.grid_position].disconnect("offset_updated", object, "_on_GroundCell_offset_updated");
			ground_cells[object.grid_position].disconnect("modulate_updated", object, "_on_GroundCell_modulate_updated");
			ground_cells[end].connect("offset_updated", object, "_on_GroundCell_offset_updated");
			ground_cells[end].connect("modulate_updated", object, "_on_GroundCell_modulate_updated");
			object.offset = ground_cells[end].offset;
			if(object.type_id == "Robot"):
				if(object.killing):
					object.killing = false;
					var dancer = grid_objects[end];
					if(dancer):
						dancer.alive = false;
			succesful_move(object, object.grid_position, end, move_time);
		
		
	else:
		failed_move(object, start_pos, end_pos, move_time);
	
	for pos in objects_to_erase:
		grid_objects.erase(pos);

	for pos in objects_to_add:
		grid_objects[pos] = objects_to_add[pos];
		objects_to_add[pos].offset = ground_cells[pos].offset;
	
	
	



func succesful_move(object, start_pos: Vector2, end_pos: Vector2, move_time: float) -> bool:
	object.move(end_pos, tile_set.tile_get_name(get_cellv(end_pos)), move_time);
	return true;

func failed_move(object, start_pos: Vector2, end_pos: Vector2, move_time: float) -> bool:
	object.failed_move(end_pos);
	return false;




func _on_Robot_is_dancing_updated(is_dancing: bool) -> void:
	if(is_dancing):
		set_dance_state("Dance");
	else:
		set_dance_state("Low");
	pass # Replace with function body.


func set_dance_state(n: String) -> void:
	if(dance_state != n):
		dance_state = n;
		
		match(dance_state):
			"Dance":
				for player in players:
					player.has_control = false;
			"Low":
				for player in players:
					player.has_control = true;


func beat():
	if(dance_state == "Dance"):
		for robot in robots:
			robot.dance();
	if(dance_state == "Dance" or menu_mode):
		for dance_floor in dance_floors:
			dance_floor.disco_light()
	
	for dancer in dancers:
		dancer.beat(dance_state == "Dance");
	
	if(old_dance_state != dance_state):
		old_dance_state = dance_state;
		emit_signal("is_dance_mode_changed", dance_state == "Dance");
	

func create_save_state():
	var robot_moves = [];
	var robot_move_index = [];
	var robot_previous_tile = [];
	var robot_alive = [];
	for robot in robots:
		robot_moves.append(robot.moves.duplicate());
		robot_move_index.append(robot.current_move_index);
		robot_previous_tile.append(robot.previous_tile_type);
	save_states.append({
		"grid_objects": grid_objects.duplicate(),
		"robot_moves" : robot_moves,
		"robot_move_index" : robot_move_index,
		"robot_previous_tile" : robot_previous_tile,
		"robot_alive" : robot_alive,
	})

func load_save_state(save_state: Dictionary):
	grid_objects = save_state["grid_objects"].duplicate();
	for i in range(len(robots)):
		robots[i].on_failed_move = false;
		robots[i].moves = save_state["robot_moves"][i].duplicate();
		robots[i].current_move_index = save_state["robot_move_index"][i];
		robots[i].previous_tile_type = save_state["robot_previous_tile"][i];
		robots[i].is_dancing = false;
		robots[i].moving = false;
		robots[i].update_move_display();
	
	for dancer in dancers:
		dancer.alive = true;
	
	for pos in grid_objects:
		var object = grid_objects[pos];
		object.tween.remove_all();
		update_object_offset(object, object.grid_position, pos);
		object.grid_position = pos;
	
	for player in players:
		player.has_control = true;
		player.moving = false;
	
	set_dance_state("Low");
	pass

func undo():
	if(len(save_states) > 1):
		sound.play("Undo");
		load_save_state(save_states.pop_back());


func _on_Robot_exit_reached(robot) -> void:
	sound.play("Cheer");
	#sound.play("LevelComplete");
	level_complete_timer.start(2);
	emit_signal("completed");
	has_control = false;
	pass # Replace with function body.


func _on_EndLevelTimer_timeout() -> void:
	emit_signal("level_number_changed", change_level_by);
	pass # Replace with function body.


func _on_Dancer_death_completed():
	undo();


func _on_LevelCompleteTimer_timeout() -> void:
	despawn();
	pass # Replace with function body.

func despawn():
	end_level_timer.start(toggle_cells(false)+1);
