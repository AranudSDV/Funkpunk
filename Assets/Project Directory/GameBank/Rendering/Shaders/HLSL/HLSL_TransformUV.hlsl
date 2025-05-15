#ifndef TRANSFORM_UV_HLSL
#define TRANSFORM_UV_HLSL

// TransformUV.hlsl
// Transforme des UVs en appliquant : 
//   1) translation relative au pivot (centrage)
//   2) mise à l’échelle
//   3) rotation autour du pivot
//   4) recentrage (add pivot)
//   5) translation finale (offset)
//
// Entrées :
//   uv            : float2, coordonnées UV initiales
//   pivot         : float2, point de pivot (ex. 0.5,0.5 pour le centre)
//   scale         : float2, échelle en X et Y
//   rotationTurns : float, rotation en tours (0→1 correspond à 0→360°)
//   offset        : float2, translation finale en UV
//
// Sortie :
//   float2, UV transformés

float2 TransformUV(
    float2 uv,
    float2 pivot,
    float2 scale,
    float rotationTurns,
    float2 offset
)
{
    // 1) Centrage sur le pivot
    float2 centered = uv - pivot;

    // 2) Mise à l’échelle
    float2 scaled = centered * scale;

    // 3) Rotation
    // Convertit les tours en radians : angle = turns * 2π
    const float PI2 = 6.28318530717958647692; // 2 * π :contentReference[oaicite:0]{index=0}
    float angle = rotationTurns * PI2;
    float s = sin(angle); // sin from HLSL :contentReference[oaicite:1]{index=1}
    float c = cos(angle); // cos from HLSL :contentReference[oaicite:2]{index=2}
    float2 rotated;
    rotated.x = scaled.x * c - scaled.y * s;
    rotated.y = scaled.x * s + scaled.y * c;

    // 4) Recentrage (rappel du pivot)
    float2 recentered = rotated + pivot;

    // 5) Translation finale (offset)
    return recentered + offset;
}

#endif // TRANSFORM_UV_HLSL
