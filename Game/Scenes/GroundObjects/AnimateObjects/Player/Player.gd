extends "../AnimateObject.gd"

export var speed := 1;

var queued_move := Vector2.ZERO;
var has_control := true setget set_has_control;

onready var p_sprite := $Sprites/P;

func _ready() -> void:
	update_dance_move();

func _process(delta: float) -> void:
	var input = get_move();
	if(input != Vector2.ZERO):
		queued_move = input;
	if(!has_control):
		queued_move = Vector2.ZERO;
	if(queued_move != Vector2.ZERO):
		if(!moving):
			dance();


func dance():
	request_move(grid_position+queued_move*speed);
	queued_move = Vector2.ZERO;
	animation_player.stop();
	animation_player.play("Dance");



func get_move() -> Vector2:
	if(Input.is_action_just_pressed("move_down")):
		return Vector2.DOWN;
	elif(Input.is_action_just_pressed("move_up")):
		return Vector2.UP;
	elif(Input.is_action_just_pressed("move_left")):
		return Vector2.LEFT;
	elif(Input.is_action_just_pressed("move_right")):
		return Vector2.RIGHT;
	return Vector2.ZERO


func update_dance_move():
	var index = -1;
	
	while index == -1 or index == current_dance_move:
		index = randi()%dance_move_count;
	scale.x = (randi()%2)*2-1;
	p_sprite.scale.x = scale.x;
	set_current_dance_move(index);
	var head_position = head_positions.get_child(index);
	if(head_position):
		p_sprite.position = head_position.position;
		p_sprite.rotation = head_position.rotation;
	pass


func set_has_control(n: bool) -> void:
	has_control = n;
	dancing_sprite.material.set_shader_param("active", has_control);

func failed_move(end_pos: Vector2) -> void:
	.failed_move(end_pos);
	Global.screen_shake(10, 0.15);
