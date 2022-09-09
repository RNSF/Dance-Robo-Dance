extends Node2D

signal animation_completed

var anim_length := 0.5;
var gravity := 5000.0;
var velocity := Vector2.ZERO;
var rotational_velocity := 0.0;

func _process(delta: float) -> void:
	velocity.y += gravity*delta;
	position += velocity*delta;
	rotation += rotational_velocity*delta;
	modulate.a -= delta/anim_length;
	if(modulate.a < 0):
		emit_signal("animation_completed")

func launch():
	modulate.a = 1.0;
	velocity = Vector2(
		rand_range(300, 500)*(((randi()%2))*2-1),
		-rand_range(1000, 1500)
	);
	rotational_velocity = rand_range(PI/2, PI)*(((randi()%2))*2-1)
