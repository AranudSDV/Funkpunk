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
    [SerializeField]private GameObject[] GoTuto = new GameObject[7];
    private bool b_tutoFinished = false;
    [SerializeField] private Sprite[] spriteBubbleTuto1;
    [SerializeField] private Sprite spriteBubbleTuto2;
    [SerializeField] private Sprite[] spriteBubbleTuto3;
    [SerializeField] private Sprite[] spriteBubbleTuto6;
    [SerializeField] private Sprite[] spriteBubbleTuto7;
    [SerializeField] private SC_Player scPlayer;
    [Tooltip("0 is toLeft, 1 is toUp, 2 is toRight, 3 is toRightDown, 4 is toRightUp, 5 is toLeftUp")][SerializeField] private GameObject[] fo_arrow = new GameObject[4];
    [SerializeField] private Material[] materials = new Material[2];
    private MeshRenderer[] render = new MeshRenderer[4];
    [SerializeField]private bool isMeshable = false;
    [SerializeField] private bool isEnnemiTuto = false;
    //[SerializeField] private GameObject goEmptyToFollw;
    [SerializeField] private GameObject[] goCameraBackTrack = new GameObject[3];
    [SerializeField] private GameObject[] goCameraMain = new GameObject[3];
    bool bOnce = false;
    [SerializeField] private bool bWaitSpace = false;
    public bool bKnowEnnemy= false;
    [SerializeField] private CinemachinePathBase m_Path;
    [SerializeField] private float m_Speed = 5f;
    private float m_Position;
    [SerializeField] private CinemachinePathBase.PositionUnits m_PositionUnits = CinemachinePathBase.PositionUnits.Distance;
    private Coroutine[] tutoCoroutine = new Coroutine[5];
    private bool coroutineIsRunning = false; 

    private void Start()
    {
        if (scPlayer == null)
        {
            GameObject goPlayer = GameObject.FindWithTag("Player");
            scPlayer = goPlayer.GetComponent<SC_Player>();
        }
        if (isMeshable == false)
        {
            scPlayer.bGameIsPaused = true;
            scPlayer.PauseGame();
            GoTuto[0].gameObject.SetActive(true);
            for (int i = 0; i < 4; i++)
            {
                //GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i] = fo_arrow[i].GetComponent<MeshRenderer>();
            }
            ChangeTutoController();
            tutoCoroutine[0] = StartCoroutine(StartFirst());
        }
    }
    private void Update()
    {
        if(isMeshable==false)
        {
            ChangeTutoController();
        }
        if(b_tutoFinished == true && isMeshable ==false && goCameraBackTrack[2].transform.position.z > 0.5f)
        {
            Time.timeScale = 1f;
            SetCartPosition(m_Position + m_Speed * Time.unscaledDeltaTime);
        }
        if(b_tutoFinished == true && goCameraBackTrack[2].transform.position.z <=1f && isMeshable == false)
        {
            TutoArrows();
            if (bOnce == false)
            {
                tutoCoroutine[1] = StartCoroutine(StartThird());
                GoTuto[1].transform.GetChild(2).gameObject.SetActive(false);
                coroutineIsRunning = true;
            }
        }
        if(isMeshable == false && b_tutoFinished == false && GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(0).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer ==false && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && Input.GetButtonDown("Jump"))))
        {
            StartCoroutine(SkipFirstTuto());
        }
        if(bWaitSpace)
        {
            if(GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(1).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")) && isMeshable == false)
            {
                bWaitSpace = false;
                tutoCoroutine[2] = StartCoroutine(StartSecond());
            }
            if(GoTuto[1].transform.GetChild(0).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                StartCoroutine(SkipTutoSecond());
            }
            if(GoTuto[2].transform.GetChild(0).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                StartCoroutine(ThirdSkip());
            }
            if(GoTuto[3].gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")) && coroutineIsRunning==false)
            {
                bWaitSpace = false;
                Debug.Log("passer le tuto de rythme");
                StartForth();
            }
            if(GoTuto[4].activeInHierarchy &&  ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                scPlayer.bGameIsPaused = false;
                scPlayer.PauseGame();
                GoTuto[4].SetActive(false);
            }
            if(GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(0).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                StartCoroutine(SkipFifth());
            }
            if (GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(1).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                scPlayer.bGameIsPaused = false;
                scPlayer.PauseGame();
                GoTuto[5].SetActive(false);
            }
            if(GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(0).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                StartCoroutine(SkipScraffiTime());
            }
            if(GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(1).gameObject.activeInHierarchy && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump")))
            {
                bWaitSpace = false;
                scPlayer.bGameIsPaused = false;
                scPlayer.PauseGame();
                GoTuto[6].SetActive(false);
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
        bWaitSpace = true;
    }
    private void TutoArrows()
    {
        if (scPlayer.UI_Joystick[3].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 4; i++)
            {
                render[i].material = materials[0];
            }
            render[0].material = materials[1]; //GAUCHE
        }
        else if (scPlayer.UI_Joystick[0].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 4; i++)
            {
                render[i].material = materials[0];
            }
            render[1].material = materials[1]; //HAUT
        }
        else if (scPlayer.UI_Joystick[4].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 4; i++)
            {
                render[i].material = materials[0];
            }
            render[2].material = materials[1]; //DROITE
        }
        else if (scPlayer.UI_Joystick[1].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
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
        GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        bWaitSpace = true;
        /*scPlayer.bGameIsPaused = false;
        scPlayer.PauseGame(); */
    }
    IEnumerator StartSecond()
    {
        GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(1).gameObject.SetActive(false);
        GoTuto[0].gameObject.SetActive(false);
        GoTuto[1].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        bWaitSpace = true;
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        GoTuto[1].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        Image img1 = GoTuto[1].transform.GetChild(1).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto2;
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[1].transform.GetChild(2).gameObject.SetActive(false);
        b_tutoFinished = true;
    }
    IEnumerator SkipTutoSecond()
    {
        StopCoroutine(tutoCoroutine[2]);
        bWaitSpace = false;
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[1].transform.GetChild(1).gameObject.SetActive(true);
        Image img1 = GoTuto[1].transform.GetChild(1).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto2;
        GoTuto[1].transform.GetChild(2).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        GoTuto[1].transform.GetChild(2).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        m_Speed = 10f;
        b_tutoFinished = true;
        //Il faut augmenter la vitesse du tuto
    }
    IEnumerator StartThird()
    {
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
        for(int i = 1;i < 4;i++)
        {
            goCameraMain[0].transform.GetChild(i).gameObject.SetActive(false);
        }
        coroutineIsRunning = false;
    }
    IEnumerator ThirdSkip()
    {
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
        for (int i = 1; i < 4; i++)
        {
            goCameraMain[0].transform.GetChild(i).gameObject.SetActive(false);
        }
        GoTuto[3].SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        bWaitSpace = true;
        coroutineIsRunning = false;
    }
    IEnumerator StartFith()
    {
        yield return new WaitForSecondsRealtime(1.5f);
        bWaitSpace = true;
        Image img1 = GoTuto[5].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto6[0];
        GoTuto[5].transform.GetChild(1).gameObject.SetActive(true);
        goCameraMain[0].transform.GetChild(3).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.2f);
        Image img2 = GoTuto[5].transform.GetChild(1).gameObject.GetComponent<Image>();
        img2.sprite = spriteBubbleTuto6[1];
        GoTuto[5].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        Image img3 = GoTuto[5].transform.GetChild(2).gameObject.GetComponent<Image>();
        img3.sprite = spriteBubbleTuto6[2];
        GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(0).gameObject.SetActive(false);
    }
    IEnumerator SkipFifth()
    {
        StopCoroutine(tutoCoroutine[4]);
        Image img1 = GoTuto[5].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto6[0];
        GoTuto[5].transform.GetChild(1).gameObject.SetActive(true);
        goCameraMain[0].transform.GetChild(3).gameObject.SetActive(true);
        Image img2 = GoTuto[5].transform.GetChild(1).gameObject.GetComponent<Image>();
        img2.sprite = spriteBubbleTuto6[1];
        GoTuto[5].transform.GetChild(2).gameObject.SetActive(true);
        Image img3 = GoTuto[5].transform.GetChild(2).gameObject.GetComponent<Image>();
        img3.sprite = spriteBubbleTuto6[2];
        GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        yield return new WaitForSecondsRealtime(0.5f);
        bWaitSpace = true;
    }
    IEnumerator ScraffiTime()
    {
        yield return new WaitForSecondsRealtime(2f);
        bWaitSpace = true;
        Image img1 = GoTuto[6].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto7[0];
        GoTuto[6].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        Image img2 = GoTuto[6].transform.GetChild(1).gameObject.GetComponent<Image>();
        img2.sprite = spriteBubbleTuto7[1];
        GoTuto[6].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        Image img3 = GoTuto[6].transform.GetChild(2).gameObject.GetComponent<Image>();
        img3.sprite = spriteBubbleTuto7[2];
        GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(0).gameObject.SetActive(false);
    }
    IEnumerator SkipScraffiTime()
    {
        StopCoroutine(tutoCoroutine[3]);
        Image img1 = GoTuto[6].transform.GetChild(0).gameObject.GetComponent<Image>();
        img1.sprite = spriteBubbleTuto7[0];
        GoTuto[6].transform.GetChild(1).gameObject.SetActive(true);
        Image img2 = GoTuto[6].transform.GetChild(1).gameObject.GetComponent<Image>();
        img2.sprite = spriteBubbleTuto7[1];
        GoTuto[6].transform.GetChild(2).gameObject.SetActive(true);
        Image img3 = GoTuto[6].transform.GetChild(2).gameObject.GetComponent<Image>();
        img3.sprite = spriteBubbleTuto7[2];
        GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(1).gameObject.SetActive(true);
        GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(0).gameObject.SetActive(false);
        yield return new WaitForSecondsRealtime(0.5f);
        bWaitSpace = true;
    }
    private void StartForth()
    {
        goCameraMain[0].transform.GetChild(1).gameObject.SetActive(true);
        goCameraMain[0].transform.GetChild(2).gameObject.SetActive(true);
        GoTuto[3].SetActive(false);
        scPlayer.bGameIsPaused = false;
        scPlayer.lastMoveDirection = Vector3.left;
        scPlayer.bisTuto = false;
        scPlayer.PauseGame();
    }
    public void StartTutoBait()
    {
        GoTuto[4].SetActive(true);
        scPlayer.bGameIsPaused = true;
        scPlayer.PauseGame();
        StartCoroutine(TutoBait());
    }
    IEnumerator TutoBait()
    {
        yield return new WaitForSecondsRealtime(1.5f);
        bWaitSpace = true;
    }
    public void TutoScraffi()
    {
        GoTuto[6].SetActive(true);
        GoTuto[6].transform.GetChild(0).gameObject.SetActive(true);
        scPlayer.bGameIsPaused = true;
        scPlayer.PauseGame();
        tutoCoroutine[3] = StartCoroutine(ScraffiTime()); 
    }
    public void StartTutoDetection()
    {
        bKnowEnnemy = true;
        GoTuto[5].SetActive(true);
        scPlayer.bGameIsPaused = true;
        scPlayer.PauseGame();
        GoTuto[5].transform.GetChild(0).gameObject.SetActive(true);
        GoTuto[5].transform.GetChild(1).gameObject.SetActive(false);
        GoTuto[5].transform.GetChild(2).gameObject.SetActive(false);
        tutoCoroutine[4] = StartCoroutine(StartFith());
    }
    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player") && isMeshable && isEnnemiTuto ==false)
        {
            scPlayer = collision.GetComponent<SC_Player>();
            sc_tuto tutoriel = GameObject.FindWithTag("Tuto").gameObject.GetComponent<sc_tuto>();
            tutoriel.TutoScraffi();
            Destroy(this.gameObject);
        }
        else if (collision.gameObject.CompareTag("Player") && isMeshable && isEnnemiTuto == true)
        {
            sc_tuto tutoriel = GameObject.FindWithTag("Tuto").gameObject.GetComponent<sc_tuto>();
            if (tutoriel.bKnowEnnemy ==false)
            {
                tutoriel.StartTutoDetection();
            }
        }
    }
    private void ChangeTutoController()
    {
        if (scPlayer.bIsOnComputer==false)
        {
            GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "A to skip";
            GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "A to continue";
            GoTuto[1].transform.GetChild(2).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "A to skip";
            GoTuto[2].transform.GetChild(3).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "A to skip";
            GoTuto[3].transform.GetChild(1).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "A to continue";
            GoTuto[3].transform.GetChild(0).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Use your joystick for directions, then \"A\" on the rythm in order to move.";
            GoTuto[4].transform.GetChild(1).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "A to continue";
            GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "A to skip";
            GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "A to continue";
            GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "A to skip";
            GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "A to continue";
        }
        else
        {
            GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Space to skip";
            GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "Space to continue";
            GoTuto[1].transform.GetChild(2).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Space to skip";
            GoTuto[2].transform.GetChild(3).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Space to skip";
            GoTuto[3].transform.GetChild(1).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Space to continue";
            GoTuto[3].transform.GetChild(0).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Use \"WASD\" for directions, then \"space\" on the rythm in order to move.";
            GoTuto[4].transform.GetChild(1).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Space to continue";
            GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Space to skip";
            GoTuto[5].transform.GetChild(3).gameObject.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "Space to continue";
            GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(0).GetComponent<TextMeshProUGUI>().text = "Space to skip";
            GoTuto[6].transform.GetChild(3).gameObject.transform.GetChild(1).GetComponent<TextMeshProUGUI>().text = "Space to continue";
        }
    }
}
