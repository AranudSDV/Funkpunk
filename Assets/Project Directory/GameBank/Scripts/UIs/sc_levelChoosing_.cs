using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.SceneManagement;
using System.Security.Cryptography;

public class sc_levelChoosing_ : MonoBehaviour
{
    [SerializeField][Tooltip("5 for each level since there are 5 stars")] private UnityEngine.RectTransform[] rectStarsLevels = new UnityEngine.RectTransform[20];
    private PlayerData _playerData;
    public int iPreviousLvl = 0;
    private bool[] bAnimStars = new bool[5] { false, false, false, false, false };
    private bool bBegin = false;

    private float jumpHeight = 50f;       // how high the image jumps
    private float jumpDuration = 0.15f;     // time to go up
    private float pauseTime = 0.1f;        // how long it stays up
    private float swingAngle = 20f;        // max rotation on Z
    private float swingDuration = 0.15f;    // duration for one swing (left to right or right to left)
    private int swingCount = 4;            // total swings (back and forth)
    private float dropDistance = 20f;      // how much it drops below original
    private float dropDuration = 0.2f;
    private Vector3[] originalPosition = new Vector3[20];
    [SerializeField] private Vector2[] ArrowAnchoredMin;
    [SerializeField] private Vector2[] ArrowAnchoredMax;
    [SerializeField] private RectTransform rectArrow;
    private void OnEnable()
    {
        SceneManager.sceneLoaded += OnSceneLoaded;
    }
    private void OnDisable()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        GameObject goMenu = GameObject.FindWithTag("Manager");
        _playerData = goMenu.GetComponent<PlayerData>();
        StartCoroutine(WaitAndAnimate());
    }
    private IEnumerator WaitAndAnimate()
    {
        yield return new WaitForSecondsRealtime(0.5f);
        CheckPreviousLvl();
    }
    private void CheckPreviousLvl()
    {
        for (int i = 0; i < 20; i++)
        {
            originalPosition[i] = rectStarsLevels[i].anchoredPosition;
        }
        if (_playerData.iLevelPlayer != 0)
        {
            iPreviousLvl = _playerData.iLevelPlayer - 1;
            bBegin = true;
            bAnimStars[0] = true;
            AnimateArrow(iPreviousLvl, _playerData.iLevelPlayer, 3f);
        }
        else
        {
            iPreviousLvl = 0;
            bBegin = true;
            bAnimStars[0] = true;
            AnimateArrow(iPreviousLvl, _playerData.iLevelPlayer, 3f);
        }
    }
    private void AnimateArrow(int iPrevious, int next, float duration)
    {
        DOTween.To(() => 0f, x => {
            rectArrow.anchorMin = Vector2.Lerp(ArrowAnchoredMin[iPrevious], ArrowAnchoredMin[next], x);
            rectArrow.anchorMax = Vector2.Lerp(ArrowAnchoredMax[iPrevious], ArrowAnchoredMax[next], x);
            // Reset offsets to maintain size and layout
            rectArrow.offsetMin = Vector2.Lerp(rectArrow.offsetMin, Vector2.zero, x);
            rectArrow.offsetMax = Vector2.Lerp(rectArrow.offsetMax, Vector2.zero, x);
        }, 1f, duration).SetEase(Ease.InOutQuad).SetUpdate(true);
    }
    private void Update()
    {
        if (bBegin)
        {
            for (int i = 0; i < 5; i++)
            {
                if (bAnimStars[i] == true)
                {
                    Animate(rectStarsLevels[i + (5 * iPreviousLvl)], originalPosition[i + (5 * iPreviousLvl)], i, _playerData.iStarsPlayer[i + (5 * iPreviousLvl)]);
                }
            }
        }
    }
    public void Animate(UnityEngine.RectTransform rectTransform, Vector3 originalPosition_, int i, int i_true)
    {
        bAnimStars[i] = false;
        Sequence starSequence = DOTween.Sequence().SetUpdate(true); // Ensures it runs independently of timeScale

        if (i_true == 1)
        {
            starSequence.Append(
                rectTransform.DOAnchorPosY(originalPosition_.y + jumpHeight, jumpDuration)
                    .SetEase(Ease.OutQuad)
                    .SetUpdate(true)
            );

            starSequence.AppendInterval(pauseTime);

            starSequence.Append(
                rectTransform.DORotate(new Vector3(0, 0, swingAngle), swingDuration)
                    .SetEase(Ease.InOutSine)
                    .SetLoops(swingCount, LoopType.Yoyo)
                    .SetUpdate(true)
            );

            starSequence.Append(
                rectTransform.DOAnchorPosY(originalPosition_.y - dropDistance, dropDuration)
                    .SetEase(Ease.InQuad)
                    .SetUpdate(true)
            );

            starSequence.Append(
                rectTransform.DOAnchorPosY(originalPosition_.y, 0.1f)
                    .SetEase(Ease.OutQuad)
                    .SetUpdate(true)
            );
        }
        else
        {
            starSequence.Append(
                rectTransform.DORotate(new Vector3(0, 0, swingAngle), swingDuration)
                    .SetEase(Ease.InOutSine)
                    .SetLoops(Mathf.Max(1, swingCount), LoopType.Yoyo)
                    .SetUpdate(true)
            );
        }
        starSequence.OnComplete(() =>
        {
            if (i + 1 < 5)
            {
                bAnimStars[i + 1] = true;
            }
            else
            {
                bBegin = false;
            }
        });
    }
    private void OnDestroy() // Clean up to prevent memory leaks
    {
        DOTween.KillAll();
    }
}
