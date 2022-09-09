extends Node


var camera : Camera2D;

func screen_shake(strength: float, time: float) -> void:
	if(camera):
		camera.shake(strength, time);

func quick_zoom(zoom: float) -> void:
	if(camera):
		camera.quick_zoom(zoom);
