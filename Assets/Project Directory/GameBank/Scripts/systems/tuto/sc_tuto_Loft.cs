using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class sc_tuto_Loft : MonoBehaviour
{
    [SerializeField] private GameObject GoTuto;
    [SerializeField] private CanvasGroup CgTuto;
    [SerializeField] private RectTransform RtTuto;
    [SerializeField] private SC_Player scPlayer;
    private bool bWaitSpace = false;
    private bool bInitialized;

    private void Init()
    {
        if (scPlayer.menuManager.gameObject.GetComponent<PlayerData>().iLevelPlayer > 0)
        {
            CgTuto.alpha = 0f;
            RtTuto.anchorMin = new Vector2(0, 1);
            RtTuto.anchorMax = new Vector2(1, 2);
            RtTuto.offsetMax = new Vector2(0f, 0f);
            RtTuto.offsetMin = new Vector2(0f, 0f);
            scPlayer.bisTuto = false;
            StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
        }
        else
        {
            StartCoroutine(StartTuto());
        }
    }

    private void Update()
    {
        if(!bInitialized)
        {
            Init();
            bInitialized = true;
        }

        if(scPlayer.bisTuto && bWaitSpace && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
        {
            GoTuto.SetActive(false);
            bWaitSpace = false;
            scPlayer.bisTuto = false;
            StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
        }
    }
    private IEnumerator StartTuto()
    {
        CgTuto.alpha = 1f;
        RtTuto.anchorMin = new Vector2(0.2f, 0.4f);
        RtTuto.anchorMax = new Vector2(0.8f, 0.73f);
        RtTuto.offsetMax = new Vector2(0f, 0f);
        RtTuto.offsetMin = new Vector2(0f, 0f);
        yield return new WaitForSecondsRealtime(0.5f);
        bWaitSpace = true;
    }
    private IEnumerator ImuneToTuto(BPM_Manager bpmmanager)
    {
        scPlayer.bIsImune = true;
        yield return new WaitForSecondsRealtime(bpmmanager.FSPB * 2);
        scPlayer.bIsImune = false;
    }
}
