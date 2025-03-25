using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Unity.VisualScripting;
using Cinemachine;
using static Cinemachine.CinemachinePathBase;
using TMPro;

public class sc_tuto : MonoBehaviour
{
    //BD
    [Header("Tuto1")]
    [SerializeField] private float[] fTimer1;
    private float ftimer = 0f;
    private bool[] b1;
    [SerializeField] private RectTransform[] GoTuto1;
    private Image[] imgTuto1;
    [SerializeField] private Sprite[] spriteBubbleTuto1;

    [Header("Last")]
    [SerializeField]private GameObject[] GoTuto = new GameObject[7];
    private bool b_tutoFinished = false;
    [SerializeField] private Sprite spriteBubbleTuto2;
    [SerializeField] private Sprite[] spriteBubbleTuto3;
    [SerializeField] private Sprite[] spriteBubbleTuto6;
    private Coroutine[] tutoCoroutine = new Coroutine[4];
    private bool coroutineIsRunning = false;
    private bool b_cameraIsTracking = false;
    [SerializeField] private bool[] bTuto = new bool[9];

    //PLAYER
    [SerializeField] private SC_Player scPlayer;
    public bool bKnowEnnemy = false;

    //DYNAMIC TUTO
    [Tooltip("0 is toLeft, 1 is toUp, 2 is toRight, 3 is toRightDown, 4 is toRightUp, 5 is toLeftUp")][SerializeField] private GameObject[] fo_arrow = new GameObject[4];
    [SerializeField] private Material[] materials = new Material[2];
    private MeshRenderer[] render = new MeshRenderer[4];
    [SerializeField]private bool isMeshable = false;
    [SerializeField] private bool isEnnemiTuto = false;
    //[SerializeField] private GameObject goEmptyToFollw;

