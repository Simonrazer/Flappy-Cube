#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform mat3 N;
uniform mat4 WVP;
uniform mat4 W;
uniform vec3 eye;
uniform int lightShadow;
uniform mat4 LWVP;

in vec3 pos;
out vec3 wnormal;
in vec3 nor;
out vec3 wposition;
out vec3 eyeDir;
out vec4 lampPos;
out vec4 wvpposition;

void main()
{
    vec4 spos = vec4(pos, 1.0);
    wnormal = normalize(N * nor);
    gl_Position = WVP * spos;
    wposition = vec4(W * spos).xyz;
    eyeDir = eye - wposition;
    if (lightShadow == 1)
    {
        lampPos = LWVP * spos;
    }
    wvpposition = gl_Position;
}

