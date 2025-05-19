//float4 SampleGraffitis(
//    float2 uv,
//    float2 seed2D,
//    sampler2D tex,
//    float NumGraffiti,
//    float AtlasCols,
//    float AtlasRows,
//    float MinScale,
//    float MaxScale,
//    float MinRotation,
//    float MaxRotation,
//    float MinOffset,
//    float MaxOffset,
//    float SeedMultiplier
//)
//{
//    seed2D *= SeedMultiplier;
//    float4 accum = float4(0, 0, 0, 0);
//    int total = AtlasCols * AtlasRows;
//    float2 tileSize = float2(1.0 / AtlasCols, 1.0 / AtlasRows);

//    for (int i = 0; i < NumGraffiti; i++)
//    {
//        float2 s0 = seed2D + float2(i, -i * 0.618);
//        int idx = (int) floor(frac(sin(dot(s0 * 1.321, float2(12.9898, 78.233))) * 43758.5453) * total);
//        float2 baseOff = float2(fmod(idx, AtlasCols), floor(idx / AtlasCols)) * tileSize;

//        float scRaw = frac(sin(dot(s0 + 1.0, float2(12.9898, 78.233))) * 43758.5453);
//        float sc = clamp(lerp(MinScale, MaxScale, scRaw), MinScale, MaxScale);

//        float rotRaw = frac(sin(dot(s0 + 2.0, float2(12.9898, 78.233))) * 43758.5453);
//        float rotT = clamp(lerp(MinRotation, MaxRotation, rotRaw), MinRotation, MaxRotation);

//        float offXRaw = frac(sin(dot(s0 + 3.0, float2(12.9898, 78.233))) * 43758.5453);
//        float offYRaw = frac(sin(dot(s0 + 4.0, float2(12.9898, 78.233))) * 43758.5453);
//        float2 localOff = float2(
//            clamp(lerp(MinOffset, MaxOffset, offXRaw), MinOffset, MaxOffset),
//            clamp(lerp(MinOffset, MaxOffset, offYRaw), MinOffset, MaxOffset)) * tileSize;

//        float2 uvTile = uv * tileSize;
//        float2 centered = uvTile - float2(0.5, 0.5);
//        float2 scaled = centered * sc;

//        //float TWO_PI = 6.28318530718;
//        float angle = rotT * 6.2831853f;
//        float c = cos(angle);
//        float s = sin(angle);
//        float2 rotated = float2(scaled.x * c - scaled.y * s, scaled.x * s + scaled.y * c);

//        float2 uvT = saturate(rotated + float2(0.5, 0.5) + baseOff + localOff);

        
//        //float4 sample = Atlas.Sample(Atlas_sampler, uvT, 0.0);
//        float4 sample = tex2D(tex, uvT);
//        accum.rgb = lerp(accum.rgb, sample.rgb, sample.a);
//        accum.a = saturate(accum.a + sample.a);
//    }
    
//    return accum;
//    //return float4(1, 0, 0, 1);

//}

float4 SampleGraffitis(
    float2 uv,
    float2 seed2D,
    sampler2D tex,
    float NumGraffiti,
    float AtlasCols,
    float AtlasRows,
    float MinScale,
    float MaxScale,
    float MinRotation,
    float MaxRotation,
    float MinOffset,
    float MaxOffset,
    float SeedMultiplier
)
{
    float2 baseSeed = seed2D * SeedMultiplier;
    float4 accum = float4(0, 0, 0, 0);
    int total = int(AtlasCols * AtlasRows);
    float2 tileSize = float2(1.0 / AtlasCols, 1.0 / AtlasRows);

    for (int i = 0; i < int(NumGraffiti); i++)
    {
        float2 s0 = baseSeed + float2(i, -i * 0.618);

        // pick random tile
        float rndIdx = frac(sin(dot(s0 * 1.321, float2(12.9898, 78.233))) * 43758.5453);
        int idx = int(floor(rndIdx * total));
        float2 cell = float2(fmod(idx, AtlasCols), floor(idx / AtlasCols));
        float2 baseOff = cell * tileSize;

        // random scale
        float scRaw = frac(sin(dot(s0 + float2(1, 1), float2(12.9898, 78.233))) * 43758.5453);
        float sc = clamp(lerp(MinScale, MaxScale, scRaw), MinScale, MaxScale);

        // random rotation
        float rotRaw = frac(sin(dot(s0 + float2(2, 2), float2(12.9898, 78.233))) * 43758.5453);
        float rotT = clamp(lerp(MinRotation, MaxRotation, rotRaw), MinRotation, MaxRotation);

        // random decal offset
        float offXRaw = frac(sin(dot(s0 + float2(3, 3), float2(12.9898, 78.233))) * 43758.5453);
        float offYRaw = frac(sin(dot(s0 + float2(4, 4), float2(12.9898, 78.233))) * 43758.5453);
        float2 decalOff = float2(
            clamp(lerp(MinOffset, MaxOffset, offXRaw), MinOffset, MaxOffset),
            clamp(lerp(MinOffset, MaxOffset, offYRaw), MinOffset, MaxOffset)
        );

        // local UV in single tile
        float2 localUV = uv;

        // center, scale, rotate around 0.5
        float2 centered = localUV - float2(0.5, 0.5);
        float2 scaled = centered * sc;
        float angle = rotT * 6.2831853;
        float c = cos(angle);
        float s = sin(angle);
        float2 rotated = float2(
            scaled.x * c - scaled.y * s,
            scaled.x * s + scaled.y * c
        );

        // back to [0,1], apply decal offset
        float2 uvInTile = rotated + float2(0.5, 0.5) + decalOff;

        // map into atlas cell
        float2 uvT = uvInTile * tileSize + baseOff;

        // clamp within cell
        uvT = clamp(uvT, baseOff, baseOff + tileSize);

        // sample and blend
        float4 sampleColor = tex2D(tex, uvT);
        accum.rgb = lerp(accum.rgb, sampleColor.rgb, sampleColor.a);
        accum.a = saturate(accum.a + sampleColor.a);
    }

    return accum;
}