extends "../AnimateObject.gd"

signal death_completed

export var dead_dancer_scene : PackedScene;

var alive := true setget set_alive;
var dead_dancer = null;

onready var sound := $Sound;


func _ready() -> void:
	set_current_dance_move(randi()%dance_move_count);
	scale.x = (randi()%2)*2-1

func update_dance_move():
	.update_dance_move();
	scale.x *= -1;

func beat(dance_mode_active: bool) -> void:
	if(dance_mode_active):
		animation_player.play("Dance");
	else:
		animation_player.play("Bop");

func set_alive(n: bool) -> void:
	if(alive != n):
		alive = n;
		visible = alive;
		if(is_instance_valid(dead_dancer)):
			dead_dancer.queue_free();
		if(!alive):
			dead_dancer = dead_dancer_scene.instance();
			if(get_parent()):
				sound.play("Hit");
				Global.quick_zoom(0.96);
				Global.screen_shake(40, 0.2);
				get_parent().add_child(dead_dancer);
				dead_dancer.position = position;
				dead_dancer.add_child(sprites.duplicate());
				dead_dancer.connect("animation_completed", self, "_on_DeadDancer_animation_completed");
				dead_dancer.launch();
				dead_dancer.z_index = 1000;

func _on_DeadDancer_animation_completed() -> void:
	emit_signal("death_completed");
