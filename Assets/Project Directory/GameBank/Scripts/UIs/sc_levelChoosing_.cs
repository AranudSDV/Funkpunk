using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.SceneManagement;
using System.Security.Cryptography;
using static System.Net.Mime.MediaTypeNames;
using UnityEngine.EventSystems;
using UnityEngine.UIElements;

public class sc_levelChoosing_ : MonoBehaviour
{
    [SerializeField] private EventSystem _eventSystem;
    [SerializeField] private Camera camUIOverlay;
    [SerializeField][Tooltip("5 for each level since there are 5 stars")] private UnityEngine.RectTransform[] rectStarsLevels = new UnityEngine.RectTransform[20];
    private MenuManager menuManager;
    private PlayerData _playerData;
    private int iLastLvl = 0;
    public int iPreviousLvlDone = 0;
    private bool[] bAnimStars = new bool[5] { false, false, false, false, false };
    private bool bBegin = false;
    [SerializeField] private GameObject[] GoLevels;
    [SerializeField] private UnityEngine.UI.Image imBackground;
    [SerializeField] private UnityEngine.UI.Image imTel;
    [SerializeField] private Material[] sprites_Background;
    [SerializeField] private Material[] sprites_Tel;
    private bool[] bNowSelected = new bool[5] { false,false,false,false, false};
    private int iSelected = 0;

