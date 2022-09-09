extends Node2D

signal move_requested(object, start_pos, end_pos, move_time);
signal grid_position_changed(object, old_pos, new_pos);


export var move_time = 0.4;
export var type_id := "GroundObject";
export var pushable_by := [];
export var cant_be_pushed_on := [];

var grid_position := Vector2.ZERO setget set_grid_position;
var tile_size := Vector2(100, 100);
var moving := false;
var connected_objects := [];
var offset := Vector2.ZERO setget set_offset;


onready var tween := $Tween;
onready var sprites := $Sprites;

func _ready() -> void:
	modulate.a = 0;

func set_grid_position(n: Vector2) -> void:
	emit_signal("grid_position_changed", self, grid_position, n);
	grid_position = n;
	position = (grid_position+Vector2(0.5, 0.5))*tile_size+offset;
	z_index = grid_position.y*3;


func request_move(end_pos: Vector2):
	emit_signal("move_requested", self, grid_position, end_pos, move_time);

func move(end_pos: Vector2, tile_type: String, override_move_time := move_time) -> void:
	moving = true;
	grid_position = end_pos;
	z_index = grid_position.y*3;
	tween.interpolate_property(self, "position", position, (grid_position+Vector2(0.5, 0.5))*tile_size+offset, override_move_time, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start();

func failed_move(end_pos: Vector2) -> void:
	pass


func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	moving = false;
	pass # Replace with function body.


func _on_GroundCell_offset_updated(n: Vector2):
	set_offset(n);
	set_grid_position(grid_position);

func _on_GroundCell_modulate_updated(n: Color):
	modulate.a = n.a;


func set_offset(n: Vector2) -> void:
	offset = n;
