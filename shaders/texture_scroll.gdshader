shader_type canvas_item;
// Rola a textura continuamente. direction_speed = voltas por segundo (x, y).
// offset_x/offset_y permitem animar o deslocamento por AnimationPlayer.
uniform vec2 direction_speed = vec2(0.0, 0.0);
uniform float offset_x = 0.0;
uniform float offset_y = 0.0;

void fragment() {
	vec2 uv = UV + vec2(offset_x, offset_y) + direction_speed * TIME;
	COLOR = texture(TEXTURE, fract(uv));
}
