#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform mat4 VP;

out vec3 color;
in vec3 col;
in vec3 pos;
out vec4 wvpposition;

void main()
{
    color = col;
    gl_Position = VP * vec4(pos, 1.0);
    wvpposition = gl_Position;
}

