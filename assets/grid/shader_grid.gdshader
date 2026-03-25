shader_type spatial;

uniform sampler2D texture_albedo : source_color;
uniform vec2 texture_world_size = vec2(2.0, 2.0);

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 world_uv = world_pos.xz / texture_world_size;
    ALBEDO = texture(texture_albedo, world_uv).rgb;
}