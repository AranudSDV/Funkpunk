using DG.Tweening;
using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class bait_juicy : MonoBehaviour
{
    [SerializeField] private float bounceHeight = 0.5f; // How high to bounce
    [SerializeField] private float scaleMultiplier = 0.9f; // Maximum scale during the pulse
    private float rotationAngle = 10f; // Tilt angle
    static int Hasard(int a, int b) //Choisi un random.
    {
        System.Random rdm = new System.Random();
        int hasard = rdm.Next(a, b + 1); //Aller jusqu'a le b inclu.
        return hasard;
    }
    private void Awake()
    {
        int hasard = Hasard(-90, 90);
        rotationAngle = Convert.ToSingle(hasard);
        BPM_Manager bpmManager = this.transform.parent.GetComponent<ing_Bait>().bpmManager;
        BaitRythm(bpmManager.FSPB);
    }
    private void BaitRythm(float f_beat)
    {
        // Combine effects
        AnimateBounce(f_beat);
        AnimateScale(f_beat);
        AnimateRotation(f_beat);
    }

    private void AnimateBounce(float beatDuration)
    {
        float startY = transform.position.y;
        transform.DOMoveY(startY + bounceHeight, beatDuration / 2) // Move up
            .SetEase(Ease.InOutSine)
            .SetLoops(-1, LoopType.Yoyo) // Loop back down
            .SetAutoKill(false) // Prevent tween from being killed
            .Play();
    }
    private void AnimateScale(float beatDuration)
    {
        Vector3 originalScale = transform.localScale;
        transform.DOScale(originalScale * scaleMultiplier, beatDuration / 2)
            .SetEase(Ease.InOutSine)
            .SetLoops(-1, LoopType.Yoyo)// Scale up and back down
            .Play();
    }
    private void AnimateRotation(float beatDuration)
    {
        transform.DORotate(new Vector3(rotationAngle, rotationAngle, 0), beatDuration, RotateMode.LocalAxisAdd)
            .SetEase(Ease.InOutSine)
            .SetLoops(-1, LoopType.Yoyo) // Slight tilt on X and Z
            .Play();
    }
    private void OnDestroy()
    {
        // Clean up tweens when the object is destroyed
        DOTween.Kill(this);
    }
}
