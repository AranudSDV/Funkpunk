using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class sc_tuto_Loft : MonoBehaviour
{
    [SerializeField] private RectTransform RtTuto;
    [SerializeField] private RectTransform RtStars;
    [SerializeField] private UnityEngine.UI.Image[] imgStars;
    [SerializeField] private Color32 colorStars;
    [SerializeField] private RectTransform RtBg;
    [SerializeField] private RectTransform RtScore;
    [SerializeField] private SC_Player scPlayer;
    private bool bWaitSpace = false;
    private bool bInitialized;
    private bool bImune = false;
    private float fTimer = 0f;

    private void Init()
    {
        if (scPlayer.menuManager.gameObject.GetComponent<PlayerData>().iLevelPlayer > 0)
        {
            RtTuto.anchorMin = new Vector2(0, 1);
            RtTuto.anchorMax = new Vector2(1, 2);
            RtTuto.offsetMax = new Vector2(0f, 0f);
            RtTuto.offsetMin = new Vector2(0f, 0f);

            RtStars.anchorMin = new Vector2(0f, 1f);
            RtStars.anchorMax = new Vector2(1f, 2f);
            RtStars.offsetMax = new Vector2(0f, 0f);
            RtStars.offsetMin = new Vector2(0f, 0f);

            RtBg.anchorMin = new Vector2(0f, 1f);
            RtBg.anchorMax = new Vector2(1f, 2f);
            RtBg.offsetMax = new Vector2(0f, 0f);
            RtBg.offsetMin = new Vector2(0f, 0f);

            RtScore.anchorMin = new Vector2(0.455f, 0.11f);
            RtScore.anchorMax = new Vector2(0.53f, 0.18f);
            RtScore.offsetMax = new Vector2(0f, 0f);
            RtScore.offsetMin = new Vector2(0f, 0f);
            scPlayer.bisTuto = false;
            bImune = true;
            scPlayer.bIsImune = true;
        }
        else
        {
            StartTuto();
            bWaitSpace = true;
        }
    }

    private void Update()
    {
        ImuneToTuto(scPlayer.bpmManager, Time.unscaledDeltaTime);
        if(!bInitialized)
        {
            Init();
            bInitialized = true;
        }

        if(scPlayer.bisTuto && bWaitSpace && (scPlayer.bpmManager.BGood || scPlayer.bpmManager.BPerfect) &&((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
        {
            if (imgStars[0].color != colorStars)
            {
                imgStars[0].color = colorStars;
            }
            else if(imgStars[1].color != colorStars)
            {
                imgStars[1].color = colorStars;
            }
            else if(imgStars[2].color != colorStars)
            {
                imgStars[2].color = colorStars;
            }
            else if (imgStars[3].color != colorStars)
            {
                imgStars[3].color = colorStars;
            }
            else
            {
                RtTuto.anchorMin = new Vector2(0f, 1f);
                RtTuto.anchorMax = new Vector2(1f, 2f);
                RtTuto.offsetMax = new Vector2(0f, 0f);
                RtTuto.offsetMin = new Vector2(0f, 0f);

                RtStars.anchorMin = new Vector2(0f, 1f);
                RtStars.anchorMax = new Vector2(1f, 2f);
                RtStars.offsetMax = new Vector2(0f, 0f);
                RtStars.offsetMin = new Vector2(0f, 0f);

                RtBg.anchorMin = new Vector2(0f, 1f);
                RtBg.anchorMax = new Vector2(1f, 2f);
                RtBg.offsetMax = new Vector2(0f, 0f);
                RtBg.offsetMin = new Vector2(0f, 0f);

                RtScore.anchorMin = new Vector2(0.455f, 0.11f);
                RtScore.anchorMax = new Vector2(0.53f, 0.18f);
                RtScore.offsetMax = new Vector2(0f, 0f);
                RtScore.offsetMin = new Vector2(0f, 0f);

                bWaitSpace = false;
                scPlayer.bisTuto = false;
                bImune = true;
                scPlayer.bIsImune = true;
            }
        }
    }
    private void StartTuto()
    {
        RtTuto.anchorMin = new Vector2(0.2f, 0.4f);
        RtTuto.anchorMax = new Vector2(0.8f, 0.73f);
        RtTuto.offsetMax = new Vector2(0f, 0f);
        RtTuto.offsetMin = new Vector2(0f, 0f);

        RtStars.anchorMin = new Vector2(0.2f, 0.6f);
        RtStars.anchorMax = new Vector2(0.8f, 0.9f);
        RtStars.offsetMax = new Vector2(0f, 0f);
        RtStars.offsetMin = new Vector2(0f, 0f);

        RtBg.anchorMin = new Vector2(0f, 0f);
        RtBg.anchorMax = new Vector2(1f, 1f);
        RtBg.offsetMax = new Vector2(0f, 0f);
        RtBg.offsetMin = new Vector2(0f, 0f);

        RtScore.anchorMin = new Vector2(0, 1);
        RtScore.anchorMax = new Vector2(1, 2);
        RtScore.offsetMax = new Vector2(0f, 0f);
        RtScore.offsetMin = new Vector2(0f, 0f);

        bImune = false;
        bWaitSpace = true;
    }
    private void ImuneToTuto(BPM_Manager bpmmanager, float timer)
    {
        if (bImune)
        {
            fTimer += timer;
            if (fTimer >= bpmmanager.FSPB*3)
            {
                scPlayer.bIsImune = false;
                bImune = false;
                fTimer = 0f;
            }
        }
    }
}
