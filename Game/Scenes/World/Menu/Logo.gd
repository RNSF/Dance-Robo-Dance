extends Sprite

onready var animation_player := $AnimationPlayer;

func beat():
	animation_player.stop();
	animation_player.play("Dance");
