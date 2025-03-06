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
    [SerializeField] private Vector2 endValueBounce;
    private bool bInitialized = false;
    private List<Tween> activeTweens = new List<Tween>();
    [SerializeField] private float f_bounce = 0f;

    private Tween shakeTween;

    private void Init()
    {
        if (targetUI != null)
        {
            if (f_bounce == 0)
            {
                StartContinuousShake();
            }
            else if(f_bounce == 1)
            {
                StartContinuousBounce();
            }
            else
            {
                StartContinuousAppend();
            }
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

    private void StartContinuousBounce()
    {
        // Infinite looping bounce
        shakeTween = targetUI.DOJumpAnchorPos(endValueBounce, strength, nbShakesPerCycle, bpmManager.FSPB)
            .SetLoops(-1, LoopType.Restart)
            .SetRelative(true) // Makes the shake relative to the current position
            .SetEase(Ease.OutQuad); // Optional: Smooth out the loop
        activeTweens.Add(shakeTween);
    }
    private void StartContinuousAppend()
    {
        Sequence bounceSequence = DOTween.Sequence();
        float targetY = targetUI.anchoredPosition.y;
        float targetX = targetUI.anchoredPosition.x;
        float bounceWidth = strength/2f;  // Déplacement latéral

        shakeTween = bounceSequence.Append(targetUI.DOAnchorPos(new Vector2(targetX + bounceWidth, targetY + strength), bpmManager.FSPB/2f)
            .SetEase(Ease.OutQuad)) // Monte à droite
            .Join(targetUI.DOScale(1.1f, bpmManager.FSPB / 2f)) // S’étire

            .Append(targetUI.DOAnchorPos(new Vector2(targetX - bounceWidth, targetY), bpmManager.FSPB/2f)
            .SetEase(Ease.InQuad)) // Redescend à gauche
            .Join(targetUI.DOScale(1f, bpmManager.FSPB / 2f)) // Reprend sa taille normale

            .Append(targetUI.DOAnchorPos(new Vector2(targetX - bounceWidth, targetY + strength), bpmManager.FSPB/2f)
            .SetEase(Ease.OutQuad)) // Monte à gauche
            .Join(targetUI.DOScale(1.1f, bpmManager.FSPB / 2f)) // S’étire

            .Append(targetUI.DOAnchorPos(new Vector2(targetX + bounceWidth, targetY), bpmManager.FSPB/2f)
            .SetEase(Ease.InQuad)) // Redescend à droite
            .Join(targetUI.DOScale(1f, bpmManager.FSPB / 2f))
            .SetLoops(-1, LoopType.Restart); // Reprend sa taille normale
        activeTweens.Add(shakeTween);
    }

    private void StartContinuousShake()
    {
        // Infinite looping shake
        shakeTween = targetUI.DOShakePosition(bpmManager.FSPB, strength, nbShakesPerCycle, randomness)
            .SetLoops(-1, LoopType.Restart)
            .SetRelative(true) // Makes the shake relative to the current position
            .SetEase(Ease.OutBack); // Optional: Smooth out the loop
        activeTweens.Add(shakeTween);
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
