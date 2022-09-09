extends Control


var on := false setget set_on;

onready var on_sprite := $On;
onready var off_sprite := $Off;

func set_on(n: bool) -> void:
	on = n;
	on_sprite.visible = on;
	off_sprite.visible = !on;
