using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using Unity.VisualScripting;
using Cinemachine;
using static Cinemachine.CinemachinePathBase;

public class sc_tuto : MonoBehaviour
{
     [SerializeField]private GameObject[] GoTuto = new GameObject[7];
    private bool b_tutoFinished = false;
    [SerializeField] private Sprite[] spriteBubbleTuto1;
    [SerializeField] private SC_Player scPlayer;
    [Tooltip("0 is toLeft, 1 is toUp, 2 is toRight, 3 is toRightDown, 4 is toRightUp, 5 is toLeftUp")][SerializeField] private GameObject[] fo_arrow = new GameObject[6];
    [SerializeField] private Material[] materials = new Material[2];
    private MeshRenderer[] render = new MeshRenderer[6];
    [SerializeField]private bool isMeshable = false;
    [SerializeField] private bool isEnnemiTuto = false;
    //[SerializeField] private GameObject goEmptyToFollw;
    [SerializeField] private GameObject[] goCameraBackTrack = new GameObject[3];
    [SerializeField] private GameObject[] goCameraMain = new GameObject[3];
    bool bOnce = false;
    private bool bWaitSpace = false;
    public bool bKnowEnnemy= false;
    private bool bCamTuto = false;
    [SerializeField] private CinemachinePathBase m_Path;
    [SerializeField] private float m_Speed;
    private float m_Position;
    [SerializeField] private CinemachinePathBase.PositionUnits m_PositionUnits = CinemachinePathBase.PositionUnits.Distance;

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
            for (int i = 0; i < 6; i++)
            {
                //GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i] = fo_arrow[i].GetComponent<MeshRenderer>();
            }
            StartCoroutine(StartFirst());
        }
    }

    private void Update()
    {
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
                StartCoroutine(StartThird());
            }
        }
        if(isMeshable == false && b_tutoFinished == false && GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(0).gameObject.activeInHierarchy && Input.GetButtonDown("Jump"))
        {
            StartCoroutine(SkipFirstTuto());
        }
        if(bWaitSpace)
        {
            if(GoTuto[0].transform.GetChild(6).gameObject.transform.GetChild(1).gameObject.activeInHierarchy && Input.GetButtonDown("Jump") && isMeshable == false)
            {
                StartCoroutine(StartSecond());
                bWaitSpace = false;
            }
            if(GoTuto[3].activeInHierarchy && Input.GetButtonDown("Jump"))
            {
                StartForth();
            }
            if(GoTuto[4].activeInHierarchy && (Input.GetKeyDown(KeyCode.V) || Input.GetButtonDown("Jump")))
            {
                scPlayer.bGameIsPaused = false;
                scPlayer.PauseGame();
                GoTuto[4].SetActive(false);
                bWaitSpace = false;
            }
            if(GoTuto[5].activeInHierarchy && Input.GetButtonDown("Jump"))
            {
                scPlayer.bGameIsPaused = false;
                scPlayer.PauseGame();
                GoTuto[5].SetActive(false);
                bWaitSpace = false;
            }
            if(GoTuto[6].activeInHierarchy && Input.GetButtonDown("Jump"))
            {
                scPlayer.bGameIsPaused = false;
                scPlayer.PauseGame();
                GoTuto[6].SetActive(false);
                bWaitSpace = false;
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
        StopCoroutine(StartFirst());
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
            for (int i = 0; i < 6; i++)
            {
                render[i].material = materials[0];
            }
            render[0].material = materials[1]; //GAUCHE
        }
        else if (scPlayer.UI_Joystick[0].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                render[i].material = materials[0];
            }
            render[1].material = materials[1]; //HAUT
        }
        else if (scPlayer.UI_Joystick[4].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                render[i].material = materials[0];
            }
            render[2].material = materials[1]; //DROITE
        }
        else if (scPlayer.UI_Joystick[7].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                render[i].material = materials[0];
            }
            render[4].material = materials[1]; //BAS DROITE
        }
        else if (scPlayer.UI_Joystick[1].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                render[i].material = materials[0];
            }
            render[3].material = materials[1]; //HAUT DROITE
            render[5].material = materials[1];
        }
        else
        {
            for (int i = 0; i < 6; i++)
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
        yield return new WaitForSecondsRealtime(1f);
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        GoTuto[1].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(false);
        b_tutoFinished = true;
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
        GoTuto[2].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        GoTuto[2].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        GoTuto[2].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        GoTuto[2].SetActive(false);
        GoTuto[3].SetActive(true);
        goCameraMain[0].SetActive(true);
        for(int i = 1;i < 4;i++)
        {
            goCameraMain[0].transform.GetChild(i).gameObject.SetActive(false);
        }
        yield return new WaitForSecondsRealtime(2f);
        bWaitSpace = true;
    }

    IEnumerator StartFith()
    {
        yield return new WaitForSecondsRealtime(1.5f);
        GoTuto[5].transform.GetChild(1).gameObject.SetActive(true);
        goCameraMain[0].transform.GetChild(3).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.2f);
        GoTuto[5].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1f);
        bWaitSpace = true;
    }

    IEnumerator ScraffiTime()
    {
        yield return new WaitForSecondsRealtime(2f);
        GoTuto[6].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        GoTuto[6].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        bWaitSpace = true;
    }

    private void StartForth()
    {
        bWaitSpace = false;
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
        bWaitSpace = true;
        GoTuto[4].SetActive(true);
        scPlayer.bGameIsPaused = true;
        scPlayer.PauseGame();
    }

    public void TutoScraffi()
    {
        GoTuto[6].SetActive(true);
        GoTuto[6].transform.GetChild(0).gameObject.SetActive(true);
        scPlayer.bGameIsPaused = true;
        scPlayer.PauseGame();
        StartCoroutine(ScraffiTime()); 
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
        StartCoroutine(StartFith());
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
}
