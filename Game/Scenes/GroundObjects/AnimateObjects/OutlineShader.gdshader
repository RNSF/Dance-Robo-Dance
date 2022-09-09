shader_type canvas_item;

const int width = 10;
uniform vec4 outline_color : hint_color;
uniform bool active = false;

void fragment(){
	if(active){
		vec4 sprite_color = texture(TEXTURE, UV);
		
		float alpha = sprite_color.a;
		for(int x = -width; x < width; x++){
			for(int y = -width; y < width; y++){
				if(sqrt(float(x*x+y*y)) <= float(width)){
					alpha += texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE*vec2(float(x), float(y))).a;
				}
			}
		}
		
		vec3 final_color = mix(outline_color.rgb, sprite_color.rgb, sprite_color.a);
		COLOR = vec4(final_color, clamp(alpha, 0.0, 1.0));
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}