extends "../GroundTile.gd"

onready var sprite := $MainSprite;
onready var disco_sprites := {
	"Light1" : $Light1Sprite,
}
var gradient_grid_start := -10;
var gradient_grid_end := 10;
var current_disco_sprite = null setget set_current_disco_sprite;

func _ready() -> void:
	sprite.material = sprite.material.duplicate();
	for disco_sprite in disco_sprites.values():
		disco_sprite.material = disco_sprite.material.duplicate();

func set_grid_position(n: Vector2) -> void:
	.set_grid_position(n);
	sprite.material.set_shader_param("start", (grid_position.y-gradient_grid_start)/(gradient_grid_end-gradient_grid_start));
	sprite.material.set_shader_param("end", (grid_position.y+1-gradient_grid_start)/(gradient_grid_end-gradient_grid_start));
	for disco_sprite in disco_sprites.values():
		disco_sprite.material.set_shader_param("start", (grid_position.y-gradient_grid_start)/(gradient_grid_end-gradient_grid_start));
		disco_sprite.material.set_shader_param("end", (grid_position.y+1-gradient_grid_start)/(gradient_grid_end-gradient_grid_start));

func disco_light():
	if(randi()%3 == 0):
		var new_disco_sprite = null;
		while(new_disco_sprite == null):
			new_disco_sprite = disco_sprites.values()[randi()%len(disco_sprites.values())];
			if(new_disco_sprite == current_disco_sprite and len(disco_sprites.values()) > 1):
				new_disco_sprite = null;
		set_current_disco_sprite(new_disco_sprite);
	else:
		set_current_disco_sprite(null);

func basic_light():
	set_current_disco_sprite(null);

func set_current_disco_sprite(n: Node):
	if(current_disco_sprite):
		current_disco_sprite.visible = false;
	current_disco_sprite = n;
	if(current_disco_sprite):
		current_disco_sprite.visible = true;
