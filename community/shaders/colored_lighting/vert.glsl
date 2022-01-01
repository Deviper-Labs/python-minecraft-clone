#version 330

#define CHUNK_WIDTH 16
#define CHUNK_LENGTH 16

uniform ivec2 u_ChunkPosition;
uniform mat4 u_ModelViewProjMatrix;
uniform float u_Daylight;

layout(location = 0) in vec3 a_LocalPosition;
layout(location = 1) in float a_TextureFetcher;
layout(location = 2) in float a_Shading;
layout(location = 3) in float a_Light;

out vec3 v_Position;
out vec3 v_TexCoords;
out vec3 v_Light;

const vec2 texture_UV[4] = vec2[4](
	vec2(0.0, 1.0),
	vec2(0.0, 0.0),
	vec2(1.0, 0.0),
	vec2(1.0, 1.0)
);

void main(void) {
	v_Position = vec3(u_ChunkPosition.x * CHUNK_WIDTH + a_LocalPosition.x, 
						a_LocalPosition.y, 
						u_ChunkPosition.y * CHUNK_LENGTH + a_LocalPosition.z);
	v_TexCoords = vec3(texture_UV[int(a_TextureFetcher) & 3], int(a_TextureFetcher) >> 2);

	float blocklightMultiplier = pow(0.8, 15.0 - (int(a_Light) & 15));
	float skylightMultiplier = pow(0.8, 15.0 - (int(a_Light) >> 4));

	v_Light = vec3(
		min(max(skylightMultiplier * u_Daylight, blocklightMultiplier * 1.5), 1.0), 
		min(max(skylightMultiplier * u_Daylight, blocklightMultiplier * 1.25), 1.0), 
		min(max(blocklightMultiplier, skylightMultiplier * (2.0 - pow(u_Daylight, 2))), 1.0)
	) * a_Shading; 

	gl_Position = u_ModelViewProjMatrix * vec4(v_Position, 1.0);
}