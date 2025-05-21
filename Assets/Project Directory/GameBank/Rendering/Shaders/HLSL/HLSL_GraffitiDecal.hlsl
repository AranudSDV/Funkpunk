float4 SampleGraffitis(
    float2 uv,
    float2 seed2D, // NOW precomputed by the graph
    sampler2D tex,
    float NumGraffiti,
    float AtlasCols,
    float AtlasRows,

    float MinScaleX,
    float MaxScaleX,
    float MinScaleY,
    float MaxScaleY,

    float MinRotation,
    float MaxRotation,

    float MinOffsetX,
    float MaxOffsetX,
    float MinOffsetY,
    float MaxOffsetY
)
{
    float4 accum = float4(0, 0, 0, 0);
    int total = int(AtlasCols * AtlasRows);
    float2 tileSize = float2(1.0 / AtlasCols, 1.0 / AtlasRows);

    for (int i = 0; i < int(NumGraffiti); i++)
    {
        // use the graph’s seed2D directly
        float2 s0 = seed2D + float2(i, -i * 0.618);

        // pick a sprite index
        float rndIdx = frac(sin(dot(s0 * 1.321, float2(12.9898, 78.233))) * 43758.5453);
        int idx = int(floor(rndIdx * total));
        float2 cell = float2(fmod(idx, AtlasCols), floor(idx / AtlasCols));
        float2 baseOff = cell * tileSize;

        // random X scale
        float scXRaw = frac(sin(dot(s0 + float2(1, 1), float2(12.9898, 78.233))) * 43758.5453);
        float scX = clamp(lerp(MinScaleX, MaxScaleX, scXRaw), MinScaleX, MaxScaleX);

        // random Y scale
        float scYRaw = frac(sin(dot(s0 + float2(2, 2), float2(12.9898, 78.233))) * 43758.5453);
        float scY = clamp(lerp(MinScaleY, MaxScaleY, scYRaw), MinScaleY, MaxScaleY);

        // random rotation
        float rotRaw = frac(sin(dot(s0 + float2(3, 3), float2(12.9898, 78.233))) * 43758.5453);
        float rotT = clamp(lerp(MinRotation, MaxRotation, rotRaw), MinRotation, MaxRotation);

        // random X offset
        float offXRaw = frac(sin(dot(s0 + float2(4, 4), float2(12.9898, 78.233))) * 43758.5453);
        float offX = clamp(lerp(MinOffsetX, MaxOffsetX, offXRaw), MinOffsetX, MaxOffsetX);

        // random Y offset
        float offYRaw = frac(sin(dot(s0 + float2(5, 5), float2(12.9898, 78.233))) * 43758.5453);
        float offY = clamp(lerp(MinOffsetY, MaxOffsetY, offYRaw), MinOffsetY, MaxOffsetY);

        float2 decalOff = float2(offX, offY);

        // transform UV within [0,1] tile
        float2 centered = uv - float2(0.5, 0.5);
        float2 scaled = float2(centered.x * scX, centered.y * scY);
        float angle = rotT * 6.2831853;
        float2 rotated = float2(
            scaled.x * cos(angle) - scaled.y * sin(angle),
            scaled.x * sin(angle) + scaled.y * cos(angle)
        );

        float2 uvInTile = rotated + float2(0.5, 0.5) + decalOff;

        // map & clamp into atlas cell
        float2 uvT = clamp(
            uvInTile * tileSize + baseOff,
            baseOff,
            baseOff + tileSize
        );

        float4 sampleC = tex2D(tex, uvT);
        accum.rgb = lerp(accum.rgb, sampleC.rgb, sampleC.a);
        accum.a = saturate(accum.a + sampleC.a);
    }

    return accum;



//float4 SampleGraffitis(
//    float2 uv, // decal UV in [0,1]
//    float2 worldPos2D, // PREPARED 2D world position seed (e.g. XZ, XY, or YZ)
//    sampler2D tex, // atlas sampler
//    float NumGraffiti,
//    float AtlasCols,
//    float AtlasRows,
//    float MinScale,
//    float MaxScale,
//    float MinRotation,
//    float MaxRotation,
//    float MinOffset,
//    float MaxOffset,
//    float2 SeedScale, // per-axis world-scale (so you can tweak each)
//    float SeedMultiplier
//)
//{
//    // 1) Apply per-axis scale to your 2D world-pos seed
//    float2 seed2D = frac(worldPos2D * SeedScale) * SeedMultiplier;

//    float4 accum = float4(0, 0, 0, 0);
//    int total = int(AtlasCols * AtlasRows);
//    float2 tileSize = float2(1.0 / AtlasCols, 1.0 / AtlasRows);

//    for (int i = 0; i < int(NumGraffiti); i++)
//    {
//        float2 s0 = seed2D + float2(i, -i * 0.618);

//        // pick random cell
//        float rndIdx = frac(sin(dot(s0 * 1.321, float2(12.9898, 78.233))) * 43758.5453);
//        int idx = int(floor(rndIdx * total));
//        float2 cell = float2(fmod(idx, AtlasCols), floor(idx / AtlasCols));
//        float2 baseOff = cell * tileSize;

//        // random scale
//        float scRaw = frac(sin(dot(s0 + float2(1, 1), float2(12.9898, 78.233))) * 43758.5453);
//        float sc = clamp(lerp(MinScale, MaxScale, scRaw), MinScale, MaxScale);

//        // random rotation
//        float rotRaw = frac(sin(dot(s0 + float2(2, 2), float2(12.9898, 78.233))) * 43758.5453);
//        float rotT = clamp(lerp(MinRotation, MaxRotation, rotRaw), MinRotation, MaxRotation);

//        // random decal-space offset
//        float offXRaw = frac(sin(dot(s0 + float2(3, 3), float2(12.9898, 78.233))) * 43758.5453);
//        float offYRaw = frac(sin(dot(s0 + float2(4, 4), float2(12.9898, 78.233))) * 43758.5453);
//        float2 decalOff = float2(
//            clamp(lerp(MinOffset, MaxOffset, offXRaw), MinOffset, MaxOffset),
//            clamp(lerp(MinOffset, MaxOffset, offYRaw), MinOffset, MaxOffset)
//        );

//        // transform in [0,1] tile-space
//        float2 centered = uv - float2(0.5, 0.5);
//        float2 scaled = centered * sc;
//        float ang = rotT * 6.2831853;
//        float2 rotUV = float2(
//            scaled.x * cos(ang) - scaled.y * sin(ang),
//            scaled.x * sin(ang) + scaled.y * cos(ang)
//        );

//        float2 uvInTile = rotUV + float2(0.5, 0.5) + decalOff;

//        // map & clamp into chosen cell
//        float2 uvT = clamp(
//            uvInTile * tileSize + baseOff,
//            baseOff,
//            baseOff + tileSize
//        );

//        float4 sampleColor = tex2D(tex, uvT);
//        accum.rgb = lerp(accum.rgb, sampleColor.rgb, sampleColor.a);
//        accum.a = saturate(accum.a + sampleColor.a);
//    }

//    return accum;
}