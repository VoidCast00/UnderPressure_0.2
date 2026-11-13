shader_type canvas_item;

uniform float fade_start : hint_range(0.0, 1.0) = 0.0; // where the fade begins (from bottom)
uniform float fade_end   : hint_range(0.0, 1.0) = 1.0; // where the image is fully visible

void fragment() {
    vec4 c = texture(TEXTURE, UV);
    // UV.y is 0 at the top and 1 at the bottom, so 1.0 - UV.y is 0 at the bottom
    float a = smoothstep(fade_start, fade_end, 1.0 - UV.y);
    COLOR = vec4(c.rgb, c.a * a);
}