// Thank you StayAtHomeDev
// www.youtube.com/playlist?list=PLEHvj4yeNfeEzJBqNriKFOxS_hAuiu-p-

shader_type spatial;

// Depth Colors
uniform vec4 primary_color : source_color;
uniform vec4 secondary_color : source_color;

// Wave Normal Maps
uniform sampler2D normalmap_a : hint_normal;
uniform sampler2D normalMap_b : hint_normal;
uniform float normalmap_a_strength : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float normalmap_b_strength : hint_range(0.0, 1.0, 0.01) = 0.25;
uniform vec2 movement_direction = vec2(0.2,0.1);
uniform float movement_strength = 0.05;

// UV Settings
uniform float uv_scale = 1.0;

// Screen Textures
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

// Water Settings
uniform float roughness = 0.2;
uniform float depth_distance : hint_range(0.0, 20.0, 0.1) = 4.0;
uniform float beers_law : hint_range(0.0, 20.0, 0.1) = 12.0;
uniform float water_transparency : hint_range(0.0, 1.0, 0.001) = 0.0;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {

	float basic_fresnel = fresnel(3.0, NORMAL, VIEW);

	vec2 uv = UV * uv_scale;
	vec2 uv_movement = movement_direction * TIME * movement_strength;

	vec3 normalmap = texture(normalmap_a, uv + uv_movement).rbg * normalmap_a_strength;
	normalmap += texture(normalMap_b, uv - uv_movement).rgb * normalmap_b_strength;

	// Creatre refraction with normalmap
	vec3 ref_normalmap = normalmap * 2.0 - (normalmap_a_strength + normalmap_b_strength);
	vec3 ref_normal = mix(NORMAL, TANGENT * ref_normalmap + BINORMAL * ref_normalmap + NORMAL * ref_normalmap, 1.0);

	// Depth and Screen Texture Samples
	float depth_clean = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	vec3 screen = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;

	// Get Depth in World Position (Y)
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec3 ndc_clean = vec3(SCREEN_UV * 2.0 - 1.0, depth_clean); // Undistored UV
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float depth_texture_y = world.y / world.w;
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;

	// Get Depth in View Matrix
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z + VERTEX.z; // Checks if object is in front of water plane

	// Set Depth Blend and adjust with Beer's Law
	float depth_blend = clamp((vertex_y - depth_texture_y)/ depth_distance, 0.0, 1.0);
	depth_blend = exp(-depth_blend * beers_law);

	// Set depth color mix from depth blend and get final color mix using screen texture
	vec3 depth_color = mix(secondary_color, primary_color, depth_blend).rgb;
	vec3 refraction_texture = textureLod(screen_texture, SCREEN_UV, ROUGHNESS * 2.0).rgb;
	vec3 final_color = mix(depth_color, refraction_texture, water_transparency * depth_blend);

	ALBEDO = final_color;
	ROUGHNESS = roughness * (1.0 - basic_fresnel);
	NORMAL_MAP = normalmap;

}