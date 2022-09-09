extends Control


var filled := false setget set_filled;

onready var filled_sprite := $Filled;
onready var empty_sprite := $Empty;

func set_filled(n: bool) -> void:
	filled = n;
	filled_sprite.visible = filled;
	empty_sprite.visible = !filled;
