shader_type canvas_item;
// Desfoque simples (média de 9 pontos). strength = raio em pixels.
uniform float strength = 6.0;

void fragment() {
	vec2 px = TEXTURE_PIXEL_SIZE * strength;
	vec4 soma = vec4(0.0);
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			soma += texture(TEXTURE, UV + vec2(float(x), float(y)) * px);
		}
	}
	COLOR = soma / 9.0;
}
