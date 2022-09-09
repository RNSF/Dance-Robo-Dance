extends "MenuOption.gd"


export var relevant_levels = [];
var completed_levels := [] setget set_completed_levels

onready var sub_label := $Sub/HBoxContainer/HBoxContainer/SubLabel;

func set_completed_levels(n: Array) -> void:
	completed_levels = n;
	var completed_relevant_level_count := 0;
	for level in relevant_levels:
		if(level in completed_levels):
			completed_relevant_level_count += 1;
	sub_label.text = str(completed_relevant_level_count) + "/" + str(len(relevant_levels));
