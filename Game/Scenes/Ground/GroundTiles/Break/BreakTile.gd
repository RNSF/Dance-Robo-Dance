extends "../GroundTile.gd"


var border = "0000" setget set_border;
var cell_size := Vector2(100, 100);

onready var sprite := $Sprite;

func _ready() -> void:
	sprite.texture = sprite.texture.duplicate();

func set_border(n: String) -> void:
	border = n;
	var horizontal = border[2] + border[0];
	var vertical = border[3] + border[1];
	
	sprite.texture.region = Rect2(
		{
			"01": 0,
			"11": 1*cell_size.x,
			"10": 2*cell_size.x,
			"00": 3*cell_size.x,
		}[horizontal],
		{
			"01": 0,
			"11": 1*cell_size.x,
			"10": 2*cell_size.x,
			"00": 4*cell_size.x,
		}[vertical]-5,
		cell_size.x,
		cell_size.y-offset.y
	);
