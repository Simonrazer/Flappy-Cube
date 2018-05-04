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
uniform mat4 LWVP;
void main() {
vec4 spos = vec4(pos, 1.0);
	gl_Position = LWVP * spos;
}
