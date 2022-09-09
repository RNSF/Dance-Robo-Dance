extends Node2D


var last_level := 1;
var last_challenge_level := 101;

var level_number := -1;
var current_level = null;
var next_level = null;
var current_song = null setget set_current_song;
var completed_levels := [];
var menu_path := "res://Game/Scenes/World/Levels/MenuLevel.tscn";
var levels := {
	-1: menu_path,
	1: "res://Game/Scenes/World/Levels/Level1.tscn",
	2: "res://Game/Scenes/World/Levels/Level2.tscn",
	3: "res://Game/Scenes/World/Levels/Level3.tscn",
	4: "res://Game/Scenes/World/Levels/Level4.tscn",
	5: "res://Game/Scenes/World/Levels/Level5.tscn",
	6: "res://Game/Scenes/World/Levels/Level6.tscn",
	7: "res://Game/Scenes/World/Levels/Level7.tscn",
	8: "res://Game/Scenes/World/Levels/Level8.tscn",
	9: "res://Game/Scenes/World/Levels/Level9.tscn",
	10: "res://Game/Scenes/World/Levels/Level10.tscn",
	11: "res://Game/Scenes/World/Levels/Level11.tscn",
	12: "res://Game/Scenes/World/Levels/Level12.tscn",
	101: "res://Game/Scenes/World/Levels/ChallengeLevel1.tscn",
	102: "res://Game/Scenes/World/Levels/ChallengeLevel2.tscn",
}
var bus_states := {
	"SFX": true,
	"Music": true,
}
onready var tek_song := $Songs/Tek;
onready var techno_song := $Songs/Techno;
onready var tech_song := $Songs/Tech;
onready var level_songs := {
	1: tek_song,
	2: tek_song,
	3: tek_song,
	4: tek_song,
	5: tek_song,
	6: tek_song,
	7: tek_song,
	8: tek_song,
	9: techno_song,
	10: techno_song,
	11: techno_song,
	12: techno_song,
	101: tech_song,
	102: tech_song,
}

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("sfx_toggle")):
		toggle_bus("SFX");
	if(Input.is_action_just_pressed("music_toggle")):
		toggle_bus("Music");

func _ready() -> void:
	set_level_number(level_number);
	set_current_song(tek_song);

func transition_to_level():
	remove_child(current_level);
	if(next_level):
		if(next_level.level == level_number):
			current_level = next_level;
		else:
			current_level = load(levels.get(level_number, menu_path)).instance();
	else:
		current_level = load(levels.get(level_number, menu_path)).instance();
	current_level.connect("completed", self, "_on_Level_completed");
	current_level.connect("level_number_changed", self, "_on_Level_level_number_changed")
	current_level.connect("is_dance_mode_changed", self, "_on_Level_is_dance_mode_changed")
	add_child(current_level);
	current_level.bus_states = bus_states;
	current_level.completed = current_level.level in completed_levels;
	if(current_level.level >= 100):
		last_challenge_level = current_level.level;
	elif(current_level.level >= 0):
		last_level = current_level.level;
	if("Menu" in current_level.name):
		current_level.connect("play_selected", self, "_on_Level_play_selected");
		current_level.connect("challenge_selected", self, "_on_Level_challenge_selected");
		current_level.completed_levels = completed_levels;
	var scene = load(levels.get(level_number+1, menu_path));
	if(scene):
		next_level = scene.instance();
	
	var level_song = level_songs.get(current_level.level);
	if(level_song):
		print(level_song.name)
		set_current_song(level_song);

func set_level_number(n: int):
	level_number = n;
	transition_to_level();

func _on_Level_completed():
	if(not current_level.level in completed_levels):
		completed_levels.append(current_level.level);

func _on_BeatTimer_timeout() -> void:
	"""
	if(current_level):
		current_level.beat();
	"""
	pass # Replace with function body.

func _on_Level_level_number_changed(level):
	set_level_number(level);


func _on_Song_beat() -> void:
	current_level.beat();
	pass # Replace with function body.


func _on_Level_is_dance_mode_changed(is_dance_mode: bool) -> void:
	if(current_song):
		current_song.in_dance_mode = is_dance_mode;


func toggle_bus(bus_name: String) -> void:
	var bus_number : int = {
		"Music" : 1,
		"SFX" : 2,
	}.get(bus_name, 0);
	if(bus_states.get(bus_name, true)):
		AudioServer.set_bus_volume_db(bus_number, -70);
		bus_states[bus_name] = false;
	else:
		AudioServer.set_bus_volume_db(bus_number, 0);
		bus_states[bus_name] = true;
	current_level.bus_states = bus_states;

func _on_Level_play_selected():
	set_level_number(last_level);

func _on_Level_challenge_selected():
	set_level_number(last_challenge_level);

func set_current_song(n: Node):
	if(current_song != n):
		if(current_song):
			current_song.stop();
		current_song = n;
		if(current_song):
			current_song.play();
