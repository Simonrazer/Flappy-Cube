#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform vec2 texStep;
uniform sampler2D tex;
uniform sampler2D gbufferD;

in vec2 texCoord;
out vec4 fragColor;

vec3 tonemapFilmic(vec3 color)
{
    vec3 x = max(vec3(0.0), color - vec3(0.0040000001899898052215576171875));
    return (x * ((x * 6.19999980926513671875) + vec3(0.5))) / ((x * ((x * 6.19999980926513671875) + vec3(1.7000000476837158203125))) + vec3(0.0599999986588954925537109375));
}

void main()
{
    vec2 texCo = texCoord;
    vec2 tcrgbNW = texCo + (vec2(-1.0) * texStep);
    vec2 tcrgbNE = texCo + (vec2(1.0, -1.0) * texStep);
    vec2 tcrgbSW = texCo + (vec2(-1.0, 1.0) * texStep);
    vec2 tcrgbSE = texCo + (vec2(1.0) * texStep);
    vec2 tcrgbM = vec2(texCo);
    vec3 rgbNW = texture(tex, tcrgbNW).xyz;
    vec3 rgbNE = texture(tex, tcrgbNE).xyz;
    vec3 rgbSW = texture(tex, tcrgbSW).xyz;
    vec3 rgbSE = texture(tex, tcrgbSE).xyz;
    vec3 rgbM = texture(tex, tcrgbM).xyz;
    vec3 luma = vec3(0.2989999949932098388671875, 0.58700001239776611328125, 0.114000000059604644775390625);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM = dot(rgbM, luma);
    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
    vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y = (lumaNW + lumaSW) - (lumaNE + lumaSE);
    float dirReduce = max((((lumaNW + lumaNE) + lumaSW) + lumaSE) * 0.03125, 0.0078125);
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
    dir = min(vec2(8.0), max(vec2(-8.0), dir * rcpDirMin)) * texStep;
    vec3 rgbA = (texture(tex, texCo + (dir * -0.16666667163372039794921875)).xyz + texture(tex, texCo + (dir * 0.16666667163372039794921875)).xyz) * 0.5;
    vec3 rgbB = (rgbA * 0.5) + ((texture(tex, texCo + (dir * -0.5)).xyz + texture(tex, texCo + (dir * 0.5)).xyz) * 0.25);
    float lumaB = dot(rgbB, luma);
    if ((lumaB < lumaMin) || (lumaB > lumaMax))
    {
        fragColor = vec4(rgbA.x, rgbA.y, rgbA.z, fragColor.w);
    }
    else
    {
        fragColor = vec4(rgbB.x, rgbB.y, rgbB.z, fragColor.w);
    }
    vec3 _277 = tonemapFilmic(fragColor.xyz);
    fragColor = vec4(_277.x, _277.y, _277.z, fragColor.w);
}

