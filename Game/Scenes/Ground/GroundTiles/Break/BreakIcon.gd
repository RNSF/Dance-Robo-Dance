extends Sprite

export var cell_type := "Break Up" setget set_cell_type;

var grid_position := Vector2.ZERO;

func set_cell_type(n: String) -> void:
	cell_type = n;
	update_texture();

func update_texture():
	var path = "res://Game/Scenes/UI/RobotMoves/RobotMove/";
	texture = {
		"Break Up": load(path+"arrowUp.png"),
		"Break Down": load(path+"arrowDown.png"),
		"Break Left": load(path+"arrowLeft.png"),
		"Break Right": load(path+"arrowRight.png"),
		"Break Blank": load(path+"minus.png"),
	}.get(cell_type, null); 
