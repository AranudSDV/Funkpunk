inline float getQuantRand(float2 s0, int i, int offsetSeed, int steps, int W)
{
    float2 seed = s0 + float2(i + offsetSeed, (i + offsetSeed) * 41 / 100);
    float raw = frac(sin(dot(seed, float2(12989, 78233))) * W);
    return floor(raw * steps + 0.5) / steps;
}

float4 SampleGraffitis(
    float2 uv, float2 seed2D, sampler2D tex,
    float NumGraffiti, float AtlasCols, float AtlasRows,
    float MinScaleX, float MaxScaleX,
    float MinScaleY, float MaxScaleY,
    float MinRotation, float MaxRotation,
    float MinOffsetX, float MaxOffsetX,
    float MinOffsetY, float MaxOffsetY)
{
    float4 accum = float4(0, 0, 0, 0);
    int total = int(AtlasCols * AtlasRows);
    float2 tileSz = float2(1.0 / AtlasCols, 1.0 / AtlasRows);
    const int W = 43758;
    const int stepsScale = 8, stepsRot = 12, stepsOffset = 8;

    for (int i = 0; i < int(NumGraffiti); i++)
    {
        float2 s0 = seed2D + float2(i, (i * 37) / 100);
        float rndIdx = frac(sin(dot(s0, float2(12989, 78233))) * W);
        int idx = int(floor(rndIdx * total));
        float2 cell = float2(idx % int(AtlasCols), idx / int(AtlasCols));
        float2 baseOff = cell * tileSz;
        float2 localUV = frac((uv - baseOff) / tileSz);
        float2 centered = localUV - 0.5;

        float qSX = getQuantRand(s0, i, 1, stepsScale, W);
        float qSY = getQuantRand(s0, i, 2, stepsScale, W);
        float qR = getQuantRand(s0, i, 3, stepsRot, W);
        float qOX = getQuantRand(s0, i, 4, stepsOffset, W);
        float qOY = getQuantRand(s0, i, 5, stepsOffset, W);

        float scX = lerp(MinScaleX, MaxScaleX, qSX);
        float scY = lerp(MinScaleY, MaxScaleY, qSY);
        float rot = lerp(MinRotation, MaxRotation, qR) * 6.2831853;
        float offX = lerp(MinOffsetX, MaxOffsetX, qOX);
        float offY = lerp(MinOffsetY, MaxOffsetY, qOY);

        float2 scaled = centered * float2(scX, scY);
        float2 rotated = float2(
            scaled.x * cos(rot) - scaled.y * sin(rot),
            scaled.x * sin(rot) + scaled.y * cos(rot)
        );

        float2 uvInTile = rotated + float2(0.5, 0.5) + float2(offX, offY);
        float2 uvT = clamp(baseOff + tileSz * uvInTile, baseOff, baseOff + tileSz);

        float4 c = tex2D(tex, uvT);
        accum.rgb = lerp(accum.rgb, c.rgb, c.a);
        accum.a = saturate(accum.a + c.a);
    }

    return accum;
}
