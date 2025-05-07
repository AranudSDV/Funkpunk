using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class sc_anim_fakePlayer : MonoBehaviour
{
    private float beatDuration = 0.5f;
    [SerializeField] private BPM_Manager bpmManager;
    [SerializeField] private Material objectMaterial;
    [SerializeField] private Color pulseColor = Color.red;
    [SerializeField] private Color originalColor;
    private void Start()
    {
        beatDuration = bpmManager.FSPB;
        AnimateMaterialPulse();
    }
    private void AnimateMaterialPulse()
    {
        objectMaterial.SetColor("_BaseColor", originalColor);
        objectMaterial.DOColor(pulseColor, "_BaseColor", beatDuration / 2)
            .SetEase(Ease.InOutSine)
            .SetLoops(-1, LoopType.Yoyo);
    }
    private void OnDestroy() // Clean up to prevent memory leaks
    {
        DOTween.KillAll();
    }
}