    //CAMERAS
    [SerializeField] private GameObject[] goCameraBackTrack = new GameObject[3];
    [SerializeField] private GameObject[] goCameraMain = new GameObject[3];
    [SerializeField] private CinemachinePathBase m_Path;
    [SerializeField] private float m_Speed = 5f;
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
        if (isMeshable == false)
        {
            scPlayer.menuManager.bGameIsPaused = true;
            scPlayer.menuManager.PauseGame();
            GoTuto[0].gameObject.SetActive(true);
            for (int i = 0; i < 4; i++)
            {
                //GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i] = fo_arrow[i].GetComponent<MeshRenderer>();
            }
            for(int i =0; i<9; i++)
            {
                bTuto[i] = false;
            }
            bTuto[0] = true;
            b1 = new bool[fTimer1.Length];
            for (int i = 0; i< fTimer1.Length; i++)
            {
                b1[i] = false;
            }
            b1[0] = true;
            bWaitSpace = true;
            //tutoCoroutine[0] = StartCoroutine(StartFirst());
        }
    }

        private void Update()
    {
        if (!bInitialized)
        {
            Init();
            bInitialized = true;
        }
        /*if(isMeshable==false)
        {
            ChangeTutoController();
        }*/
        if (bTuto[3] && isMeshable ==false && goCameraBackTrack[2].transform.position.z > 0.5f && !scPlayer.menuManager.bGameIsPaused)
        {
            Time.timeScale = 1f;
            SetCartPosition(m_Position + m_Speed * Time.unscaledDeltaTime);
            b_cameraIsTracking = true;
        }
        if(b_cameraIsTracking && scPlayer.menuManager.CgPauseMenu.alpha == 0f)
        {
            scPlayer.menuManager.bGameIsPaused = false;
            scPlayer.menuManager.PauseGame();
        }
        if(bTuto[3] && goCameraBackTrack[2].transform.position.z <=1f && isMeshable == false)
        {
            TutoArrows();
            b_cameraIsTracking = false;
            if (bOnce == false)
            {
                tutoCoroutine[1] = StartCoroutine(StartThird());
                GoTuto[1].transform.GetChild(2).gameObject.SetActive(false);
                StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
                coroutineIsRunning = true;
            }
        }
        if(bTuto[0])
        {
            Tuto1(Time.unscaledDeltaTime);
        }
        if (bWaitSpace)
        {
            if (bTuto[0] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")) && isMeshable == false)
            {
                //StartCoroutine(SkipFirstTuto());
                Tuto1Skip();
            }
            if (bTuto[1] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")) && isMeshable == false)
            {
                bWaitSpace = false;
                tutoCoroutine[2] = StartCoroutine(StartSecond());
            }
            if (bTuto[2] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                StartCoroutine(SkipTutoSecond());
            }
            if(bTuto[3])
            {
                scPlayer.menuManager.bGameIsPaused = false;
                scPlayer.menuManager.PauseGame();
                bWaitSpace = false;
            }
            if(bTuto[4] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                StartCoroutine(ThirdSkip());
            }
            if(bTuto[5] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")) && coroutineIsRunning==false)
            {
                bWaitSpace = false;
                StartForth();
            }
            if(bTuto[6] &&  ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                scPlayer.menuManager.bGameIsPaused = false;
                scPlayer.menuManager.PauseGame();
                GoTuto[4].SetActive(false);
                StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
            }
            if(bTuto[7] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                StartCoroutine(SkipFifth());
            }
            if (bTuto[8] && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                scPlayer.menuManager.bGameIsPaused = false;
                scPlayer.menuManager.PauseGame();
                GoTuto[5].SetActive(false);
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
        yield return new WaitForSecondsRealtime(bpmmanager.FSPB *2);
        scPlayer.bIsImune = false;
    }
    private IEnumerator SkipFirstTuto()
    {
        StopCoroutine(tutoCoroutine[0]);
        Image[] img = new Image[6];
        for (int i = 0; i<6; i++)
        {
            GoTuto[0].transform.GetChild(i).gameObject.SetActive(true);
            img[i] = GoTuto[0].transform.GetChild(i).gameObject.GetComponent<Image>();
            img[i].sprite = spriteBubbleTuto1[i];
        }
        GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        bTuto[0] = false;
        bTuto[1] = true;
        bWaitSpace = true;
    }
    private void TutoArrows()
    {
        if (scPlayer.lastMoveDirection == Vector3.left)
        {
            for (int i = 0; i < 4; i++)
            {
                render[i].material = materials[0];
            }
            render[0].material = materials[1]; //GAUCHE
        }
        else if (scPlayer.lastMoveDirection == Vector3.forward)
        {
            for (int i = 0; i < 4; i++)
            {
                render[i].material = materials[0];
            }
            render[1].material = materials[1]; //HAUT
        }
        else if (scPlayer.lastMoveDirection == Vector3.right)
        {
            for (int i = 0; i < 4; i++)
            {
                render[i].material = materials[0];
            }
            render[2].material = materials[1]; //DROITE
        }
        else if (scPlayer.lastMoveDirection == new Vector3(1,0,1))
        {
            for (int i = 0; i < 4; i++)
            {
                render[i].material = materials[0];
            }
            render[3].material = materials[1];
        }
        else
        {
            for (int i = 0; i < 4; i++)
            {
                render[i].material = materials[0];
            }
        }
    }
    IEnumerator StartFirst()
    {
        yield return new WaitForSecondsRealtime(1f);
        bTuto[0] = true;
        bWaitSpace = true;
        GoTuto[0].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        Image img1 = GoTuto[0].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto1[0];
        GoTuto[0].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto[0].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2.5f);
        Image img2 = GoTuto[0].transform.GetChild(1).gameObject.GetComponent<Image>();
        img2.sprite = spriteBubbleTuto1[1];
        Image img3 = GoTuto[0].transform.GetChild(2).gameObject.GetComponent<Image>();
        img3.sprite = spriteBubbleTuto1[2];
        GoTuto[0].transform.GetChild(3).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto[0].transform.GetChild(4).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2.5f);
        Image img4 = GoTuto[0].transform.GetChild(3).gameObject.GetComponent<Image>();
        img4.sprite = spriteBubbleTuto1[3];
        Image img5 = GoTuto[0].transform.GetChild(4).gameObject.GetComponent<Image>();
        img5.sprite = spriteBubbleTuto1[4];
        GoTuto[0].transform.GetChild(5).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        Image img6 = GoTuto[0].transform.GetChild(5).gameObject.GetComponent<Image>();
        img6.sprite = spriteBubbleTuto1[5];
        GoTuto[00].transform.GetChild(6).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        bTuto[1] = true;
        bTuto[0] = false;
        /*scPlayer.bGameIsPaused = false;
        scPlayer.PauseGame(); */
    }
    private void Tuto1(float timer)
    {
        ftimer += timer;
        for(int i =0; i < fTimer1.Length; i++)
        {
            if (ftimer >= fTimer1[i] && b1[i])
            {
                GoTuto1[i].offsetMin = Vector2.zero;
                b1[i] = false;
                if(i != fTimer1.Length -1)
                {
                    b1[i + 1] = true;
                    ftimer = 0f;
                }
                else
                {
                    GoTuto1[i + 1].offsetMin = new Vector2(2000f,0f);
                    bTuto[0] = false;
                    bTuto[1] = true;
                }
            }
        }
    }
    private void Tuto1Skip()
    {
        for (int i = 0; i < bTuto.Length; i++)
        {
            GoTuto1[i].offsetMin = Vector2.zero;
            if (i == bTuto.Length)
            {
                bTuto[0] = false;
                bTuto[1] = true;
            }
        }
    }
    IEnumerator StartSecond()
    {
        //GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(1).gameObject.SetActive(false);
        GoTuto[0].gameObject.SetActive(false);
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
        m_Speed = 10f;
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
        GoTuto[2].transform.GetChild(3).gameObject.SetActive(true);
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
        GoTuto[3].SetActive(true);
        goCameraMain[0].SetActive(true);
        goCameraMain[0].transform.GetChild(2).gameObject.SetActive(false);
        bTuto[4] = false;
        bTuto[5] = true;
        coroutineIsRunning = false;
    }
    IEnumerator ThirdSkip()
    {
        bTuto[3] = false;
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
        GoTuto[2].SetActive(false);
        goCameraMain[0].SetActive(true);
        goCameraMain[0].transform.GetChild(2).gameObject.SetActive(false);
        GoTuto[3].SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        bWaitSpace = true;
        bTuto[4] = false;
        bTuto[5] = true;
        coroutineIsRunning = false;
    }
    IEnumerator StartFith()
    {
        yield return new WaitForSecondsRealtime(1.5f);
        goCameraMain[0].transform.GetChild(2).gameObject.SetActive(true);
        bTuto[7] = true;
        bWaitSpace = true;
        Image img1 = GoTuto[5].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto6[0];
        GoTuto[5].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.2f);
        Image img2 = GoTuto[5].transform.GetChild(1).gameObject.GetComponent<Image>();
        img2.sprite = spriteBubbleTuto6[1];
        GoTuto[5].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        Image img3 = GoTuto[5].transform.GetChild(2).gameObject.GetComponent<Image>();
        img3.sprite = spriteBubbleTuto6[2];
        GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        bTuto[7] = false;
        bTuto[8] = true;
    }
    IEnumerator SkipFifth()
    {
        StopCoroutine(tutoCoroutine[3]);
        goCameraMain[0].transform.GetChild(2).gameObject.SetActive(true);
        Image img1 = GoTuto[5].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto6[0];
        GoTuto[5].transform.GetChild(1).gameObject.SetActive(true);
        Image img2 = GoTuto[5].transform.GetChild(1).gameObject.GetComponent<Image>();
        img2.sprite = spriteBubbleTuto6[1];
        GoTuto[5].transform.GetChild(2).gameObject.SetActive(true);
        Image img3 = GoTuto[5].transform.GetChild(2).gameObject.GetComponent<Image>();
        img3.sprite = spriteBubbleTuto6[2];
        GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        yield return new WaitForSecondsRealtime(0.5f);
        bWaitSpace = true;
        bTuto[7] = false;
        bTuto[8] = true;
    }
    private void StartForth()
    {
        bTuto[5] = false;
        goCameraMain[0].transform.GetChild(1).gameObject.SetActive(true);
        GoTuto[3].SetActive(false);
        scPlayer.menuManager.bGameIsPaused = false;
        scPlayer.lastMoveDirection = Vector3.left;
        scPlayer.bisTuto = false;
        scPlayer.menuManager.PauseGame();
    }
    public void StartTutoBait()
    {
        GoTuto[4].SetActive(true);
        scPlayer.menuManager.bGameIsPaused = true;
        scPlayer.menuManager.PauseGame();
        StartCoroutine(TutoBait());
    }
    IEnumerator TutoBait()
    {
        yield return new WaitForSecondsRealtime(1.5f);
        bTuto[6] = true;
        bWaitSpace = true;
    }
    public void StartTutoDetection()
    {
        bKnowEnnemy = true;
        GoTuto[5].SetActive(true);
        scPlayer.menuManager.bGameIsPaused = true;
        scPlayer.menuManager.PauseGame();
        GoTuto[5].transform.GetChild(0).gameObject.SetActive(true);
        GoTuto[5].transform.GetChild(1).gameObject.SetActive(false);
        GoTuto[5].transform.GetChild(2).gameObject.SetActive(false);
        tutoCoroutine[3] = StartCoroutine(StartFith());
    }
    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player") && isMeshable && isEnnemiTuto == true)
        {
            sc_tuto tutoriel = GameObject.FindWithTag("Tuto").gameObject.GetComponent<sc_tuto>();
            if (tutoriel.bKnowEnnemy ==false)
            {
                tutoriel.StartTutoDetection();
            }
        }
    }
}
