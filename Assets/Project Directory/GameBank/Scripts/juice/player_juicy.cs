using DG.Tweening;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class player_juicy : MonoBehaviour
{
    [SerializeField] private float bounceHeight = 0.1f; // How high to bounce
    [SerializeField] private float scaleMultiplier = 1.1f; // Maximum scale during the pulse
    [SerializeField] private BPM_Manager bpmManager;
    static int Hasard(int a, int b) //Choisi un random.
    {
        System.Random rdm = new System.Random();
        int hasard = rdm.Next(a, b + 1); //Aller jusqu'a le b inclu.
        return hasard;
    }
    private void Awake()
    {
        BPM_Manager bpmManager = this.transform.parent.GetComponent<BPM_Manager>();
        BaitRythm(bpmManager.FSPB);
    }
    private void BaitRythm(float f_beat)
    {
        // Combine effects
        AnimateBounce(f_beat);
        AnimateScale(f_beat);
    }

    private void AnimateBounce(float beatDuration)
    {
        float startY = transform.position.y;
        transform.DOMoveY(startY + bounceHeight, beatDuration) // Move up
            .SetEase(Ease.InOutSine)
            .SetLoops(-1, LoopType.Yoyo) // Loop back down
            .SetAutoKill(false) // Prevent tween from being killed
            .Play();
    }
    private void AnimateScale(float beatDuration)
    {
        Vector3 originalScale = transform.localScale;
        transform.DOScale(originalScale * scaleMultiplier, beatDuration)
            .SetEase(Ease.InOutSine)
            .SetLoops(-1, LoopType.Yoyo)// Scale up and back down
            .Play();
    }
    private void OnDestroy()
    {
        // Clean up tweens when the object is destroyed
        DOTween.Kill(this);
    }
}