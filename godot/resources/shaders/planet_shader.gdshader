shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float planet_radius : hint_range(1000, 10000000) = 6371000.0;
uniform sampler2D noise_texture : hint_black;
uniform float biome_blend : hint_range(0, 1) = 0.5;
uniform int face_chunks_x : hint_range(1, 100000) = 40;

varying vec3 v_world_pos;
varying vec3 v_normal;
varying vec2 v_face_uv;
varying int v_face_id;

void vertex() {
	// VERTEX vem no espaço do cubo unitário [-0.5, 0.5]
	// Precisamos expandir para esfera
	vec3 cube_pos = VERTEX * 2.0;  // [-1, 1]
	vec3 sphere_dir = normalize(cube_pos);
	
	// Determina qual face baseado na componente dominante
	float abs_x = abs(cube_pos.x);
	float abs_y = abs(cube_pos.y);
	float abs_z = abs(cube_pos.z);
	
	int face;
	vec2 uv;
	
	if (abs_x >= abs_y && abs_x >= abs_z) {
		face = (cube_pos.x > 0.0) ? 0 : 2;  // +X ou -X
		uv = vec2(-cube_pos.z, cube_pos.y) / abs_x;
	} else if (abs_y >= abs_z) {
		face = (cube_pos.y > 0.0) ? 3 : 1;  // +Y ou -Y
		uv = vec2(cube_pos.x, cube_pos.z) / abs_y;
	} else {
		face = (cube_pos.z > 0.0) ? 4 : 5;  // +Z ou -Z
		uv = vec2(cube_pos.x, -cube_pos.y) / abs_z;
	}
	
	// UV para [0, 1]
	uv = uv * 0.5 + 0.5;
	
	v_face_id = face;
	v_face_uv = uv;
	v_normal = sphere_dir;
	v_world_pos = sphere_dir * planet_radius;
	
	VERTEX = v_world_pos;
}

void fragment() {
	// Bioma procedural simples baseado em face e UV
	vec3 color;
	
	// Cores base por face (para debug visual)
	vec3 face_colors[6] = vec3[6](
		vec3(0.8, 0.3, 0.3),  // 0: +X Right - vermelho
		vec3(0.3, 0.3, 0.8),  // 1: -Y Bottom - azul
		vec3(0.3, 0.8, 0.3),  // 2: -X Left - verde
		vec3(0.8, 0.8, 0.3),  // 3: +Y Top - amarelo
		vec3(0.8, 0.3, 0.8),  // 4: +Z Front - magenta
		vec3(0.3, 0.8, 0.8)   // 5: -Z Back - ciano
	);
	
	// Bioma por latitude (v_normal.y)
	float lat = v_normal.y;  // -1 a 1
	
	if (lat > 0.7) {
		color = vec3(0.9, 0.9, 1.0);  // Polar - gelo
	} else if (lat > 0.3) {
		color = vec3(0.4, 0.6, 0.3);  // Temperado norte
	} else if (lat > -0.3) {
		color = vec3(0.2, 0.7, 0.2);  // Equatorial - floresta
	} else if (lat > -0.7) {
		color = vec3(0.5, 0.5, 0.3);  // Temperado sul
	} else {
		color = vec3(0.8, 0.8, 0.9);  // Polar sul - gelo
	}
	
	// Adiciona ruído sutil
	float noise = texture(noise_texture, v_face_uv * 50.0).r;
	color += (noise - 0.5) * 0.1;
	
	// Grid de chunks (debug)
	vec2 chunk_uv = v_face_uv * float(face_chunks_x);
	float grid_line = max(
		abs(fract(chunk_uv.x) - 0.5) - 0.001,
		abs(fract(chunk_uv.y) - 0.5) - 0.001
	);
	if (grid_line < 0.0) {
		color *= 0.8;
	}
	
	ALBEDO = color;
	ALPHA = 1.0;
}