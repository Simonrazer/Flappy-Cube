#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform vec4 casData[20];
uniform sampler2D gbuffer0;
uniform sampler2D gbuffer1;
uniform vec3 eye;
uniform vec3 eyeLook;
uniform vec2 cameraProj;
uniform vec3 l;
uniform int lightShadow;
uniform sampler2D shadowMap;
uniform float shadowsBias;
uniform vec3 lightColor;

in vec2 texCoord;
in vec3 viewRay;
out vec4 fragColor;

vec2 octahedronWrap(vec2 v)
{
    return (vec2(1.0) - abs(v.yx)) * vec2((v.x >= 0.0) ? 1.0 : -1.0, (v.y >= 0.0) ? 1.0 : -1.0);
}

vec3 getPos(vec3 eye_1, vec3 eyeLook_1, vec3 viewRay_1, float depth, vec2 cameraProj_1)
{
    vec3 vray = normalize(viewRay_1);
    float linearDepth = cameraProj_1.y / (((depth * 0.5) + 0.5) - cameraProj_1.x);
    float viewZDist = dot(eyeLook_1, vray);
    vec3 wposition = eye_1 + (vray * (linearDepth / viewZDist));
    return wposition;
}

vec2 unpackFloat(float f)
{
    return vec2(floor(f) / 100.0, fract(f));
}

vec3 surfaceAlbedo(vec3 baseColor, float metalness)
{
    return mix(baseColor, vec3(0.0), vec3(metalness));
}

vec3 surfaceF0(vec3 baseColor, float metalness)
{
    return mix(vec3(0.039999999105930328369140625), baseColor, vec3(metalness));
}

mat4 getCascadeMat(float d, inout int casi, inout int casIndex)
{
    vec4 comp = vec4(float(d > casData[16].x), float(d > casData[16].y), float(d > casData[16].z), float(d > casData[16].w));
    casi = int(min(dot(vec4(1.0), comp), 4.0));
    casIndex = casi * 4;
    return mat4(vec4(casData[casIndex + 0]), vec4(casData[casIndex + 1]), vec4(casData[casIndex + 2]), vec4(casData[casIndex + 3]));
}

float shadowCompare(sampler2D shadowMap_1, vec2 uv, float compare)
{
    float depth = texture(shadowMap_1, uv).x;
    return step(compare, depth);
}

float shadowLerp(sampler2D shadowMap_1, vec2 uv, float compare, vec2 smSize)
{
    vec2 texelSize = vec2(1.0) / smSize;
    vec2 f = fract((uv * smSize) + vec2(0.5));
    vec2 centroidUV = floor((uv * smSize) + vec2(0.5)) / smSize;
    float lb = shadowCompare(shadowMap_1, centroidUV, compare);
    float lt = shadowCompare(shadowMap_1, centroidUV + (texelSize * vec2(0.0, 1.0)), compare);
    float rb = shadowCompare(shadowMap_1, centroidUV + (texelSize * vec2(1.0, 0.0)), compare);
    float rt = shadowCompare(shadowMap_1, centroidUV + texelSize, compare);
    float a = mix(lb, lt, f.y);
    float b = mix(rb, rt, f.y);
    float c = mix(a, b, f.x);
    return c;
}

float PCF(sampler2D shadowMap_1, vec2 uv, float compare, vec2 smSize)
{
    float result = shadowLerp(shadowMap_1, uv + (vec2(-1.0) / smSize), compare, smSize);
    result += shadowLerp(shadowMap_1, uv + (vec2(-1.0, 0.0) / smSize), compare, smSize);
    result += shadowLerp(shadowMap_1, uv + (vec2(-1.0, 1.0) / smSize), compare, smSize);
    result += shadowLerp(shadowMap_1, uv + (vec2(0.0, -1.0) / smSize), compare, smSize);
    result += shadowLerp(shadowMap_1, uv, compare, smSize);
    result += shadowLerp(shadowMap_1, uv + (vec2(0.0, 1.0) / smSize), compare, smSize);
    result += shadowLerp(shadowMap_1, uv + (vec2(1.0, -1.0) / smSize), compare, smSize);
    result += shadowLerp(shadowMap_1, uv + (vec2(1.0, 0.0) / smSize), compare, smSize);
    result += shadowLerp(shadowMap_1, uv + (vec2(1.0) / smSize), compare, smSize);
    return result / 9.0;
}

float shadowTest(sampler2D shadowMap_1, vec3 lPos, float shadowsBias_1, vec2 smSize)
{
    bool _306 = lPos.x < 0.0;
    bool _312;
    if (!_306)
    {
        _312 = lPos.y < 0.0;
    }
    else
    {
        _312 = _306;
    }
    bool _318;
    if (!_312)
    {
        _318 = lPos.x > 1.0;
    }
    else
    {
        _318 = _312;
    }
    bool _324;
    if (!_318)
    {
        _324 = lPos.y > 1.0;
    }
    else
    {
        _324 = _318;
    }
    if (_324)
    {
        return 1.0;
    }
    return PCF(shadowMap_1, lPos.xy, lPos.z - shadowsBias_1, smSize);
}

