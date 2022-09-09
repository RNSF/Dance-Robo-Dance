extends HBoxContainer

export var robot_move_scene : PackedScene;


var moves := [] setget set_moves;
var current_move_index := 0 setget set_current_move_index;

func set_moves(n: Array) -> void:
	moves = n;
	for index in range(len(moves)):
		var move = moves[index];
		var robot_move = get_child(index);
		if(!robot_move):
			robot_move = robot_move_scene.instance();
		add_child(robot_move);
		robot_move.move = move;
		


func set_current_move_index(n: int) -> void:
	var old_robot_move = get_child(current_move_index);
	if(old_robot_move):
		old_robot_move.is_current = false;
	current_move_index = n;
	var robot_move = get_child(current_move_index);
	if(robot_move):
		robot_move.is_current = true;


func _on_Robot_moves_updated(moves) -> void:
	set_moves(moves);




func _on_Robot_current_move_index_updated(current_move_index: int) -> void:
	set_current_move_index(current_move_index);
	pass # Replace with function body.
