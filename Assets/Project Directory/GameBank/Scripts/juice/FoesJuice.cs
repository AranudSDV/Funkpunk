using DG.Tweening;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FoesJuice : MonoBehaviour
{
    public float startY;
    [SerializeField] private Vector3 originalScale;
    private Quaternion startRot;
    [SerializeField] private float bounceHeight = 0.1f; // How high to bounce
    [SerializeField] private float scaleMultiplier = 1.2f; // Maximum scale during the pulse
    [SerializeField] private BPM_Manager bpmManager;
    private float rotationAngle = 10f; // Tilt angle
    [SerializeField] private SC_FieldOfView scFoe;
    private bool bOnce = false;
    static int Hasard(int a, int b) //Choisi un random.
    {
        System.Random rdm = new System.Random();
        int hasard = rdm.Next(a, b + 1); //Aller jusqu'a le b inclu.
        return hasard;
    }
    private void Awake()
    {
        int hasard = Hasard(-20, 20);
        rotationAngle = Convert.ToSingle(hasard);
        BaitRythm(bpmManager.FSPB);
        startRot = this.transform.rotation;
        originalScale = transform.localScale;
        startY = transform.position.y;
    }
    private void Update()
    {
        if(scFoe.bIsPhaseAnimated && !bOnce)
        {
            DOTween.Kill(this);
            transform.rotation = startRot;
            transform.localScale = originalScale;
            transform.position = new Vector3(transform.position.x, startY, transform.position.z);
            bOnce = true;
        }
        else if(!scFoe.bIsPhaseAnimated && bOnce)
        {
            bOnce = false;

            int hasard = Hasard(-20, 20);
            rotationAngle = Convert.ToSingle(hasard);
            BaitRythm(bpmManager.FSPB);
        }
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
        transform.DOMoveY(startY + bounceHeight, beatDuration / 2) // Move up
            .SetEase(Ease.InOutSine)
            .SetLoops(-1, LoopType.Yoyo) // Loop back down
            .SetAutoKill(false) // Prevent tween from being killed
            .Play();
    }
    private void AnimateScale(float beatDuration)
    {
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
