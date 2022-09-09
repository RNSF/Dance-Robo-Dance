extends TextureRect


var move := Vector2.ZERO setget set_move;
var is_current := false setget set_is_current;

onready var texture_rect := $TextureRect;
onready var animation_player := $AnimationPlayer;

func _ready() -> void:
	set_is_current(is_current);
	

func set_move(n: Vector2):
	move = n;
	update_texture();


func update_texture():
	var path = "res://Game/Scenes/UI/RobotMoves/RobotMove/";
	texture_rect.texture = {
		Vector2.UP: load(path+"arrowUp.png"),
		Vector2.DOWN: load(path+"arrowDown.png"),
		Vector2.LEFT: load(path+"arrowLeft.png"),
		Vector2.RIGHT: load(path+"arrowRight.png"),
		Vector2.ZERO: load(path+"minus.png"),
	}.get(move, null);


func set_is_current(n: bool):
	if(is_current != n):
		is_current = n;
		if(is_current):
			animation_player.play("BecomeCurrent");
		else:
			animation_player.play_backwards("BecomeCurrent");


func _on_RobotMove_resized() -> void:
	rect_pivot_offset = rect_size/2;
	pass # Replace with function body.
