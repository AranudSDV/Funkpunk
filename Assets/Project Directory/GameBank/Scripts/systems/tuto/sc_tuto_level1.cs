using Cinemachine;
using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.UIElements;
using static Cinemachine.CinemachinePathBase;

public class sc_tuto_level1 : MonoBehaviour
{
    [SerializeField] private GameObject[] GoTuto1 = new GameObject[5];
    [SerializeField] private GameObject[] GoTuto2 = new GameObject[3];
    [SerializeField] private GameObject[] GoTuto3 = new GameObject[2];
    [SerializeField] private GameObject[] goCameraBackTrack = new GameObject[3]; //cam, dolly, empty
    [SerializeField] private GameObject[] goCameraMain = new GameObject[3]; //cam, dolly, ui
    //[SerializeField] private GameObject goWallGoal; //cam, dolly, ui
    //[SerializeField] private GameObject target;
    [SerializeField] private CinemachinePathBase m_Path;
   //[SerializeField] private Cinemachine.CinemachineVirtualCamera c_VirtualCamera;
    [SerializeField] private float m_Speed = 10f;
    private float m_Position;
    [SerializeField] private CinemachinePathBase.PositionUnits m_PositionUnits = CinemachinePathBase.PositionUnits.Distance;
    private bool b_tutoFinished = false;
    //private bool bWallToSee = false;
    [SerializeField] private Sprite[] spriteBubbleTuto1 = new Sprite[4];
    [SerializeField] private Sprite[] spriteBubbleTuto2 = new Sprite[2];
    [SerializeField] private Sprite spriteBubbleTuto3;
    [SerializeField] private SC_Player scPlayer;
    private Coroutine[] tutoCoroutine = new Coroutine[4];
    private bool coroutineIsRunning = false;
    private bool bWaitSpace = false;
    private bool bOnce = false;
    private bool bInitialized = false;
    private bool[] bTuto = new bool[6];
    private void Init()
    {
        scPlayer.bGameIsPaused = true;
        scPlayer.PauseGame();
        for(int i = 0; i<6; i++)
        {
            bTuto[i] = false;
        }
        tutoCoroutine[0] = StartCoroutine(StartFirst());
    }
    private void Update()
    {
        if(!bInitialized)
        {
            Init();
            bInitialized = true;
        }
        if (bWaitSpace)
        {
            if (!b_tutoFinished && bTuto[0] && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                StartCoroutine(SkipFirstTuto());
            }
            if (!b_tutoFinished && bTuto[1] && !bTuto[0] && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                GoTuto1[0].transform.parent.gameObject.SetActive(false);
                tutoCoroutine[1] = StartCoroutine(StartSecond());
            }
            if (!b_tutoFinished && bTuto[2] && !bTuto[1] && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                StartCoroutine(SkipTutoSecond());
            }
            if(!b_tutoFinished && bTuto[3] && !bTuto[2] && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                StartMidSecond();
            }
            if (b_tutoFinished && bTuto[4] && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                StartCoroutine(SkipThirdTuto());
                bWaitSpace = false;
            }
            if (b_tutoFinished && bTuto[5] && !bTuto[4] && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                GoTuto3[0].transform.parent.gameObject.SetActive(false);
                tutoCoroutine[3] = StartCoroutine(StartForth());
                coroutineIsRunning = true;
            }
        }
        if(b_tutoFinished)
        {
            Time.timeScale = 1f;
            scPlayer.bGameIsPaused = false;
            scPlayer.PauseGame();
            SetCartPosition(m_Position + m_Speed * Time.unscaledDeltaTime);
        }
        if (b_tutoFinished && goCameraBackTrack[0].transform.position.z <= 6f)
        {
            if (bOnce == false)
            {

                bTuto[4] = true;
                tutoCoroutine[2] = StartCoroutine(StartThird());
            }
        }
    }
    private IEnumerator StartFirst()
    {
        yield return new WaitForSecondsRealtime(0.1f);
        bWaitSpace = true;
        yield return new WaitForSecondsRealtime(0.9f);
        bTuto[0] = true;
        GoTuto1[0].SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        UnityEngine.UI.Image img1 = GoTuto1[0].GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto1[0];
        GoTuto1[1].SetActive(true);
        yield return new WaitForSecondsRealtime(2.5f);
        UnityEngine.UI.Image img2 = GoTuto1[1].GetComponent<UnityEngine.UI.Image>();
        img2.sprite = spriteBubbleTuto1[1];
        GoTuto1[2].SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto1[3].SetActive(true);
        yield return new WaitForSecondsRealtime(2.5f);
        UnityEngine.UI.Image img3 = GoTuto1[2].GetComponent<UnityEngine.UI.Image>();
        img3.sprite = spriteBubbleTuto1[2];
        UnityEngine.UI.Image img4 = GoTuto1[3].GetComponent<UnityEngine.UI.Image>();
        img4.sprite = spriteBubbleTuto1[3];
        yield return new WaitForSecondsRealtime(1f);
        GoTuto1[4].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto1[4].transform.GetChild(1).gameObject.SetActive(true);
        bTuto[1] = true;
        bTuto[0] = false;
    }
    private IEnumerator SkipFirstTuto()
    {
        bWaitSpace = false;
        StopCoroutine(tutoCoroutine[0]);
        UnityEngine.UI.Image[] img = new UnityEngine.UI.Image[4];
        for (int i = 0; i < 4; i++)
        {
            GoTuto1[i].SetActive(true);
            img[i] = GoTuto1[i].GetComponent<UnityEngine.UI.Image>();
            img[i].sprite = spriteBubbleTuto1[i];
        }
        GoTuto1[4].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto1[4].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        bWaitSpace = true;
        bTuto[1] = true;
        bTuto[0] = false;
    }
    private IEnumerator StartSecond()
    {
        bWaitSpace = false;
        GoTuto2[0].transform.parent.gameObject.SetActive(true);
        GoTuto2[0].gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.1f);
        bWaitSpace = true;
        yield return new WaitForSecondsRealtime(0.9f);
        bTuto[2] = true;
        bTuto[1] = false;
        UnityEngine.UI.Image img1 = GoTuto2[0].GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto2[0];
        GoTuto2[1].gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        UnityEngine.UI.Image img2 = GoTuto2[1].GetComponent<UnityEngine.UI.Image>();
        img2.sprite = spriteBubbleTuto2[1];
        yield return new WaitForSecondsRealtime(1f);
        GoTuto2[2].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto2[2].transform.GetChild(1).gameObject.SetActive(true);
        bTuto[3] = true;
        bTuto[2] = false;
    }
    private IEnumerator SkipTutoSecond()
    {
        StopCoroutine(tutoCoroutine[1]);
        bWaitSpace = false;
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto2[0].gameObject.SetActive(false);
        GoTuto2[1].gameObject.SetActive(true);
        UnityEngine.UI.Image img1 = GoTuto2[1].GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto2[1];
        GoTuto2[2].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto2[2].transform.GetChild(1).gameObject.SetActive(true);
        m_Speed = 20f;
        bWaitSpace = true;
        bTuto[3] = true;
        bTuto[2] = false;
        //Il faut augmenter la vitesse du tuto
    }
    private void StartMidSecond()
    {
        scPlayer.bGameIsPaused = false;
        scPlayer.PauseGame();
        GoTuto2[2].transform.GetChild(1).gameObject.SetActive(false);
        GoTuto2[0].gameObject.SetActive(false);
        bWaitSpace = false;
        b_tutoFinished = true;
        bTuto[3] = false;
    }
    private IEnumerator StartThird()
    {
        GoTuto3[0].transform.parent.gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto3[0].gameObject.SetActive(true);
        bWaitSpace = true;
        yield return new WaitForSecondsRealtime(1.5f);
        UnityEngine.UI.Image img1 = GoTuto3[0].GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto3;
        yield return new WaitForSecondsRealtime(1.5f);
        GoTuto3[1].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto3[1].transform.GetChild(1).gameObject.SetActive(true);
        bTuto[4] = false;
        bTuto[5] = true;
        //Il faut augmenter la vitesse du tuto
    }
    private IEnumerator SkipThirdTuto()
    {
        StopCoroutine(tutoCoroutine[2]);
        GoTuto3[0].transform.parent.gameObject.SetActive(true);
        GoTuto3[0].gameObject.SetActive(true);
        UnityEngine.UI.Image img1 = GoTuto3[0].GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto3;
        GoTuto3[1].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto3[1].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        bTuto[4] = false;
        bTuto[5] = true;
        m_Speed = 20f;
        bWaitSpace = true;
    }
    private IEnumerator StartForth()
    {
        bOnce = true;
        GoTuto2[0].transform.parent.gameObject.SetActive(false);
        for (int i = 0; i < 3; i++)
        {
            goCameraMain[i].SetActive(true);
        }
        for (int i = 0; i < 3; i++)
        {
            goCameraBackTrack[i].SetActive(false);
        }
        yield return new WaitForSecondsRealtime(0.1f);
        bWaitSpace = true;
        yield return new WaitForSecondsRealtime(0.9f);
        coroutineIsRunning = false;
        scPlayer.bisTuto = false;
        StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
    }
    private IEnumerator ImuneToTuto(BPM_Manager bpmmanager)
    {
        scPlayer.bIsImune = true;
        if (bpmmanager.FSPB <0.6)
        {
            yield return new WaitForSecondsRealtime(bpmmanager.FSPB * 4);
        }
        else
        {
            yield return new WaitForSecondsRealtime(bpmmanager.FSPB * 2);
        }
        scPlayer.bIsImune = false;
    }
    private void SetCartPosition(float distanceAlongPath)
    {
        if (m_Path != null)
        {
            m_Position = m_Path.StandardizeUnit(distanceAlongPath, m_PositionUnits); //goCameraBackTrack[0].
            goCameraBackTrack[2].transform.position = m_Path.EvaluatePositionAtUnit(m_Position, m_PositionUnits);
            goCameraBackTrack[2].transform.rotation = m_Path.EvaluateOrientationAtUnit(m_Position, m_PositionUnits);
        }
    }
}