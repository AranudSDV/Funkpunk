using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using Unity.VisualScripting;

public class sc_tuto : MonoBehaviour
{
     [SerializeField]private GameObject[] GoTuto = new GameObject[7];
    private bool b_tutoFinished = false;
    private Image img;
    private SC_Player scPlayer;
    [Tooltip("0 is toLeft, 1 is toUp, 2 is toRight, 3 is toRightDown, 4 is toRightUp, 5 is toLeftUp")][SerializeField] private GameObject[] fo_arrow = new GameObject[6];
    [SerializeField] private Material[] materials = new Material[2];
    private MeshRenderer[] render = new MeshRenderer[6];
    private GameObject goPlayer;
    [SerializeField]private bool isMeshable = false;
    [SerializeField] private bool isEnnemiTuto = false;
    [SerializeField] private GameObject goEmptyToFollw;
    [SerializeField] private GameObject[] goCameraBackTrack = new GameObject[2];
    [SerializeField] private GameObject[] goCameraMain = new GameObject[3];
    bool bOnce = false;
    private bool bWaitSpace = false;
    public bool bKnowEnnemy= false;

    private void Start()
    {
        goPlayer = GameObject.FindWithTag("Player");
        scPlayer = goPlayer.GetComponent<SC_Player>();
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
        if(b_tutoFinished == true && isMeshable ==false && goEmptyToFollw.transform.position.z > 5)
        {
            Time.timeScale = 1f;
            goEmptyToFollw.transform.position -= new Vector3(0f, 0f, 5f * Time.unscaledDeltaTime);
           /* TutoArrows();
            TutoKey();*/
        }
        if(b_tutoFinished == true && goEmptyToFollw.transform.position.z <=5 && isMeshable == false)
        {
            TutoArrows();
            TutoKey();
            if (bOnce == false)
            {
                StartCoroutine(StartThird());
            }
        }
        if(bWaitSpace)
        {
            if(GoTuto[3].activeInHierarchy && Input.GetButtonDown("Jump"))
            {
                StartForth();
            }
            if(GoTuto[4].activeInHierarchy && Input.GetKeyDown(KeyCode.V))
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

    private void TutoKey()
    {
        if (scPlayer.bIsBaiting)
        {
            GameObject goInputs = goPlayer.transform.GetChild(4).gameObject;
            goInputs.transform.GetChild(0).gameObject.SetActive(false);
            goInputs.transform.GetChild(1).gameObject.SetActive(true);
        }
        else
        {
            GameObject goInputs = goPlayer.transform.GetChild(4).gameObject;
            goInputs.transform.GetChild(0).gameObject.SetActive(true);
            goInputs.transform.GetChild(1).gameObject.SetActive(false);
        }
    }
    private void TutoArrows()
    {
        if (scPlayer.UI_Joystick[3].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                //GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i].material = materials[0];
            }
            //GoTuto[0].transform.GetChild(0).gameObject.SetActive(true);
            render[0].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[0].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
               // GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i].material = materials[0];
            }
            //GoTuto[0].transform.GetChild(1).gameObject.SetActive(true);
            render[1].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[4].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                //GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i].material = materials[0];
            }
            //GoTuto[0].transform.GetChild(2).gameObject.SetActive(true);
            render[2].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[7].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                //GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i].material = materials[0];
            }
            //GoTuto[0].transform.GetChild(3).gameObject.SetActive(true);
            render[3].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[1].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                //GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i].material = materials[0];
            }
            //GoTuto[0].transform.GetChild(4).gameObject.SetActive(true);
            render[4].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[2].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                //GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i].material = materials[0];
            }
            //GoTuto[0].transform.GetChild(5).gameObject.SetActive(true);
            render[5].material = materials[1];
        }
        else
        {
            for (int i = 0; i < 6; i++)
            {
                //GoTuto[0].transform.GetChild(i).gameObject.SetActive(false);
                render[i].material = materials[0];
            }
        }
    }

    IEnumerator StartFirst()
    {
        yield return new WaitForSecondsRealtime(1f);
        GoTuto[0].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        GoTuto[0].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(0.5f);
        GoTuto[0].transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.6f);
        GoTuto[0].transform.GetChild(3).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.2f);
        GoTuto[0].transform.GetChild(4).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        GoTuto[0].gameObject.SetActive(false);
        yield return new WaitForSecondsRealtime(1f);
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(1.5f);
        GoTuto[1].transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSecondsRealtime(2f);
        GoTuto[1].transform.GetChild(0).gameObject.SetActive(false);
        b_tutoFinished = true;
        /*scPlayer.bGameIsPaused = false;
        scPlayer.PauseGame(); */
    }

    IEnumerator StartThird()
    {
        bOnce = true;
        GoTuto[1].SetActive(false);
        for (int i = 1; i < 3; i++)
        {
            goCameraMain[i].SetActive(true);
        }
        for (int i = 0; i < 2; i++)
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
        goCameraMain[0].transform.GetChild(2).gameObject.SetActive(true);
        GoTuto[3].SetActive(false);
        scPlayer.bGameIsPaused = false;
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
            scPlayer.bIsTuto = false;
            sc_tuto tutoriel = GameObject.FindWithTag("Tuto").gameObject.GetComponent<sc_tuto>();
            tutoriel.TutoScraffi();
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
