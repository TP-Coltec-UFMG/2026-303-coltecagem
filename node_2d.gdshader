shader_type canvas_item;

// lod controla a força do desfoque
uniform float lod: hint_range(0.0, 5.0) = 2.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment(){
	// Essa linha pega a imagem que está atrás do ColorRect e desfoca
	vec4 color = texture(screen_texture, SCREEN_UV, lod);
	COLOR = color;
}