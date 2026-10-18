shader_type canvas_item;
// Igual ao texture_scroll, mas com um leve balanço lateral em zigue-zague.
uniform vec2 direction_speed = vec2(0.0, 0.5);
uniform float offset_x = 0.0;
uniform float offset_y = 0.0;

void fragment() {
	vec2 uv = UV + vec2(offset_x, offset_y) + direction_speed * TIME;
	uv.x += 0.03 * sin(uv.y * 12.56636);
	COLOR = texture(TEXTURE, fract(uv));
}
