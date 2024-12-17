using DG.Tweening;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FoesJuice : MonoBehaviour
{
    [SerializeField] private float bounceHeight = 0.1f; // How high to bounce
    [SerializeField] private float scaleMultiplier = 1.2f; // Maximum scale during the pulse
    private float rotationAngle = 10f; // Tilt angle
    static int Hasard(int a, int b) //Choisi un random.
    {
        System.Random rdm = new System.Random();
        int hasard = rdm.Next(a, b + 1); //Aller jusqu'a le b inclu.
        return hasard;
    }
    private void Awake()
    {
        scaleMultiplier = 1f + (0.15f / 0.85f);
        int hasard = Hasard(-20, 20);
        rotationAngle = Convert.ToSingle(hasard);
        SC_Player scPlayer = this.transform.parent.GetComponent<SC_FieldOfView>().GOPlayerRef.GetComponent<SC_Player>();
        BaitRythm(scPlayer.FSPB);
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
        transform.DOLocalRotate(new Vector3(0, 0, rotationAngle), beatDuration, RotateMode.WorldAxisAdd)
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
