#version 330
#ifdef GL_ARB_shading_language_420pack
#extension GL_ARB_shading_language_420pack : require
#endif

void main()
{
    float opacity = 0.0;
    if (opacity < 0.100000001490116119384765625)
    {
        discard;
    }
}

