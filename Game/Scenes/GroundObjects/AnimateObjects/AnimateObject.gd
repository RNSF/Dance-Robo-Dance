extends "../GroundObject.gd"

var current_dance_move := 0 setget set_current_dance_move;
var current_dance_frame := 0 setget current_dance_frame;
var dance_move_count := 8;
var frame_count := 2;
var sprite_size := Vector2(250, 300);
var on_failed_move := false;

onready var animation_player := $AnimationPlayer;
onready var dancing_sprite := $Sprites/DanceSprite;
onready var head_positions := $HeadPositions;
onready var move_sound := $MoveSound;
onready var dance_frames := [
	load("res://Game/Scenes/GroundObjects/AnimateObjects/Sprites/Dance1.png"),
	load("res://Game/Scenes/GroundObjects/AnimateObjects/Sprites/Dance2.png"),
	load("res://Game/Scenes/GroundObjects/AnimateObjects/Sprites/Dance3.png"),
	load("res://Game/Scenes/GroundObjects/AnimateObjects/Sprites/Dance4.png"),
	load("res://Game/Scenes/GroundObjects/AnimateObjects/Sprites/Dance5.png"),
	load("res://Game/Scenes/GroundObjects/AnimateObjects/Sprites/Dance6.png"),
	load("res://Game/Scenes/GroundObjects/AnimateObjects/Sprites/Dance7.png"),
	load("res://Game/Scenes/GroundObjects/AnimateObjects/Sprites/Dance8.png"),
]

func _ready() -> void:
	dancing_sprite.material = dancing_sprite.material.duplicate();

func set_current_dance_move(n: int):
	current_dance_move = n;
	update_sprite();

func current_dance_frame(n: int):
	current_dance_frame = n;
	update_sprite();

func update_sprite():
	dancing_sprite.texture = dance_frames[current_dance_move];


func move(end_pos: Vector2, tile_type: String, override_move_time := move_time) -> void:
	.move(end_pos, tile_type, override_move_time);
	move_sound.play("Step"+str(randi()%5));


func failed_move(end_pos: Vector2) -> void:
	.failed_move(end_pos);
	move_sound.play("Bounce"+str(randi()%5));
	on_failed_move = true;
	moving = true;
	tween.interpolate_property(self, "position", position, offset+position+((end_pos+Vector2(0.5, 0.5))*tile_size-position)*0.2, move_time/8/2, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween.start();
	pass

func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	if(on_failed_move):
		on_failed_move = false;
		tween.interpolate_property(self, "position", position, offset+(grid_position+Vector2(0.5, 0.5))*tile_size, 7*move_time/8/2, Tween.TRANS_EXPO, Tween.EASE_IN)
		tween.start();
	else:
		._on_Tween_tween_completed(object, key);

	


func update_dance_move():
	pass

func update_bop_move():
	pass
