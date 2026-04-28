shader_type spatial;

uniform sampler2D texture_albedo;

render_mode cull_disabled;
render_mode unshaded;

void fragment() {
    vec4 color = texture(texture_albedo, UV);
    ALBEDO = color.rgb;
    ALPHA = color.a;
}