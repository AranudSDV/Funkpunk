using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class sc_tuto_Loft : MonoBehaviour
{
    [SerializeField] private GameObject GoTuto;
    [SerializeField] private SC_Player scPlayer;
    private bool bWaitSpace = false;
    private bool bInitialized;

    private void Init()
    {
        if (scPlayer.menuManager.gameObject.GetComponent<PlayerData>().iLevelPlayer > 0)
        {
            GoTuto.SetActive(false);
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

        if(bWaitSpace = true && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
        {
            GoTuto.SetActive(false);
            bWaitSpace = false;
            scPlayer.bisTuto = false;
            StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
        }
    }
    private IEnumerator StartTuto()
    {
        GoTuto.SetActive(true);
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
