#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

out vec4 fragColor[2];
in vec3 color;
vec4 wvpposition;

void main()
{
    fragColor[0] = vec4(1.0, 1.0, 0.0, 1.0 - (((wvpposition.z / wvpposition.w) * 0.5) + 0.5));
    fragColor[1] = vec4(color, 1.0);
}