    private float jumpHeight = 50f;       // how high the image jumps
    private float jumpDuration = 0.15f;     // time to go up
    private float pauseTime = 0.1f;        // how long it stays up
    private float swingAngle = 20f;        // max rotation on Z
    private float swingDuration = 0.15f;    // duration for one swing (left to right or right to left)
    private int swingCount = 4;            // total swings (back and forth)
    private float dropDistance = 20f;      // how much it drops below original
    private float dropDuration = 0.2f;
    private Vector3[] originalPosition = new Vector3[20];
    [SerializeField] private Vector2[] CharaAnchoredMin;
    [SerializeField] private Vector2[] CharaAnchoredMax;
    [SerializeField] private RectTransform rectChara;
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
        menuManager = goMenu.GetComponent<MenuManager>();
        _playerData = goMenu.GetComponent<PlayerData>();
        imBackground.material = sprites_Background[_playerData.iLevelPlayer];
        menuManager.gameObject.GetComponent<Canvas>().worldCamera = camUIOverlay;
        menuManager.EventSystem = _eventSystem;
        StartCoroutine(WaitAndAnimate());
    }
    private IEnumerator WaitAndAnimate()
    {
        yield return new WaitForSecondsRealtime(0.5f);
        CheckPreviousLvl();
    }
    private void Update()
    {
        if (bBegin)
        {
            for (int i = 0; i < 5; i++)
            {
                if (bAnimStars[i] == true)
                {
                    AnimateStars(rectStarsLevels[i + (5 * iPreviousLvlDone)], originalPosition[i + (5 * iPreviousLvlDone)], i, _playerData.iStarsPlayer[i + (5 * iPreviousLvlDone)]);
                }
            }
        }
        if (menuManager != null)
        {
            for (int i = 0; i < 5; i++)
            {
                if (menuManager.EventSystem.currentSelectedGameObject == GoLevels[i] && !bNowSelected[i])
                {
                    bNowSelected[iSelected] = false;
                    AnimateChara(iSelected, i, 0.8f);
                    bNowSelected[i] = true;
                    imTel.material = sprites_Tel[i];
                }
                else if(menuManager.EventSystem.currentSelectedGameObject != GoLevels[i] && bNowSelected[i])
                {
                    bNowSelected[i] = false;
                }
            }
        }
    }
    private void CheckPreviousLvl()
    {
        for (int i = 0; i < 20; i++)
        {
            originalPosition[i] = rectStarsLevels[i].anchoredPosition;
        }
        if (_playerData.iLevelPlayer != 0)
        {
            if(menuManager!=null)
            {
                iPreviousLvlDone = menuManager.iPreviousLevelPlayed;
            }
            if(iPreviousLvlDone == _playerData.iLevelPlayer - 1)
            {
                iLastLvl = _playerData.iLevelPlayer - 1;
            }
            else
            {
                iLastLvl = _playerData.iLevelPlayer;
            }
            bBegin = true;
            bAnimStars[0] = true;
            rectChara.anchorMin = CharaAnchoredMin[iPreviousLvlDone];
            rectChara.anchorMax = CharaAnchoredMax[iPreviousLvlDone];
            rectChara.offsetMin = new Vector2(0f, 0f);
            rectChara.offsetMax = new Vector2(0f,0f);
            menuManager.EventSystem.firstSelectedGameObject = GoLevels[iPreviousLvlDone];
            bNowSelected[iPreviousLvlDone] = true;
            iSelected = iPreviousLvlDone;
            AnimateCharaNext(iLastLvl, _playerData.iLevelPlayer, 0.8f);
        }
        else
        {
            iPreviousLvlDone = 0;
            iLastLvl = 0;
            bBegin = true;
            bAnimStars[0] = true;
            rectChara.anchorMin = CharaAnchoredMin[iPreviousLvlDone];
            rectChara.anchorMax = CharaAnchoredMax[iPreviousLvlDone];
            rectChara.offsetMin = new Vector2(0f, 0f);
            rectChara.offsetMax = new Vector2(0f, 0f);
            menuManager.EventSystem.firstSelectedGameObject = GoLevels[0];
            bNowSelected[0] = true;
            iSelected = 0;
            AnimateCharaNext(iLastLvl, _playerData.iLevelPlayer, 0.8f);
        }
    }
    private void AnimateCharaNext(int iPrevious, int next, float duration)
    {
        Sequence charaSequence = DOTween.Sequence().SetUpdate(true); // Ensures it runs independently of timeScale
        charaSequence.Append(
            DOTween.To(() => 0f, x => {
            rectChara.anchorMin = Vector2.Lerp(CharaAnchoredMin[iPrevious], CharaAnchoredMin[next], x);
            rectChara.anchorMax = Vector2.Lerp(CharaAnchoredMax[iPrevious], CharaAnchoredMax[next], x);
            // Reset offsets to maintain size and layout
            // Y bounce
            float bounceOffset = Mathf.Sin(x * Mathf.PI) * 50f; 
            rectChara.offsetMin = new Vector2(0, bounceOffset);
            rectChara.offsetMax = new Vector2(0, bounceOffset);
        }, 1f, duration).SetEase(Ease.InOutBack)
        );
        charaSequence.OnComplete(() =>
        {
            rectChara.offsetMin = Vector2.zero;
            rectChara.offsetMax = Vector2.zero;
        });
        iSelected = next;
        menuManager.EventSystem.SetSelectedGameObject(GoLevels[iSelected]);
    }
    private void AnimateChara(int iPrevious, int next, float duration)
    {
        Sequence charaSequence = DOTween.Sequence().SetUpdate(true); // Ensures it runs independently of timeScale
        charaSequence.Append(
            DOTween.To(() => 0f, x => {
            rectChara.anchorMin = Vector2.Lerp(CharaAnchoredMin[iPrevious], CharaAnchoredMin[next], x);
            rectChara.anchorMax = Vector2.Lerp(CharaAnchoredMax[iPrevious], CharaAnchoredMax[next], x);
            // Reset offsets to maintain size and layout
            if(iPrevious!= next)
            {
                // Y bounce
                float bounceOffset = Mathf.Sin(x * Mathf.PI) * -80f;
                rectChara.offsetMin = new Vector2(0, bounceOffset);
                rectChara.offsetMax = new Vector2(0, bounceOffset);
                }
            else
            {
                rectChara.offsetMin = Vector2.Lerp(rectChara.offsetMin, Vector2.zero, x);
                rectChara.offsetMax = Vector2.Lerp(rectChara.offsetMax, Vector2.zero, x);
            }
        }, 1f, duration).SetEase(Ease.InOutBack).SetUpdate(true)
        );
        charaSequence.OnComplete(() =>
        {
            rectChara.offsetMin = Vector2.zero;
            rectChara.offsetMax = Vector2.zero;
        });
        iSelected = next;
    }
    public void AnimateStars(UnityEngine.RectTransform rectTransform, Vector3 originalPosition_, int i, int i_true)
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
