#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

uniform vec3 H;
uniform vec3 A;
uniform vec3 B;
uniform vec3 C;
uniform vec3 D;
uniform vec3 E;
uniform vec3 F;
uniform vec3 G;
uniform vec3 I;
uniform vec3 sunDirection;
uniform vec3 Z;
uniform float envmapStrength;

in vec3 normal;
out vec4 fragColor;

vec3 hosekWilkie(float cos_theta, float gamma, float cos_gamma)
{
    vec3 chi = vec3(1.0 + (cos_gamma * cos_gamma)) / pow((vec3(1.0) + (H * H)) - (H * (2.0 * cos_gamma)), vec3(1.5));
    return (vec3(1.0) + (A * exp(B / vec3(cos_theta + 0.00999999977648258209228515625)))) * ((((C + (D * exp(E * gamma))) + (F * (cos_gamma * cos_gamma))) + (G * chi)) + (I * sqrt(cos_theta)));
}

void main()
{
    vec3 n = normalize(normal);
    float phi = acos(n.z);
    float theta = atan(-n.y, n.x) + 3.1415927410125732421875;
    float cos_theta = clamp(n.z, 0.0, 1.0);
    float cos_gamma = dot(n, sunDirection);
    float gamma_val = acos(cos_gamma);
    float param = cos_theta;
    float param_1 = gamma_val;
    float param_2 = cos_gamma;
    vec3 _136 = (Z * hosekWilkie(param, param_1, param_2)) * envmapStrength;
    fragColor = vec4(_136.x, _136.y, _136.z, fragColor.w);
}

