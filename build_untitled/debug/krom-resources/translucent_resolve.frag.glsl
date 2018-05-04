#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform sampler2D gbuffer0;
uniform sampler2D gbuffer1;
uniform sampler2D gbufferD;

in vec2 texCoord;
out vec4 fragColor;

void main()
{
    vec4 accum = texture(gbuffer0, texCoord);
    float revealage = accum.w;
    if (revealage == 1.0)
    {
        discard;
    }
    accum.w = texture(gbuffer1, texCoord).x;
    fragColor = vec4(accum.xyz / vec3(clamp(accum.w, 9.9999997473787516355514526367188e-05, 50000.0)), 1.0 - revealage);
}

