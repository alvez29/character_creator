shader_type canvas_item;

uniform float colors : hint_range(1.0, 16.0) = 4.0;
uniform float noise : hint_range(0.0, 1.0) = 0.1;
uniform float dither_strength : hint_range(0.0, 2.0) = 1.0;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

float bayer4x4(vec2 pos) {
    int x = int(mod(pos.x, 4.0));
    int y = int(mod(pos.y, 4.0));

    int matrix[16] = int[16](
         0,  8,  2, 10,
        12,  4, 14,  6,
         3, 11,  1,  9,
        15,  7, 13,  5
    );

    return float(matrix[y * 4 + x]) / 16.0;
}

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    // Umbral de Bayer ajustado al rango [-0.5, 0.5]
    float threshold = (bayer4x4(FRAGCOORD.xy) - 0.5) * dither_strength;

    // Cuantizar cada canal con el umbral aplicado
    vec3 quantized;
    quantized.r = floor((color.r + threshold / colors) * colors) / colors;
    quantized.g = floor((color.g + threshold / colors) * colors) / colors;
    quantized.b = floor((color.b + threshold / colors) * colors) / colors;

    COLOR.rgb = clamp(quantized, 0.0, 1.0);

    // Ruido estático encima
    float grain = random(FRAGCOORD.xy) * noise;
    COLOR.rgb += grain - (noise * 0.5);
    COLOR.rgb = clamp(COLOR.rgb, 0.0, 1.0);

    COLOR.a = color.a;
}