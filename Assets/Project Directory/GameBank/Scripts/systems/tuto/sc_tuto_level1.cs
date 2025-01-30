using Cinemachine;
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
    [SerializeField] private GameObject[] goCameraBackTrack = new GameObject[3]; //cam, dolly, empty
    [SerializeField] private GameObject[] goCameraMain = new GameObject[3]; //cam, dolly, ui
    [SerializeField] private CinemachinePathBase m_Path;
    [SerializeField] private float m_Speed = 5f;
    private float m_Position;
    [SerializeField] private CinemachinePathBase.PositionUnits m_PositionUnits = CinemachinePathBase.PositionUnits.Distance;
    private bool b_tutoFinished = false;
    [SerializeField] private Sprite[] spriteBubbleTuto1 = new Sprite[4];
    [SerializeField] private Sprite[] spriteBubbleTuto2 = new Sprite[2];
    [SerializeField] private SC_Player scPlayer;
    private Coroutine tutoCoroutine;
    private bool coroutineIsRunning = false;
    private bool bWaitSpace = false;
    private bool bOnce = false;

    private void Start()
    {
        scPlayer.bGameIsPaused = true;
        scPlayer.PauseGame();
        tutoCoroutine = StartCoroutine(StartFirst());
    }
    private void Update()
    {
        if (bWaitSpace)
        {
            if (b_tutoFinished == false && GoTuto1[4].transform.GetChild(0).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                StartCoroutine(SkipFirstTuto());
            }
            if (b_tutoFinished == false && GoTuto1[4].transform.GetChild(1).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                GoTuto1[0].transform.parent.gameObject.SetActive(false);
                StartCoroutine(StartSecond());
            }
            if (b_tutoFinished == false && GoTuto2[3].transform.GetChild(1).gameObject && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                bWaitSpace = false;
                scPlayer.bGameIsPaused = false;
                scPlayer.PauseGame();
                StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
                b_tutoFinished = true;
            }
        }
        if (b_tutoFinished == true && goCameraBackTrack[2].transform.position.z > 0.5f)
        {
            Time.timeScale = 1f;
            SetCartPosition(m_Position + m_Speed * Time.unscaledDeltaTime);
        }
        if (b_tutoFinished == true && goCameraBackTrack[2].transform.position.z <= 1f)
        {
            if (bOnce == false)
            {
                tutoCoroutine = StartCoroutine(StartThird());
                GoTuto1[1].transform.GetChild(2).gameObject.SetActive(false);
                coroutineIsRunning = true;
            }
        }
    }
    private IEnumerator StartFirst()
    {
        yield return new WaitForSecondsRealtime(1f);
        GoTuto1[0].SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        bWaitSpace = true;
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
        img3.sprite = spriteBubbleTuto1[3];
        UnityEngine.UI.Image img4 = GoTuto1[3].GetComponent<UnityEngine.UI.Image>();
        img4.sprite = spriteBubbleTuto1[4];
        yield return new WaitForSecondsRealtime(1f);
        GoTuto1[4].SetActive(false);
        GoTuto1[4].SetActive(true);
        bWaitSpace = true;
    }
    private IEnumerator SkipFirstTuto()
    {
        StopCoroutine(tutoCoroutine);
        UnityEngine.UI.Image[] img = new UnityEngine.UI.Image[4];
        for (int i = 0; i < 4; i++)
        {
            GoTuto1[0].transform.GetChild(i).gameObject.SetActive(true);
            img[i] = GoTuto1[0].transform.GetChild(i).gameObject.GetComponent<UnityEngine.UI.Image>();
            img[i].sprite = spriteBubbleTuto1[i];
        }
        GoTuto1[4].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto1[4].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        bWaitSpace = true;
    }
    private IEnumerator StartSecond()
    {
        GoTuto2[0].gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        bWaitSpace = true;
        UnityEngine.UI.Image img1 = GoTuto2[0].GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto2[0];
        GoTuto2[1].gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        UnityEngine.UI.Image img2 = GoTuto2[1].GetComponent<UnityEngine.UI.Image>();
        img2.sprite = spriteBubbleTuto2[1];
        yield return new WaitForSecondsRealtime(1f);
        GoTuto2[3].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto2[3].transform.GetChild(1).gameObject.SetActive(true);
        bWaitSpace = false;
        b_tutoFinished = true;
    }
    private IEnumerator SkipTutoSecond()
    {
        StopCoroutine(tutoCoroutine);
        bWaitSpace = false;
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto2[0].gameObject.SetActive(false);
        GoTuto2[1].gameObject.SetActive(true);
        UnityEngine.UI.Image img1 = GoTuto2[1].transform.GetChild(1).gameObject.GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto2[1];
        GoTuto2[3].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto2[3].transform.GetChild(1).gameObject.SetActive(true);
        m_Speed = 10f;
        b_tutoFinished = true;
        //Il faut augmenter la vitesse du tuto
    }
    private IEnumerator StartThird()
    {
        bOnce = true;
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
        /*GoTuto[2].transform.GetChild(3).gameObject.SetActive(true);
        GoTuto[2].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        Image img1 = GoTuto[2].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto3[0];
        GoTuto[2].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        Image img2 = GoTuto[2].transform.GetChild(1).gameObject.GetComponent<Image>();
        img2.sprite = spriteBubbleTuto3[1];
        GoTuto[2].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        Image img3 = GoTuto[2].transform.GetChild(2).gameObject.GetComponent<Image>();
        img3.sprite = spriteBubbleTuto3[2];
        GoTuto[2].SetActive(false);
        GoTuto[3].SetActive(true);*/
        goCameraMain[0].SetActive(true);
        for (int i = 1; i < 4; i++)
        {
            goCameraMain[0].transform.GetChild(i).gameObject.SetActive(false);
        }
        coroutineIsRunning = false;
    }
    private IEnumerator ImuneToTuto(BPM_Manager bpmmanager)
    {
        scPlayer.bIsImune = true;
        yield return new WaitForSecondsRealtime(bpmmanager.FSPB * 2);
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