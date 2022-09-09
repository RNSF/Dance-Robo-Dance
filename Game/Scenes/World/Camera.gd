extends Camera2D




var shake_strength := 0.0;
var shake_time := 0.0;
var shake_noise := Vector2(0, 0);
var cam_zoom := 1.0;
var cam_zoom_speed := 4.0;
var shake_speed := 4;


onready var noise = OpenSimplexNoise.new();
onready var cam_default_zoom = zoom;

func _ready():
	Global.camera = self;

func _process(delta):
	shake_noise.x = noise.get_noise_2d(OS.get_ticks_msec()*shake_speed, 0);
	shake_noise.y = noise.get_noise_2d(0, OS.get_ticks_msec()*shake_speed);
	offset = shake_noise*shake_strength;
	shake_time -= delta;
	if(shake_time <= 0):
		shake_strength = 0;
	
	#Quick Zoom
	zoom = cam_default_zoom*cam_zoom;
	cam_zoom = lerp(cam_zoom, 1, min(1, cam_zoom_speed*delta));
	if(cam_zoom < 1.01 and cam_zoom > 0.99): cam_zoom = 1;

func shake(strength: float, time: float) -> void:
	if(shake_strength < strength):
		shake_strength = strength;
		if(shake_time < time):
			shake_time = time;

func quick_zoom(amount):
	cam_zoom = min(amount, cam_zoom);
	pass
