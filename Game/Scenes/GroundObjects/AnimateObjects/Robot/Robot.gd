extends "../AnimateObject.gd"

signal current_move_index_updated(current_move_index);
signal moves_updated(moves);
signal is_dancing_updated(is_dancing);
signal exit_reached(robot);

export var moves := [Vector2.UP, Vector2.LEFT, Vector2.DOWN, Vector2.LEFT] setget set_moves;
export var dead_robot_scene : PackedScene;

var current_move_index := 0 setget set_current_move_index;
var is_dancing := false setget set_is_dancing;
var previous_tile_type := "";
var can_move := true;
var killing := false;

onready var move_sprite := $Sprites/Move;
onready var sound := $Sound;
onready var confetti_particle := $ConfettiParticle;

func _ready() -> void:
	emit_signal("moves_updated", moves);
	set_current_move_index(0);
	update_move_display();
	set_current_dance_move(current_dance_move);
	dancing_sprite.material.set_shader_param("active", is_dancing);

func dance() -> void:
	var current_move: Vector2 = moves[current_move_index];
	request_move(grid_position+current_move);



func request_move(end_pos: Vector2) -> void:
	if(can_move):
		.request_move(end_pos);
	else:
		dance_move();
		increment_dance_move();


func set_current_move_index(n: int) -> void:
	current_move_index = n;
	emit_signal("current_move_index_updated", current_move_index);

func update_move_display():
	var path := "res://Game/Scenes/UI/RobotMoves/RobotMove/";
	move_sprite.texture = {
		Vector2.UP: load(path+"arrowUp.png"),
		Vector2.DOWN: load(path+"arrowDown.png"),
		Vector2.LEFT: load(path+"arrowLeft.png"),
		Vector2.RIGHT: load(path+"arrowRight.png"),
		Vector2.ZERO: load(path+"minus.png"),
	}.get(moves[current_move_index], null);

func set_moves(n: Array):
	if(!is_inside_tree()):
		yield(self, "ready");
	moves = n;
	emit_signal("moves_updated", moves);
	update_move_display();


func set_is_dancing(n: bool) -> void:
	if(is_dancing != n):
		is_dancing = n;
		dancing_sprite.material.set_shader_param("active", is_dancing);
		emit_signal("is_dancing_updated", is_dancing);


func move(end_pos: Vector2, tile_type: String, override_move_time := move_time) -> void:
	dance_move();
	increment_dance_move();
	.move(end_pos, tile_type, override_move_time);
	if(previous_tile_type != tile_type):
		if("Exit" in tile_type):
			can_move = false;
			emit_signal("exit_reached", self);
			confetti_particle.emitting = true;
		elif("DanceFloor" in tile_type):
			set_is_dancing(true);
		elif("Break" in tile_type):
			set_is_dancing(false);
			var move_index = current_move_index;
			match tile_type:
				"Break Up":
					replace_move(move_index, Vector2.UP);
				"Break Down":
					replace_move(move_index, Vector2.DOWN);
				"Break Left":
					replace_move(move_index, Vector2.LEFT);
				"Break Right":
					replace_move(move_index, Vector2.RIGHT);
				"Break Blank":
					replace_move(move_index, Vector2.ZERO);
	previous_tile_type = tile_type;
	
	


func increment_dance_move():
	if(is_dancing):
		sound.play({
			Vector2.UP: "DanceUp",
			Vector2.LEFT: "DanceLeft",
			Vector2.DOWN: "DanceDown",
			Vector2.RIGHT: "DanceRight",
		}.get(moves[current_move_index], ""));
		current_move_index += 1;
		set_current_move_index(current_move_index % len(moves));
	update_move_display();

func failed_move(end_pos: Vector2) -> void:
	.failed_move(end_pos);
	dance_move();
	increment_dance_move();

func replace_move(index, replacement_move) -> void:
	moves[index] = replacement_move;
	set_moves(moves);


func rotate_moves(rotation_direction) -> void:
	for i in range(len(moves)):
		rotate_move(i, rotation_direction);


func rotate_move(index, rotation_direction) -> void:
	for i in range(len(moves)):
		var move : Vector2 = moves[i];
		moves[i] = move.rotated(rotation_degrees*PI/2)

func update_dance_move() -> void:
	.update_dance_move();
	var index = -1;
	while index == -1 or index == current_dance_move:
		index = randi()%dance_move_count;
	set_current_dance_move(index);
	
	pass

func update_bop_move() -> void:
	.update_bop_move();

func dance_move() -> void:
	if(is_dancing):
		if(moves[current_move_index] != Vector2.ZERO):
			animation_player.play("Dance");
		else:
			animation_player.play("Bop");
		if(can_move):
			Global.screen_shake(5, 0.1);
		#Global.quick_zoom(0.96);

func set_current_dance_move(n: int) -> void:
	.set_current_dance_move(n);
	var head_position = head_positions.get_child(current_dance_move);
	if(head_position):
		move_sprite.position = head_position.position;
		move_sprite.rotation = head_position.rotation;


