extends "../World.gd"

signal play_selected
signal challenge_selected

onready var options := {
	Vector2(4, -3) : $Menu/PlayMenuOption,
	Vector2(4, -1) : $Menu/ChallengeMenuOption,
	Vector2(4, 1) : $Menu/QuitMenuOption,
}
onready var challenge_menu_option := $Menu/ChallengeMenuOption;
onready var play_menu_option := $Menu/PlayMenuOption;
onready var animation_player := $AnimationPlayer;
onready var logo := $Logo;

var selected_option = null setget set_selected_option;
var completed_levels := [] setget set_completed_levels;


func _on_PlayMenuOption_chosen() -> void:
	animation_player.play_backwards("ShowMenu");
	yield(get_tree().create_timer(ground.toggle_cells(false)+1),"timeout")
	emit_signal("play_selected");
	pass


func _on_ChallengeMenuOption_chosen() -> void:
	animation_player.play_backwards("ShowMenu");
	yield(get_tree().create_timer(ground.toggle_cells(false)+1),"timeout")
	emit_signal("challenge_selected");
	pass


func _on_QuitMenuOption_chosen() -> void:
	if(OS.get_name() != "HTML5"):
		get_tree().quit();
	pass


func _on_Ground_player_position_changed(pos: Vector2) -> void:
	if(!readied):
		yield(self, "ready");
	set_selected_option(options.get(pos));
	pass # Replace with function body.


func set_selected_option(n: Node) -> void:
	if(selected_option != n):
		if(selected_option):
			selected_option.selected = false;
		selected_option = n;
		if(selected_option):
			selected_option.selected = true;


func set_completed_levels(n: Array) -> void:
	completed_levels = n;
	play_menu_option.completed_levels = completed_levels;
	challenge_menu_option.completed_levels = completed_levels;


func beat() -> void:
	.beat();
	logo.beat();
