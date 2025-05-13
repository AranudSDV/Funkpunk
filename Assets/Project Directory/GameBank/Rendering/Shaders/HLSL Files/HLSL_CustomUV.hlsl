#ifndef DECAL_LOOP_HLSL
#define DECAL_LOOP_HLSL

#include "TransformUV.hlsl"   // your existing TransformUV function

TEXTURE2D(_Atlas);
SAMPLER(sampler_Atlas);

int _NumGraffiti;
int _AtlasCols, _AtlasRows;
float _MinScale, _MaxScale, _MaxOffset;

// Simple hash-based PRNG from seed
float Rand(in float2 s)
{
    return frac(sin(dot(s, float2(12.9898, 78.233))) * 43758.5453);
}

float4 ForEachGraffiti(float2 uv, float2 seed2D)
{
    float4 accum = float4(0, 0, 0, 0);
    int totalSprites = _AtlasCols * _AtlasRows;

    for (int i = 0; i < _NumGraffiti; i++)
    {
        // derive sub-seeds by adding offsets
        float2 s0 = seed2D + float2(i, -i * 0.618);
        // 1) pick sprite index
        float rIdx = Rand(s0 * 1.321);
        int idx = (int) floor(rIdx * totalSprites);
        float col = fmod(idx, _AtlasCols);
        float row = floor(idx / _AtlasCols);
        float2 baseOffset = float2(col, row) / float2(_AtlasCols, _AtlasRows);

        // 2) random scale
        float r1 = Rand(s0 + 1.0);
        float scale = lerp(_MinScale, _MaxScale, r1);

        // 3) random rotation in tours
        float rotT = Rand(s0 + 2.0);

        // 4) local offset
        float offX = lerp(-_MaxOffset, _MaxOffset, Rand(s0 + 3.0));
        float offY = lerp(-_MaxOffset, _MaxOffset, Rand(s0 + 4.0));
        float2 localOffset = float2(offX, offY);

        // 5) transform UV & sample
        float2 uvT = TransformUV(
            uv,
            float2(0.5, 0.5),
            float2(scale, scale),
            rotT,
            baseOffset + localOffset
        );
        accum += _Atlas.Sample(sampler_Atlas, uvT);
    }
    return accum;
}

#endif