extends Node2D

signal offset_updated(new_offset);
signal modulate_updated(new_modulate);


var grid_position := Vector2.ZERO setget set_grid_position;
var tile_size := Vector2(100, 100);
var offset := Vector2.ZERO setget set_offset;
var resting_offset := Vector2.ZERO setget set_resting_offset;
var animating := false;
export var animation_offset := Vector2.ZERO setget set_animation_offset;

onready var animation_player := $AnimationPlayer;
onready var spawn_in_timer := $SpawnInTimer;
onready var despawn_timer := $DespawnTimer;

func _ready() -> void:
	modulate.a = 0;

func set_grid_position(n: Vector2) -> void:
	grid_position = n;
	position = (grid_position+Vector2(0.5, 0.5))*tile_size+offset;
	z_index = grid_position.y*3-2;

func set_offset(n: Vector2) -> void:
	if(offset != n):
		offset = n;
		set_grid_position(grid_position);
		emit_signal("offset_updated", offset);

func set_resting_offset(n: Vector2) -> void:
	resting_offset = n;
	set_offset(resting_offset+animation_offset)

func set_animation_offset(n: Vector2) -> void:
	animation_offset = n;
	set_offset(resting_offset+animation_offset)
		

func _on_SpawnInTimer_timeout() -> void:
	animation_player.play("SpawnIn");
	pass # Replace with function body.


func _process(delta: float) -> void:
	if(animation_player.current_animation != null):
		emit_signal("modulate_updated", modulate);


func _on_DespawnTimer_timeout() -> void:
	animation_player.play_backwards("SpawnIn");
	pass # Replace with function body.