float shadowTestCascade(sampler2D shadowMap_1, vec3 eye_1, vec3 p, float shadowsBias_1, vec2 smSize)
{
    float d = distance(eye_1, p);
    int param;
    int param_1;
    mat4 _422 = getCascadeMat(d, param, param_1);
    int casi = param;
    int casIndex = param_1;
    mat4 LWVP = _422;
    vec4 lPos = LWVP * vec4(p, 1.0);
    float visibility = 1.0;
    if (lPos.w > 0.0)
    {
        visibility = shadowTest(shadowMap_1, lPos.xyz / vec3(lPos.w), shadowsBias_1, smSize);
    }
    float nextSplit = casData[16][casi];
    float _450;
    if (casi == 0)
    {
        _450 = nextSplit;
    }
    else
    {
        _450 = nextSplit - (casData[16][casi - 1]);
    }
    float splitSize = _450;
    float splitDist = (nextSplit - d) / splitSize;
    float visibility2;
    if ((splitDist <= 0.1500000059604644775390625) && (casi != 3))
    {
        int casIndex2 = casIndex + 4;
        mat4 LWVP2 = mat4(vec4(casData[casIndex2 + 0]), vec4(casData[casIndex2 + 1]), vec4(casData[casIndex2 + 2]), vec4(casData[casIndex2 + 3]));
        vec4 lPos2 = LWVP2 * vec4(p, 1.0);
        visibility2 = 1.0;
        if (lPos2.w > 0.0)
        {
            visibility2 = shadowTest(shadowMap_1, lPos2.xyz / vec3(lPos2.w), shadowsBias_1, smSize);
        }
        float lerpAmt = smoothstep(0.0, 0.1500000059604644775390625, splitDist);
        return mix(visibility2, visibility, lerpAmt);
    }
    return visibility;
}

vec3 lambertDiffuseBRDF(vec3 albedo, float nl)
{
    return albedo * max(0.0, nl);
}

float d_ggx(float nh, float a)
{
    float a2 = a * a;
    float denom = pow(((nh * nh) * (a2 - 1.0)) + 1.0, 2.0);
    return (a2 * 0.3183098733425140380859375) / denom;
}

float v_smithschlick(float nl, float nv, float a)
{
    return 1.0 / (((nl * (1.0 - a)) + a) * ((nv * (1.0 - a)) + a));
}

vec3 f_schlick(vec3 f0, float vh)
{
    return f0 + ((vec3(1.0) - f0) * exp2(((-5.554729938507080078125 * vh) - 6.9831600189208984375) * vh));
}

vec3 specularBRDF(vec3 f0, float roughness, float nl, float nh, float nv, float vh)
{
    float a = roughness * roughness;
    return (f_schlick(f0, vh) * (d_ggx(nh, a) * clamp(v_smithschlick(nl, nv, a), 0.0, 1.0))) / vec3(4.0);
}

void main()
{
    vec4 g0 = texture(gbuffer0, texCoord);
    vec4 g1 = texture(gbuffer1, texCoord);
    float depth = ((1.0 - g0.w) * 2.0) - 1.0;
    vec3 n;
    n.z = (1.0 - abs(g0.x)) - abs(g0.y);
    vec3 v;
    float dotNV;
    vec2 _622;
    vec2 metrough;
    vec3 albedo;
    vec3 f0;
    float dotNL;
    float visibility;
    if (n.z >= 0.0)
    {
        _622 = g0.xy;
    }
    else
    {
        _622 = octahedronWrap(g0.xy);
    }
    n = vec3(_622.x, _622.y, n.z);
    n = normalize(n);
    vec3 p = getPos(eye, eyeLook, viewRay, depth, cameraProj);
    metrough = unpackFloat(g0.z);
    v = normalize(eye - p);
    dotNV = dot(n, v);
    albedo = surfaceAlbedo(g1.xyz, metrough.x);
    f0 = surfaceF0(g1.xyz, metrough.x);
    dotNL = dot(n, l);
    visibility = 1.0;
    if (lightShadow == 1)
    {
        visibility = shadowTestCascade(shadowMap, eye, p + ((n * shadowsBias) * 10.0), shadowsBias, vec2(4096.0, 1024.0));
    }
    vec3 h = normalize(v + l);
    float dotNH = dot(n, h);
    float dotVH = dot(v, h);
    vec3 _731 = lambertDiffuseBRDF(albedo, dotNL) + specularBRDF(f0, metrough.y, dotNL, dotNH, dotNV, dotVH);
    fragColor = vec4(_731.x, _731.y, _731.z, fragColor.w);
    vec3 _738 = fragColor.xyz * lightColor;
    fragColor = vec4(_738.x, _738.y, _738.z, fragColor.w);
    vec3 _744 = fragColor.xyz * visibility;
    fragColor = vec4(_744.x, _744.y, _744.z, fragColor.w);
}

