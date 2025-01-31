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
    [SerializeField] private GameObject[] GoTuto3 = new GameObject[3];
    [SerializeField] private GameObject[] goCameraBackTrack = new GameObject[3]; //cam, dolly, empty
    [SerializeField] private GameObject[] goCameraMain = new GameObject[3]; //cam, dolly, ui
    [SerializeField] private CinemachinePathBase m_Path;
    [SerializeField] private float m_Speed = 10f;
    private float m_Position;
    [SerializeField] private CinemachinePathBase.PositionUnits m_PositionUnits = CinemachinePathBase.PositionUnits.Distance;
    private bool b_tutoFinished = false;
    private bool bWallToSee = false;
    [SerializeField] private Sprite[] spriteBubbleTuto1 = new Sprite[4];
    [SerializeField] private Sprite[] spriteBubbleTuto2 = new Sprite[2];
    [SerializeField] private Sprite[] spriteBubbleTuto3 = new Sprite[2];
    [SerializeField] private SC_Player scPlayer;
    private Coroutine[] tutoCoroutine = new Coroutine[4];
    private bool coroutineIsRunning = false;
    private bool bWaitSpace = false;
    private bool bOnce = false;

    private void Start()
    {
        scPlayer.bGameIsPaused = true;
        scPlayer.PauseGame();
        tutoCoroutine[0] = StartCoroutine(StartFirst());
    }
    private void Update()
    {
        if (bWaitSpace)
        {
            if (!b_tutoFinished && GoTuto1[4].transform.GetChild(0).gameObject.activeInHierarchy && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                bWaitSpace = false;
                StartCoroutine(SkipFirstTuto());
            }
            if (!b_tutoFinished && GoTuto1[4].transform.GetChild(1).gameObject.activeInHierarchy && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                GoTuto1[0].transform.parent.gameObject.SetActive(false);
                tutoCoroutine[1] = StartCoroutine(StartSecond());
            }
            if (!b_tutoFinished && GoTuto2[2].transform.GetChild(1).gameObject.activeInHierarchy && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                bWaitSpace = false;
                scPlayer.bGameIsPaused = false;
                scPlayer.PauseGame();
                GoTuto2[2].transform.GetChild(1).gameObject.SetActive(false);
                b_tutoFinished = true;
            }
            if (b_tutoFinished && GoTuto3[2].transform.GetChild(0).gameObject.activeInHierarchy && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                StartCoroutine(SkipThirdTuto());
                bWaitSpace = false;
            }
            if (b_tutoFinished && GoTuto3[2].transform.GetChild(1).gameObject.activeInHierarchy && ((!scPlayer.bIsOnComputer && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
            {
                GoTuto3[0].transform.parent.gameObject.SetActive(false);
                bWallToSee = true;
                Time.timeScale = 1f;
            }
        }
        if (b_tutoFinished && goCameraBackTrack[0].transform.position.z > 5.5f && ((goCameraBackTrack[0].transform.position.z == 28.5f && bWallToSee)||(goCameraBackTrack[0].transform.position.z != 28.5f && !bWallToSee)))
        {
            Time.timeScale = 1f;
            SetCartPosition(m_Position + m_Speed * Time.unscaledDeltaTime);
        }
        if (b_tutoFinished && goCameraBackTrack[0].transform.position.z <= 6f)
        {
            if (bOnce == false)
            {
                tutoCoroutine[3] = StartCoroutine(StartForth());
                coroutineIsRunning = true;
                Debug.Log("fini");
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
        img3.sprite = spriteBubbleTuto1[2];
        UnityEngine.UI.Image img4 = GoTuto1[3].GetComponent<UnityEngine.UI.Image>();
        img4.sprite = spriteBubbleTuto1[3];
        yield return new WaitForSecondsRealtime(1f);
        GoTuto1[4].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto1[4].transform.GetChild(1).gameObject.SetActive(true);
        bWaitSpace = true;
    }
    private IEnumerator SkipFirstTuto()
    {
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
        yield return new WaitForSecondsRealtime(0.5f);
        bWaitSpace = true;
    }
    private IEnumerator StartSecond()
    {
        GoTuto2[0].transform.parent.gameObject.SetActive(true);
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
        GoTuto2[2].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto2[2].transform.GetChild(1).gameObject.SetActive(true);
        bWaitSpace = false;
        b_tutoFinished = true;
        GoTuto2[0].gameObject.SetActive(false);
    }
    private IEnumerator SkipTutoSecond()
    {
        StopCoroutine(tutoCoroutine[1]);
        bWaitSpace = false;
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto2[0].gameObject.SetActive(false);
        GoTuto2[1].gameObject.SetActive(true);
        UnityEngine.UI.Image img1 = GoTuto2[1].transform.GetChild(1).gameObject.GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto2[1];
        GoTuto2[2].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto2[2].transform.GetChild(1).gameObject.SetActive(true);
        m_Speed = 20f;
        b_tutoFinished = true;
        //Il faut augmenter la vitesse du tuto
    }
    public void ThirdTuto()
    {
        Time.timeScale = 0f;
        Debug.Log("passer le mur");
        tutoCoroutine[2] = StartCoroutine(StartThird());
    }
    private IEnumerator StartThird()
    {
        GoTuto3[0].transform.parent.gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto3[0].gameObject.SetActive(true);
        bWaitSpace = true;
        yield return new WaitForSecondsRealtime(1.5f);
        UnityEngine.UI.Image img1 = GoTuto3[0].GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto3[0];
        GoTuto3[1].gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        UnityEngine.UI.Image img2 = GoTuto3[1].GetComponent<UnityEngine.UI.Image>();
        img2.sprite = spriteBubbleTuto3[1];
        yield return new WaitForSecondsRealtime(1.5f);
        GoTuto3[2].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto3[2].transform.GetChild(1).gameObject.SetActive(true);
        //Il faut augmenter la vitesse du tuto
    }
    private IEnumerator SkipThirdTuto()
    {
        StopCoroutine(tutoCoroutine[2]);
        GoTuto3[0].transform.parent.gameObject.SetActive(true);
        GoTuto3[0].gameObject.SetActive(true);
        UnityEngine.UI.Image img1 = GoTuto3[0].GetComponent<UnityEngine.UI.Image>();
        img1.sprite = spriteBubbleTuto3[0];
        GoTuto3[1].gameObject.SetActive(true);
        UnityEngine.UI.Image img2 = GoTuto3[1].GetComponent<UnityEngine.UI.Image>();
        img2.sprite = spriteBubbleTuto3[1];
        GoTuto3[2].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto3[2].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        GoTuto3[0].transform.parent.gameObject.SetActive(false);
        m_Speed = 20f; 
        bWallToSee = true;
        Time.timeScale = 1f;
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
        yield return new WaitForSecondsRealtime(1f);
        bWaitSpace = true;
        coroutineIsRunning = false;
        scPlayer.bisTuto = false;
        StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
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