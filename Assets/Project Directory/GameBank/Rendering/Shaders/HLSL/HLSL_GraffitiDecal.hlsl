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
    float2 uv, // decal UV in [0,1]
    float2 worldPos2D, // PREPARED 2D world position seed (e.g. XZ, XY, or YZ)
    sampler2D tex, // atlas sampler
    float NumGraffiti,
    float AtlasCols,
    float AtlasRows,
    float MinScale,
    float MaxScale,
    float MinRotation,
    float MaxRotation,
    float MinOffset,
    float MaxOffset,
    float2 SeedScale, // per-axis world-scale (so you can tweak each)
    float SeedMultiplier
)
{
    // 1) Apply per-axis scale to your 2D world-pos seed
    float2 seed2D = frac(worldPos2D * SeedScale) * SeedMultiplier;

    float4 accum = float4(0, 0, 0, 0);
    int total = int(AtlasCols * AtlasRows);
    float2 tileSize = float2(1.0 / AtlasCols, 1.0 / AtlasRows);

    for (int i = 0; i < int(NumGraffiti); i++)
    {
        float2 s0 = seed2D + float2(i, -i * 0.618);

        // pick random cell
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

        // random decal-space offset
        float offXRaw = frac(sin(dot(s0 + float2(3, 3), float2(12.9898, 78.233))) * 43758.5453);
        float offYRaw = frac(sin(dot(s0 + float2(4, 4), float2(12.9898, 78.233))) * 43758.5453);
        float2 decalOff = float2(
            clamp(lerp(MinOffset, MaxOffset, offXRaw), MinOffset, MaxOffset),
            clamp(lerp(MinOffset, MaxOffset, offYRaw), MinOffset, MaxOffset)
        );

        // transform in [0,1] tile-space
        float2 centered = uv - float2(0.5, 0.5);
        float2 scaled = centered * sc;
        float ang = rotT * 6.2831853;
        float2 rotUV = float2(
            scaled.x * cos(ang) - scaled.y * sin(ang),
            scaled.x * sin(ang) + scaled.y * cos(ang)
        );

        float2 uvInTile = rotUV + float2(0.5, 0.5) + decalOff;

        // map & clamp into chosen cell
        float2 uvT = clamp(
            uvInTile * tileSize + baseOff,
            baseOff,
            baseOff + tileSize
        );

        float4 sampleColor = tex2D(tex, uvT);
        accum.rgb = lerp(accum.rgb, sampleColor.rgb, sampleColor.a);
        accum.a = saturate(accum.a + sampleColor.a);
    }

    return accum;
}