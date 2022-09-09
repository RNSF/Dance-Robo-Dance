extends Node2D

signal completed
signal level_number_changed(amount)
signal is_dance_mode_changed(is_dance_mode)

export var level = 0;
export var level_count := 12;

onready var ground := $Ground;
onready var camera := $Camera;
onready var star := $UI/UI/Star;
onready var sfx_option := $UI/UI/SfxOption;
onready var music_option := $UI/UI/MusicOption;
onready var controls := $UI/UI/Controls;
onready var help := $UI/UI/Help;
onready var canvas_modulate := $CanvasModulate;
onready var world_environment := $WorldEnvironment;
onready var level_number_label := $UI/UI/LevelNumber;

var completed := false setget set_completed;
var bus_states := {"SFX": true, "Music": true} setget set_bus_states
var readied := false
var returning_to_menu := false;

func _ready() -> void:
	var rect = ground.get_used_rect();
	camera.position = (rect.position+rect.size/2)*ground.cell_size+Vector2(0, 100)*camera.scale.y;
	readied = true;
	var level_string_value = level;
	if(level_string_value >= 100):
		level_string_value -= 100;
	level_number_label.text = str(level_string_value) + "/" + str(level_count);

func _process(delta: float) -> void:
	var help_toggled = Input.is_action_pressed("toggle_help");
	music_option.visible = !help_toggled;
	sfx_option.visible = !help_toggled;
	help.visible = !help_toggled;
	controls.visible = help_toggled;
	if(Input.is_action_just_pressed("return_to_menu") and ground.has_control):
		returning_to_menu = true;
		ground.has_control = false;
		ground.despawn();

func beat() -> void:
	ground.beat();


func set_bus_states(n: Dictionary) -> void:
	bus_states = n;
	music_option.on = bus_states.get("Music", false);
	sfx_option.on = bus_states.get("SFX", false);

func _on_Ground_completed() -> void:
	emit_signal("completed")
	set_completed(true);
	pass # Replace with function body.


func _on_Ground_level_number_changed(amount) -> void:
	if(returning_to_menu):
		emit_signal("level_number_changed", -1);
	else:
		emit_signal("level_number_changed", level+amount);
	pass # Replace with function body.


func _on_Ground_is_dance_mode_changed(is_dance_mode) -> void:
	emit_signal("is_dance_mode_changed", is_dance_mode);
	if(!readied):
		yield(self, "ready");
	canvas_modulate.visible = is_dance_mode;
	if(is_dance_mode):
		world_environment.environment.glow_intensity = 3.0;
		world_environment.environment.glow_strength = 0.8;
	else:
		world_environment.environment.glow_intensity = 2.0;
		world_environment.environment.glow_strength = 0.6;
		
	pass # Replace with function body.


func set_completed(n: bool) -> void:
	completed = n;
	star.filled = completed;

