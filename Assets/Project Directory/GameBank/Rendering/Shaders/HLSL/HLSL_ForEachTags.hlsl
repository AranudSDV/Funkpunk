#ifndef HLSL_ForEachTags
#define HLSL_ForEachTags


#include "HLSL_TransformUV.hlsl"



// --- PRNG stateless pour générer des aléas à partir d'une seed 2D ---
float Rand(float2 s)
{
    return frac(sin(dot(s, float2(12.9898, 78.233))) * 43758.5453);
}

// --- Boucle dynamique : génère N graffitis ---
float4 ForEachTags(
    float2 uv,
    float2 seed2D,
    Texture2D Atlas, 
    int NumGraffiti,
    int AtlasCols,
    int AtlasRows,
    float MinScale,
    float MaxScale,
    float MinRotation,
    float MaxRotation,
    float MinOffset,
    float MaxOffset,
    float SeedMultiplier
)
{
    // Applique l'échelle spatiale au seed
    seed2D *= SeedMultiplier;

    float4 accum = float4(0, 0, 0, 0);
    int total = AtlasCols * AtlasRows;

    for (int i = 0; i < NumGraffiti; i++)
    {
        float2 s0 = seed2D + float2(i, -i * 0.618);

        // 1) Sélection du sprite dans l'atlas
        int idx = (int) floor(Rand(s0 * 1.321) * total);
        float col = fmod(idx, AtlasCols);
        float row = floor(idx / AtlasCols);
        float2 baseOffset = float2(col, row) / float2(AtlasCols, AtlasRows);

        // 2) Scale aléatoire
        float scRaw = Rand(s0 + 1.0);
        float sc = clamp(lerp(MinScale, MaxScale, scRaw), MinScale, MaxScale);

        // 3) Rotation aléatoire (tours)
        float rotRaw = Rand(s0 + 2.0);
        float rotT = clamp(lerp(MinRotation, MaxRotation, rotRaw), MinRotation, MaxRotation);

        // 4) Offset local X/Y
        float offXRaw = Rand(s0 + 3.0);
        float offYRaw = Rand(s0 + 4.0);
        float offX = clamp(lerp(MinOffset, MaxOffset, offXRaw), MinOffset, MaxOffset);
        float offY = clamp(lerp(MinOffset, MaxOffset, offYRaw), MinOffset, MaxOffset);
        float2 localOff = float2(offX, offY);

        // 5) TransformUV & sample
        float2 uvT = TransformUV(
            uv,
            float2(0.5, 0.5), // pivot
            float2(sc, sc), // scale uniforme
            rotT, // rotation
            baseOffset + localOff // translation finale
        );
        accum += Atlas.Sample(Atlas_sampler, uvT);
    }

    return accum;
}

#endif // HLSL_ForEachTags
