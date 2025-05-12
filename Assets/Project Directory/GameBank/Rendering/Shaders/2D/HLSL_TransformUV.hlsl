// TransformUV.hlsl
// Fonction HLSL pour Unity/Amplify Shader Editor
// Combine translation, scaling, rotation et offset UV

#ifndef TRANSFORMUV_HLSL
#define TRANSFORMUV_HLSL

// Convertit des UV selon un pivot, une échelle, une rotation et un offset
// uv       : coordonnée UV d'entrée
// pivot    : point de pivot en UV (par ex. float2(0.5,0.5))
// scale    : facteur de mise à l'échelle (U, V)
// rotation : angle en tours (0→1 correspond à 0→360°)
// offset   : translation finale en UV

float2 TransformUV(float2 uv,
                   float2 pivot,
                   float2 scale,
                   float  rotation,
                   float2 offset)
{
    // 1) Conversion de la rotation (tours) en radians (2π par tour)
    float rad = rotation * 6.283185307179586;

    // 2) Calcul de sin et cos
    float s = sin(rad);
    float c = cos(rad);

    // 3) Centrage sur le pivot et application de l'échelle
    float2 centered = (uv - pivot) * scale;

    // 4) Application de la matrice de rotation 2D
    float2 rotated;
    rotated.x = centered.x * c - centered.y * s;
    rotated.y = centered.x * s + centered.y * c;

    // 5) Recentrement et translation finale
    return rotated + pivot + offset;
}

#endif // TRANSFORMUV_HLSL
