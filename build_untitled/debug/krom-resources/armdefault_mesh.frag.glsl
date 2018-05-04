#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

in vec3 wnormal;
out vec4 fragColor[2];

vec2 octahedronWrap(vec2 v)
{
    return (vec2(1.0) - abs(v.yx)) * vec2((v.x >= 0.0) ? 1.0 : -1.0, (v.y >= 0.0) ? 1.0 : -1.0);
}

float packFloat(float f1, float f2)
{
    float index = floor(f1 * 100.0);
    float alpha = clamp(f2, 0.0, 0.999000012874603271484375);
    return index + alpha;
}

void main()
{
    vec3 n = normalize(wnormal);
    vec3 basecol = vec3(0.800000011920928955078125);
    float roughness = 0.0;
    float metallic = 0.0;
    float occlusion = 1.0;
    n /= vec3((abs(n.x) + abs(n.y)) + abs(n.z));
    vec2 _80;
    if (n.z >= 0.0)
    {
        _80 = n.xy;
    }
    else
    {
        _80 = octahedronWrap(n.xy);
    }
    n = vec3(_80.x, _80.y, n.z);
    fragColor[0] = vec4(n.xy, packFloat(metallic, roughness), 1.0 - gl_FragCoord.z);
    fragColor[1] = vec4(basecol, occlusion);
}

