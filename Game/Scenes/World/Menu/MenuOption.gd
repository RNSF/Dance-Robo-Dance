extends VBoxContainer

signal chosen

onready var label := $Label;
onready var sub := $Sub;

var selected := false setget set_selected;

func _ready() -> void:
	set_selected(false);


func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("ui_select") and selected):
		emit_signal("chosen");

func set_selected(n: bool) -> void:
	selected = n;
	sub.visible = selected;
