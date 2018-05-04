#version 450
#define _Irr
#define _EnvSky
#define _Rad
#define _EnvStr
#define _Deferred
#define _CSM
#define _Brdf
#define _IndPos
#define _SSAO
in vec3 pos;
in vec3 nor;
out vec3 wnormal;
out vec3 wposition;
out vec3 eyeDir;
out vec4 lampPos;
out vec4 wvpposition;
uniform mat3 N;
uniform mat4 WVP;
uniform mat4 W;
uniform vec3 eye;
uniform int lightShadow;
uniform mat4 LWVP;
void main() {
    vec4 spos = vec4(pos, 1.0);
	wnormal = normalize(N * nor);
	gl_Position = WVP * spos;
	wposition = vec4(W * spos).xyz;
	eyeDir = eye - wposition;
	if (lightShadow == 1) lampPos = LWVP * spos;
	wvpposition = gl_Position;
}
