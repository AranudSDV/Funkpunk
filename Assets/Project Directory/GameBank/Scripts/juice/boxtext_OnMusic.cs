using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI; 
using DG.Tweening;

public class boxtext_OnMusic : MonoBehaviour
{
    [SerializeField]private RectTransform targetUI; // The UI element to shake

    [SerializeField] private float strength = 10f;   // Shake strength
    [SerializeField]private int nbShakesPerCycle = 10;  // Number of shakes per cycle
    [SerializeField]private float randomness = 90f; // Randomness in shake direction
    [SerializeField]private float interval = 0.1f;  // Delay between shake cycles

    private Tween shakeTween;

    private void Start()
    {
        if (targetUI != null)
        {
            StartContinuousShake();
        }
        else
        {
            Debug.LogWarning("Target UI is not assigned.");
        }
    }

    private void StartContinuousShake()
    {
        // Infinite looping shake
        shakeTween = targetUI.DOShakePosition(interval, strength, nbShakesPerCycle, randomness)
            .SetLoops(-1, LoopType.Restart)
            .SetRelative(true) // Makes the shake relative to the current position
            .OnStart(() => Debug.Log("Shake started"))
            .OnComplete(() => Debug.Log("Shake completed"))
            .SetEase(Ease.Linear); // Optional: Smooth out the loop
    }

    private void OnDisable()
    {
        // Stop the shake when the object is disabled to avoid memory leaks
        if (shakeTween != null && shakeTween.IsActive())
        {
            shakeTween.Kill();
            shakeTween = null;
        }
    }

    private void OnEnable()
    {
        if (shakeTween != null && shakeTween.IsActive())
        {
            shakeTween.Kill();
        }
        Debug.Log("new shake tween");
        StartContinuousShake();
    }
}
