shader_type spatial;

uniform sampler2D texture_albedo : source_color;
uniform vec2 texture_world_size = vec2(2.0, 2.0);
uniform float blend_sharpness = 4.0;

varying vec3 local_pos;
varying vec3 local_normal;

void vertex() {
    // VERTEX y NORMAL ya están en espacio local, no hace falta transformar
    local_pos    = VERTEX;
    local_normal = normalize(NORMAL);
}

void fragment() {
    // Ajustar por escala: dividir entre la escala del objeto para mantener 2m x 2m
    vec3 scale = vec3(
        length(MODEL_MATRIX[0].xyz),
        length(MODEL_MATRIX[1].xyz),
        length(MODEL_MATRIX[2].xyz)
    );

    vec3 pos = local_pos * scale / vec3(texture_world_size.x, texture_world_size.y, texture_world_size.x);

    vec2 uv_x = pos.zy;
    vec2 uv_y = pos.xz;
    vec2 uv_z = pos.xy;

    vec3 col_x = texture(texture_albedo, uv_x).rgb;
    vec3 col_y = texture(texture_albedo, uv_y).rgb;
    vec3 col_z = texture(texture_albedo, uv_z).rgb;

    vec3 weights = pow(abs(local_normal), vec3(blend_sharpness));
    weights /= (weights.x + weights.y + weights.z);

    ALBEDO = col_x * weights.x + col_y * weights.y + col_z * weights.z;
	ROUGHNESS = 1.0;
}