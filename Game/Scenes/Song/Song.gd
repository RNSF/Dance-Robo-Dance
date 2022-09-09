extends Node

signal beat

export var bpm := 138.0;

var current_beat := 0;
var in_dance_mode := false setget set_in_dance_mode;
var playing := false;
var time := 0.0;
var time_begin := 0.0;
var time_delay := 0.0;

onready var dance_track := $Dance;
onready var low_track := $Low;

func play():
	set_in_dance_mode(in_dance_mode);
	current_beat = 1/bpm;
	
	playing = true;
	time = 0;
	time_begin = OS.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency();
	dance_track.play();
	low_track.play();

func set_in_dance_mode(n: bool):
	in_dance_mode = n;
	if(in_dance_mode):
		low_track.volume_db = -100;
		dance_track.volume_db = 0;
	else:
		low_track.volume_db = 0;
		dance_track.volume_db = -100;

func _process(delta: float) -> void:

	time = max(time, low_track.get_playback_position() + AudioServer.get_time_since_last_mix());
	time -= AudioServer.get_output_latency()

	if(playing):
		"""
		time = (OS.get_ticks_usec() - time_begin) / 1000000.0
		time -= time_delay
		time = max(0, time)
		print(time)
		"""
		if((1/bpm)*60*current_beat < time):
			emit_signal("beat")
			current_beat = ceil(time/60*bpm);


func _on_Low_finished() -> void:
	dance_track.stop();
	low_track.stop();
	if(playing):
		play();
	pass # Replace with function body.


func stop():
	playing = false;
	dance_track.stop();
	low_track.stop();
