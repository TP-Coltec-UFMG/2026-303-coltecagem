shader_type canvas_item;
// Granulado por cima da imagem: o ruído vira a transparência, e a cor vem
// do próprio nó (self_modulate do ColorRect).
void fragment() {
	float ruido = fract(sin(dot(UV * 431.0 + vec2(floor(TIME * 24.0)), vec2(12.9898, 78.233))) * 43758.5453);
	COLOR.a *= ruido;
}
