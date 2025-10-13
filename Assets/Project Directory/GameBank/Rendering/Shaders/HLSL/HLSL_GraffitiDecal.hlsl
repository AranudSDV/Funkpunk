// Hash discret pour Random01
uint Hash2D(uint x, uint y)
{
    uint h = x * 374761393u + y * 668265263u;
    h = (h ^ (h >> 13)) * 1274126177u;
    return h;
}

// Retourne float4 stable à partir d'un uint2
float4 Random4(uint x, uint y)
{
    uint h1 = Hash2D(x, y);
    uint h2 = Hash2D(x + 1u, y + 1u);
    uint h3 = Hash2D(x + 2u, y + 2u);
    uint h4 = Hash2D(x + 3u, y + 3u);
    return float4(
        frac(h1 / 4294967296.0),
        frac(h2 / 4294967296.0),
        frac(h3 / 4294967296.0),
        frac(h4 / 4294967296.0)
    );
}

float4 SampleGraffitis(
    float2 uv,
    float2 seed2D,
    sampler2D tex,
    float NumGraffiti,
    
    float2 AtlasSize,
    
    float2 ScaleRange,
    float2 StretchRange,
    
    
    float2 RotationRange,
    
    float2 OffsetXRange,
    float2 OffsetYRange
)
{
    float4 accum = float4(0, 0, 0, 0);
    int total = int(AtlasSize.y * AtlasSize.x);
    float2 tileSize = float2(1.0 / AtlasSize.x, 1.0 / AtlasSize.y);

    uint2 seedInt = uint2(floor(seed2D * 10000.0));

    // centre global du decal (dans l'espace UV du decal)
    float2 decalCenter = float2(0.5, 0.5);

    for (int i = 0; i < int(NumGraffiti); i++)
    {
        uint2 s0Int = seedInt + uint2(i, i * 37);

        // Gen Random floats
        float4 rnds = Random4(s0Int.x, s0Int.y); // ID & Scale
        float4 rnds2 = Random4(s0Int.x + 10u, s0Int.y + 10u); // Rota & Offset
       

        // index sprite
        int idx = int(floor(rnds.x * total));
        float2 cell = float2(floor(idx / AtlasSize.y), fmod(idx, AtlasSize.y));
        float2 baseOff = cell * tileSize;

        // Scale
        float scUniform = lerp(ScaleRange.x, ScaleRange.y, rnds.y);
        
        float stretchX = 1.0 + lerp(StretchRange.x, StretchRange.y, rnds.z);
        float stretchY = 1.0 + lerp(StretchRange.x, StretchRange.y, rnds.w);
        
        float2 scale = scUniform * float2(stretchX, stretchY);
        
        //float scX = clamp(lerp(ScaleRangeX.x, ScaleRangeX.y, rnds.y), ScaleRangeX.x, ScaleRangeX.y);
        //float scY = clamp(lerp(ScaleRangeY.x, ScaleRangeY.y, rnds.z), ScaleRangeY.x, ScaleRangeY.y);

       // Rotation
        
        float rotT = clamp(lerp(RotationRange.x, RotationRange.y, rnds2.x), RotationRange.x, RotationRange.y);

        float angle = radians(rotT);
        
        // Offset global (seed distinct pour stabilité)
        
        float offX = clamp(lerp(OffsetXRange.x, OffsetXRange.y, rnds2.y), OffsetXRange.x, OffsetXRange.y);
        float offY = clamp(lerp(OffsetYRange.x, OffsetYRange.y, rnds2.z), OffsetYRange.x, OffsetYRange.y);
        float2 decalOff = float2(offX, offY); // en espace UV global du decal (0..1)

        // --------------------
        // MAPPING INVERSE (centrer le tag au centre avant l'offset, puis offset)
        // --------------------
        
        float2 cellCenter = baseOff + tileSize * 0.5;

        // On veut placer le centre du sprite sur (decalCenter + decalOff) en espace decal.
        // Pour cela on calcule l'inverse des transforms :
        // local = inverseRotate( inverseScale( (uv - (decalCenter + decalOff)) / tileSize ) )
        // puis uvSample = local * tileSize + cellCenter

        // UV relatif au centre final (decal center + offset)
        float2 uvRel = uv - (decalCenter + decalOff);

        // passer en "unités de cellule" (1.0 = largeur/hauteur d'une cellule)
        float2 localCell = uvRel / tileSize;

        // inverse rotation : rotate by -angle
        float sinA = sin(-angle);
        float cosA = cos(-angle);
        float2 rotatedInv = float2(
            localCell.x * cosA - localCell.y * sinA,
            localCell.x * sinA + localCell.y * cosA
        );

        // inverse scale
        rotatedInv /= float2(scale);

        // remapper dans l'atlas autour du centre de la cellule
        float2 uvSample = rotatedInv * tileSize + cellCenter;

        // clamp pour éviter le bleeding hors cellule (optionnel mais utile)
        float2 uvT = clamp(uvSample, baseOff, baseOff + tileSize);

        // Sample texture
        float4 sampleC = tex2D(tex, uvT);

        // Accumulation
        accum.rgb = lerp(accum.rgb, sampleC.rgb, sampleC.a);
        accum.a = saturate(accum.a + sampleC.a);
    }

    return accum;
}
