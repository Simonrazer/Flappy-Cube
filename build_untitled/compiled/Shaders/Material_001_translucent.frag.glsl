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
#include "compiled.glsl"
#include "std/brdf.glsl"
#include "std/math.glsl"
#include "std/shirr.glsl"
#include "std/shadows.glsl"
#include "compiled.glsl"
in vec3 wnormal;
in vec3 wposition;
in vec3 eyeDir;
in vec4 lampPos;
in vec4 wvpposition;
out vec4[2] fragColor;
uniform vec3 lightColor;
uniform vec3 lightDir;
uniform vec3 lightPos;
uniform int lightType;
uniform vec2 spotlightData;
uniform float envmapStrength;
uniform sampler2D senvmapBrdf;
uniform sampler2D senvmapRadiance;
uniform int envmapNumMipmaps;
uniform sampler2D shadowMap;
uniform samplerCube shadowMapCube;
uniform bool receiveShadow;
uniform float shadowsBias;
uniform int lightShadow;
uniform vec2 lightProj;
uniform vec3 eye;
void main() {
vec3 n = normalize(wnormal);

    vec3 vVec = normalize(eyeDir);
    float dotNV = max(dot(n, vVec), 0.0);

	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float opacity;
	basecol = vec3(0.8);
	roughness = 0.0;
	metallic = 0.0;
	occlusion = 1.0;
	opacity = (1.0 - vec3(1.0, 1.0, 1.0).r);
	float visibility = 1.0;
	vec3 lp = lightPos - wposition;
	vec3 l;
	if (lightType == 0) l = lightDir;
	else { l = normalize(lp); visibility *= attenuate(distance(wposition, lightPos)); }
	vec3 h = normalize(vVec + l);
	float dotNL = dot(n, l);
	float dotNH = dot(n, h);
	float dotVH = dot(vVec, h);
	if (receiveShadow) {
	    if (lightShadow == 1) {
	vec2 smSize;
	vec3 lPos;
	if (lightType == 0) {
	    int casi;
	    int casindex;
	    mat4 LWVP = getCascadeMat(distance(eye, wposition), casi, casindex);
	    vec4 lampPos = LWVP * vec4(wposition, 1.0);
	    lPos = lampPos.xyz / lampPos.w;
	    smSize = shadowmapSize * vec2(shadowmapCascades, 1.0);
	}
	else {
	    lPos = lampPos.xyz / lampPos.w;
	    smSize = shadowmapSize;
	}
	    visibility *= PCF(shadowMap, lPos.xy, lPos.z - shadowsBias, smSize);
	    }
	    else if (lightShadow == 2) visibility *= PCFCube(shadowMapCube, lp, -l, shadowsBias, lightProj, n);
	}
	if (lightType == 2) {
	    float spotEffect = dot(lightDir, l);
	    if (spotEffect < spotlightData.x) {
	        visibility *= smoothstep(spotlightData.y, spotlightData.x, spotEffect);
	    }
	}
	vec3 albedo = surfaceAlbedo(basecol, metallic);
	vec3 f0 = surfaceF0(basecol, metallic);
	vec3 direct;
	direct = lambertDiffuseBRDF(albedo, dotNL);
	direct += specularBRDF(f0, roughness, dotNL, dotNH, dotNV, dotVH);
	vec2 envBRDF = texture(senvmapBrdf, vec2(roughness, 1.0 - dotNV)).xy;
	vec3 indirect = shIrradiance(n);
	indirect *= albedo;
	vec3 reflectionWorld = reflect(-vVec, n);
	float lod = getMipFromRoughness(roughness, envmapNumMipmaps);
	vec3 prefilteredColor = textureLod(senvmapRadiance, envMapEquirect(reflectionWorld), lod).rgb;
	indirect += prefilteredColor * (f0 * envBRDF.x + envBRDF.y) * 1.5;
	indirect *= envmapStrength;	

	vec4 premultipliedReflect = vec4(vec3(direct * visibility + indirect * occlusion), opacity);
	float fragZ = wvpposition.z / wvpposition.w;
	float a = min(1.0, premultipliedReflect.a) * 8.0 + 0.01;
	float b = -fragZ * 0.95 + 1.0;
	float w = clamp(a * a * a * 1e8 * b * b * b, 1e-2, 3e2);
	fragColor[0] = vec4(premultipliedReflect.rgb * w, premultipliedReflect.a);
	fragColor[1] = vec4(premultipliedReflect.a * w, 0.0, 0.0, 1.0);
}
