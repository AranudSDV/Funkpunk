using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class sc_tuto : MonoBehaviour
{
     private GameObject GoFirst;
    private bool b_tutoFinished = false;
    private Image img;
    private SC_Player scPlayer;
    [Tooltip("0 is toLeft, 1 is toUp, 2 is toRight, 3 is toRightDown, 4 is toRightUp, 5 is toLeftUp")][SerializeField] private GameObject[] fo_arrow = new GameObject[6];
    [SerializeField] private Material[] materials = new Material[2];
    private MeshRenderer[] renderer = new MeshRenderer[6];
    private GameObject goPlayer;
    [SerializeField]private bool isMeshable = false;

    private void Start()
    {
        goPlayer = GameObject.FindWithTag("Player");
        scPlayer = goPlayer.GetComponent<SC_Player>();
        GoFirst = this.transform.GetChild(0).gameObject;
        if (isMeshable)
        {
            GoFirst.gameObject.SetActive(true);
            for (int i = 0; i < 6; i++)
            {
                GoFirst.transform.GetChild(i).gameObject.SetActive(false);
                renderer[i] = fo_arrow[i].GetComponent<MeshRenderer>();
            }
            GoFirst.transform.GetChild(5).gameObject.SetActive(true);
            StartCoroutine(StartFirst());
        }
    }

    private void Update()
    {
        if(b_tutoFinished == false && Input.GetKey(KeyCode.T) && isMeshable==false)
        {
            GoFirst.gameObject.SetActive(false);
            b_tutoFinished = true;
        }
        else if(b_tutoFinished == true && isMeshable ==false)
        {
            GoFirst.gameObject.SetActive(false);
            TutoArrows();
            TutoKey();
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
                GoFirst.transform.GetChild(i).gameObject.SetActive(false);
                renderer[i].material = materials[0];
            }
            GoFirst.transform.GetChild(0).gameObject.SetActive(true);
            renderer[0].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[0].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                GoFirst.transform.GetChild(i).gameObject.SetActive(false);
                renderer[i].material = materials[0];
            }
            GoFirst.transform.GetChild(1).gameObject.SetActive(true);
            renderer[1].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[4].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                GoFirst.transform.GetChild(i).gameObject.SetActive(false);
                renderer[i].material = materials[0];
            }
            GoFirst.transform.GetChild(2).gameObject.SetActive(true);
            renderer[2].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[7].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                GoFirst.transform.GetChild(i).gameObject.SetActive(false);
                renderer[i].material = materials[0];
            }
            GoFirst.transform.GetChild(3).gameObject.SetActive(true);
            renderer[3].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[1].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                GoFirst.transform.GetChild(i).gameObject.SetActive(false);
                renderer[i].material = materials[0];
            }
            GoFirst.transform.GetChild(4).gameObject.SetActive(true);
            renderer[4].material = materials[1];
        }
        else if (scPlayer.UI_Joystick[2].activeInHierarchy) //0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG
        {
            for (int i = 0; i < 6; i++)
            {
                GoFirst.transform.GetChild(i).gameObject.SetActive(false);
                renderer[i].material = materials[0];
            }
            GoFirst.transform.GetChild(5).gameObject.SetActive(true);
            renderer[5].material = materials[1];
        }
        else
        {
            for (int i = 0; i < 6; i++)
            {
                GoFirst.transform.GetChild(i).gameObject.SetActive(false);
                renderer[i].material = materials[0];
            }
        }
    }

    IEnumerator StartFirst()
    {
        yield return new WaitForSeconds(1f);
        GoFirst.transform.GetChild(0).gameObject.SetActive(true);
        yield return new WaitForSeconds(1.2f);
        GoFirst.transform.GetChild(1).gameObject.SetActive(true);
        yield return new WaitForSeconds(1.5f);
        GoFirst.transform.GetChild(2).gameObject.SetActive(true);
        yield return new WaitForSeconds(0.5f);
        GoFirst.transform.GetChild(3).gameObject.SetActive(true);
        yield return new WaitForSeconds(1.6f);
        GoFirst.transform.GetChild(4).gameObject.SetActive(true);
        yield return new WaitForSeconds(1f);
        GoFirst.transform.GetChild(5).gameObject.SetActive(false);
        b_tutoFinished = true;
    }

    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player") && isMeshable)
        {
            scPlayer = collision.GetComponent<SC_Player>();
            scPlayer.bIsTuto = false;
        }
    }
}
