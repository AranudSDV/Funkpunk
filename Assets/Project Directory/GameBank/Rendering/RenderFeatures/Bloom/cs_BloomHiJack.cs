using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable, VolumeComponentMenu("BloomHijack")]
public class cs_BloomHiJack : VolumeComponent, IPostProcessComponent
{
    [Header("Bloom Settings")]
    public FloatParameter threshold = new FloatParameter(0.9f);
    public FloatParameter intensity = new FloatParameter(1f);
    public ClampedFloatParameter scatter = new ClampedFloatParameter(0.7f, 0f, 1f);
    public IntParameter clamp = new IntParameter(65472);
    public ClampedIntParameter maxIterations = new ClampedIntParameter(6, 0, 10);
    public NoInterpColorParameter tint = new NoInterpColorParameter(Color.white);

    [Header("BloomTexture")]
    public IntParameter Density = new IntParameter(10);
    public ClampedFloatParameter Cutoff = new ClampedFloatParameter(0.4f, 0f, 1f);
    public Vector2Parameter scrollDirection = new Vector2Parameter(Vector2.zero);

    public bool IsActive()
    {
        // Active l'effet uniquement si le seuil est inférieur à une valeur définie
        return intensity.value > 0;
    }

    public bool IsTileCompatible()
    {
        return false; // Pas compatible avec les tiles
    }
}