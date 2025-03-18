using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Unity.VisualScripting;
using Cinemachine;
using static Cinemachine.CinemachinePathBase;
using TMPro;

public class sc_tuto_lvl2 : MonoBehaviour
{
    //BD
    [SerializeField] private GameObject[] GoTuto = new GameObject[3];
    private bool b_tutoFinished = false;
    [SerializeField] private Sprite spriteBubbleTuto2;
    [SerializeField] private Sprite spriteBubbleTuto3;
    private Coroutine[] tutoCoroutine = new Coroutine[4];
    private bool coroutineIsRunning = false;
    private bool b_cameraIsTracking = false;
    [SerializeField] private bool[] bTuto = new bool[6];

    //PLAYER
    [SerializeField] private SC_Player scPlayer;

    //CAMERAS
    [SerializeField] private GameObject[] goCameraBackTrack = new GameObject[3];
    [SerializeField] private GameObject[] goCameraMain = new GameObject[3];
    [SerializeField] private CinemachinePathBase m_Path;
    [SerializeField] private float m_Speed = 10f;
    private float m_Position;
    [SerializeField] private CinemachinePathBase.PositionUnits m_PositionUnits = CinemachinePathBase.PositionUnits.Distance;

    //UTILISATEUR WAIT
    bool bOnce = false;
    [SerializeField] private bool bWaitSpace = false;
    private bool bInitialized;
    private void Init()
    {
        if (scPlayer == null)
        {
            GameObject goPlayer = GameObject.FindWithTag("Player");
            scPlayer = goPlayer.GetComponent<SC_Player>();
        }
        scPlayer.menuManager.bGameIsPaused = true;
        scPlayer.menuManager.PauseGame();
        scPlayer.bisTuto = true;
        GoTuto[0].gameObject.SetActive(true);
        for (int i = 0; i < 6; i++)
        {
            bTuto[i] = false;
        }
        //ChangeTutoController();
        tutoCoroutine[0] = StartCoroutine(StartFirst());
    }

