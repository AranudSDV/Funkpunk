#include "HLSL_TransformUV.hlsl"          // votre fonction HLSL

TEXTURE2D(_Atlas); SAMPLER(sampler_Atlas);

int _NumGraffiti, _AtlasCols, _AtlasRows;
float _MinScale, _MaxScale, _MinRotation, _MaxRotation;
float _MinOffset, _MaxOffset, _SeedMultiplier;

// PRNG stable
float Rand(float2 s)
{
    return frac(sin(dot(s, float2(12.9898, 78.233))) * 43758.5453);
}

float4 ForEachGraffiti(float2 uv, float3 worldPos)
{
    float2 seed2D = worldPos.xz * _SeedMultiplier;
    float4 accum = 0;
    int total = _AtlasCols * _AtlasRows;

    for (int i = 0; i < _NumGraffiti; i++)
    {
        float2 seed = seed2D + float2(i, -i * 0.618);

        // 1) Index de sprite
        int idx = (int) floor(Rand(seed * 1.321) * total);
        float col = fmod(idx, _AtlasCols);
        float row = floor(idx / _AtlasCols);
        float2 baseOffset = float2(col, row) / float2(_AtlasCols, _AtlasRows);

        // 2) Scale aléatoire, remappé et clampé
        float scRaw = Rand(seed + 1.0);
        float sc = clamp(lerp(_MinScale, _MaxScale, scRaw), _MinScale, _MaxScale);

        // 3) Rotation aléatoire (tours), remappée et clampée
        float rotRaw = Rand(seed + 2.0);
        float rotT = clamp(lerp(_MinRotation, _MaxRotation, rotRaw), _MinRotation, _MaxRotation);

        // 4) Offset local X/Y, remappé et clampé
        float offXRaw = Rand(seed + 3.0);
        float offYRaw = Rand(seed + 4.0);
        float offX = clamp(lerp(_MinOffset, _MaxOffset, offXRaw), _MinOffset, _MaxOffset);
        float offY = clamp(lerp(_MinOffset, _MaxOffset, offYRaw), _MinOffset, _MaxOffset);
        float2 localOff = float2(offX, offY);

        // 5) TransformUV (scale→rotate→translate) + sample
        float2 uvT = TransformUV(
            uv,
            float2(0.5, 0.5),
            float2(sc, sc),
            rotT,
            baseOffset + localOff
        );
        accum += _Atlas.Sample(sampler_Atlas, uvT);
    }
    return accum;
}
