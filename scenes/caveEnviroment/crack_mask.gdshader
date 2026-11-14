shader_type canvas_item;

//draws the crack only where the tile under it has pixels
//so it follows the shape of edge rock tiles, ores and crystals

uniform sampler2D rock_tex : filter_nearest;
uniform vec4 rock_region;  //xy = uv start, zw = uv size of the tile inside its png
uniform sampler2D ore_tex : filter_nearest;
uniform vec4 ore_region;
uniform bool has_ore = false;

void fragment() {
	vec4 crack = texture(TEXTURE, UV);
	float mask = texture(rock_tex, rock_region.xy + UV * rock_region.zw).a;
	if (has_ore) {
		mask = max(mask, texture(ore_tex, ore_region.xy + UV * ore_region.zw).a);
	}
	COLOR = vec4(crack.rgb, crack.a * mask);
}