    private void Update()
    {
        if (!bInitialized)
        {
            Init();
            bInitialized = true;
        }
        if (bTuto[3] && goCameraBackTrack[2].transform.position.z > 6f && !scPlayer.menuManager.bGameIsPaused)
        {
            Time.timeScale = 1f;
            SetCartPosition(m_Position + m_Speed * Time.unscaledDeltaTime);
            b_cameraIsTracking = true;
        }
        if (b_cameraIsTracking && scPlayer.menuManager.CgPauseMenu.alpha == 0f)
        {
            scPlayer.menuManager.bGameIsPaused = false;
            scPlayer.menuManager.PauseGame();
        }
        if (bTuto[3] && goCameraBackTrack[2].transform.position.z <= 7f)
        {
            b_cameraIsTracking = false;
            if (bOnce == false)
            {
                tutoCoroutine[1] = StartCoroutine(StartThird());
                GoTuto[1].transform.GetChild(2).gameObject.SetActive(false);
                StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
                coroutineIsRunning = true;
            }
        }
        if (bWaitSpace)
        {
            if (bTuto[0] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                StartCoroutine(SkipFirstTuto());
            }
            if (bTuto[1] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                tutoCoroutine[2] = StartCoroutine(StartSecond());
            }
            if (bTuto[2] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                StartCoroutine(SkipTutoSecond());
            }
            if (bTuto[3])
            {
                scPlayer.menuManager.bGameIsPaused = false;
                scPlayer.menuManager.PauseGame();
                bWaitSpace = false;
            }
            if (bTuto[4] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                StartCoroutine(ThirdSkip());
            }
            if (bTuto[5] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")) && coroutineIsRunning == false)
            {
                bWaitSpace = false;
                StartForth();
                StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
                b_tutoFinished = true;
            }
        }
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
    private IEnumerator ImuneToTuto(BPM_Manager bpmmanager)
    {
        scPlayer.bIsImune = true;
        yield return new WaitForSecondsRealtime(bpmmanager.FSPB * 2);
        scPlayer.bIsImune = false;
    }
    private IEnumerator SkipFirstTuto()
    {
        StopCoroutine(tutoCoroutine[0]);
        Image[] img = new Image[6];
        for (int i = 0; i < 5; i++)
        {
            GoTuto[0].transform.GetChild(i).gameObject.SetActive(true);
        }
        GoTuto[0].transform.GetChild(5).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[0].transform.GetChild(5).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        bTuto[0] = false;
        bTuto[1] = true;
        bWaitSpace = true;
    }
    IEnumerator StartFirst()
    {
        yield return new WaitForSecondsRealtime(1f);
        bTuto[0] = true;
        bWaitSpace = true;
        GoTuto[0].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.7f);
        GoTuto[0].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        GoTuto[0].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto[0].transform.GetChild(3).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        GoTuto[0].transform.GetChild(4).gameObject.SetActive(true);
        GoTuto[0].transform.GetChild(5).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[0].transform.GetChild(5).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        bTuto[1] = true;
        bTuto[0] = false;
        /*scPlayer.bGameIsPaused = false;
        scPlayer.PauseGame(); */
    }
    IEnumerator StartSecond()
    {
        GoTuto[0].transform.GetChild(5).gameObject.transform.GetChild(1).gameObject.SetActive(false);
        GoTuto[0].gameObject.SetActive(false);
        GoTuto[1].gameObject.SetActive(true);
        GoTuto[1].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        bTuto[1] = false;
        bTuto[2] = true;
        bWaitSpace = true;
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        GoTuto[1].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        Image img1 = GoTuto[1].transform.GetChild(1).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto2;
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[1].transform.GetChild(2).gameObject.SetActive(false);
        bTuto[2] = false;
        bTuto[3] = true;
        bWaitSpace = true;
    }
    IEnumerator SkipTutoSecond()
    {
        StopCoroutine(tutoCoroutine[2]);
        bTuto[1] = false;
        bTuto[2] = false;
        bWaitSpace = false;
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[1].transform.GetChild(1).gameObject.SetActive(true);
        Image img1 = GoTuto[1].transform.GetChild(1).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto2;
        GoTuto[1].transform.GetChild(2).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[1].transform.GetChild(2).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        m_Speed = 15f;
        bTuto[3] = true;
        b_tutoFinished = true;
        bWaitSpace = true;
        //Il faut augmenter la vitesse du tuto
    }
    IEnumerator StartThird()
    {
        bTuto[3] = false;
        bTuto[4] = true;
        bOnce = true;
        GoTuto[1].SetActive(false);
        GoTuto[2].SetActive(true);
        for (int i = 1; i < 3; i++)
        {
            goCameraMain[i].SetActive(true);
        }
        for (int i = 0; i < 3; i++)
        {
            goCameraBackTrack[i].SetActive(false);
        }
        yield return new WaitForSecondsRealtime(1f);
        bWaitSpace = true;
        GoTuto[2].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        Image img1 = GoTuto[2].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto3;
        GoTuto[2].transform.GetChild(1).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[2].transform.GetChild(1).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        bTuto[4] = false;
        bTuto[5] = true;
        coroutineIsRunning = false;
    }
    IEnumerator ThirdSkip()
    {
        bTuto[3] = false;
        bTuto[4] = false;
        StopCoroutine(tutoCoroutine[1]);
        bOnce = true;
        /*scPlayer.bGameIsPaused = true;
        scPlayer.PauseGame();*/
        for (int i = 1; i < 3; i++)
        {
            goCameraMain[i].SetActive(true);
        }
        for (int i = 0; i < 3; i++)
        {
            goCameraBackTrack[i].SetActive(false);
        }
        GoTuto[1].SetActive(false);
        GoTuto[2].SetActive(true);
        goCameraMain[0].SetActive(true);
        GoTuto[2].transform.GetChild(0).gameObject.SetActive(true);
        Image img1 = GoTuto[2].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto3;
        GoTuto[2].transform.GetChild(1).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[2].transform.GetChild(1).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        bWaitSpace = true;
        bTuto[5] = true;
        coroutineIsRunning = false;
    }
    private void StartForth()
    {
        for (int i = 1; i < 3; i++)
        {
            goCameraMain[i].SetActive(true);
        }
        bTuto[5] = false;
        GoTuto[2].SetActive(false);
        scPlayer.menuManager.bGameIsPaused = false;
        scPlayer.lastMoveDirection = Vector3.left;
        scPlayer.bisTuto = false;
        scPlayer.menuManager.PauseGame();
    }
}
