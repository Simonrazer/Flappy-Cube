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
void main() {
	vec3 n;
	float dotNV;
	float opacity;
	opacity = (1.0 - vec3(1.0, 1.0, 1.0).r);
	if (opacity < 0.10000000149011612) discard;
}
