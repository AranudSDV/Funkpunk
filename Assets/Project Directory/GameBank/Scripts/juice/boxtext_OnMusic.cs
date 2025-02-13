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
    [SerializeField] private BPM_Manager bpmManager;
    private bool bInitialized = false;
    private List<Tween> activeTweens = new List<Tween>();

    private Tween shakeTween;

    private void Init()
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
    private void Update()
    {
        if(!bInitialized)
        {
            Init();
            bInitialized = true;
            int totalPlaying = DOTween.TotalPlayingTweens();
            if (activeTweens.Count > 1)
            {
                KillFirstTween();
            }
        }
    }
    private void KillFirstTween()
    {
        if (activeTweens.Count > 0)
        {
            // Kill the first tween
            activeTweens[0].Kill();

            // Remove it from the list
            activeTweens.RemoveAt(0);
        }
    }

    private void StartContinuousShake()
    {
        // Infinite looping shake
        shakeTween = targetUI.DOShakePosition(bpmManager.FSPB, strength, nbShakesPerCycle, randomness)
            .SetLoops(-1, LoopType.Restart)
            .SetRelative(true) // Makes the shake relative to the current position
            .SetEase(Ease.OutBack); // Optional: Smooth out the loop
        activeTweens.Add(shakeTween);
        Debug.Log(bpmManager.FSPB);
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
        StartContinuousShake();
    }
}
