shader_type canvas_item;

// 0: Normal, 1: Protanopia, 2: Deuteranopia, 3: Tritanopia, 4: Achromatopsia
uniform int mode : hint_range(0, 4) = 0;
uniform float severity: hint_range(0.0, 1.0) = 1.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Matrizes de Brettel
const mat3 brettel_protan_1 = mat3(
    vec3(0.14980, 1.19548, -0.34528),
    vec3(0.10764, 0.84864, 0.04372),
    vec3(0.00384, -0.00540, 1.00156)
);
const mat3 brettel_protan_2 = mat3(
    vec3(0.14570, 1.16172, -0.30742),
    vec3(0.10816, 0.85291, 0.03892),
    vec3(0.00386, -0.00524, 1.00139)
);
const vec3 brettel_protan_plane_normal = vec3(0.00048, 0.00393, -0.00441);

const mat3 brettel_deutan_1 = mat3(
    vec3(0.36477, 0.86381, -0.22858),
    vec3(0.26294, 0.64245, 0.09462),
    vec3(-0.02006, 0.02728, 0.99278)
);
const mat3 brettel_deutan_2 = mat3(
    vec3(0.37298, 0.88166, -0.25464),
    vec3(0.25954, 0.63506, 0.10540),
    vec3(-0.01980, 0.02784, 0.99196)
);
const vec3 brettel_deutan_plane_normal = vec3(-0.00281, -0.00611, 0.00892);

const mat3 brettel_tritan_1 = mat3(
    vec3(1.01277, 0.13548, -0.14826),
    vec3(-0.01243, 0.86812, 0.14431),
    vec3(0.07589, 0.80500, 0.11911)
);
const mat3 brettel_tritan_2 = mat3(
    vec3(0.93678, 0.18979, -0.12657),
    vec3(0.06154, 0.81526, 0.12320),
    vec3(-0.37562, 1.12767, 0.24796)
);
const vec3 brettel_tritan_plane_normal = vec3(0.03901, -0.02788, -0.01113);

// Funções de conversão sRGB -> Linear e Linear -> sRGB
vec3 linear_to_srgb(vec3 color) {
    color = clamp(color, vec3(0.0), vec3(1.0));
    return mix(
        (vec3(1.055) * pow(color, vec3(1.0 / 2.4))) - vec3(0.055),
        12.92 * color,
        lessThan(color, vec3(0.0031308))
    );
}

vec3 srgb_to_linear(vec3 color) {
    return mix(
        pow((color + vec3(0.055)) / vec3(1.055), vec3(2.4)),
        color / vec3(12.92),
        lessThan(color, vec3(0.04045))
    );
}

void fragment() {
    // 1. Captura a imagem DE TRÁS do ColorRect
    vec4 tex = textureLod(screen_texture, SCREEN_UV, 0.0);
    
    if (mode == 0 || severity == 0.0) {
        COLOR = tex;
    } else if (mode == 4) { // Achromatopsia (Escala de Cinza)
        float gray = 0.299 * tex.r + 0.587 * tex.g + 0.114 * tex.b;
        vec3 result = mix(tex.rgb, vec3(gray), severity);
        COLOR = vec4(result, tex.a);
    } else {
        // Converte para Linear para cálculos físicos precisos
        vec3 lin_rgb = srgb_to_linear(tex.rgb);
        vec3 rgb_cvd;

        if (mode == 1) { // Protanopia
            float d = dot(lin_rgb, brettel_protan_plane_normal);
            rgb_cvd = d >= 0.0 ? lin_rgb * brettel_protan_1 : lin_rgb * brettel_protan_2;
        } else if (mode == 2) { // Deuteranopia
            float d = dot(lin_rgb, brettel_deutan_plane_normal);
            rgb_cvd = d >= 0.0 ? lin_rgb * brettel_deutan_1 : lin_rgb * brettel_deutan_2;
        } else { // Tritanopia
            float d = dot(lin_rgb, brettel_tritan_plane_normal);
            rgb_cvd = d >= 0.0 ? lin_rgb * brettel_tritan_1 : lin_rgb * brettel_tritan_2;
        }

        rgb_cvd = clamp(rgb_cvd, 0.0, 1.0);
        rgb_cvd = mix(lin_rgb, rgb_cvd, severity);
        
        // Devolve para sRGB (espaço do monitor)
        COLOR = vec4(linear_to_srgb(rgb_cvd), tex.a);
    }
}