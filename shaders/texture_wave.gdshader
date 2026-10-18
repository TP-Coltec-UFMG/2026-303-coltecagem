shader_type canvas_item;
// Ondula a imagem. speed = velocidade da onda, waves = quantidade de
// ondas, strength = intensidade em pixels, interval = se maior que 0,
// a onda anda "em degraus" a cada tantos segundos.
uniform vec2 speed = vec2(5.0, 0.0);
uniform vec2 waves = vec2(2.0, 0.0);
uniform vec2 strength = vec2(2.0, 2.0);
uniform float interval = 0.0;

void fragment() {
	float t = TIME;
	if (interval > 0.0) {
		t = floor(TIME / interval) * interval;
	}
	vec2 offset = vec2(
		sin(UV.y * waves.x * 6.28318 + t * speed.x) * strength.x,
		sin(UV.x * waves.y * 6.28318 + t * speed.y) * strength.y);
	COLOR = texture(TEXTURE, UV + offset * TEXTURE_PIXEL_SIZE);
}
