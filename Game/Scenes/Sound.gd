extends Node


func play(sound_name: String) -> void:
	var sfx = get_node(sound_name);
	if(sfx):
		sfx.play();
