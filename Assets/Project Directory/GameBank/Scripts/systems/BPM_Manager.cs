using Cinemachine;
using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;

public class BPM_Manager : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    //LE BEAT
    [Header("Beat")]
    public float FBPM;
    private float FBPS;
    public float FSPB;
    [SerializeField] private CinemachineFollowZoom FOVS;
    private bool b_more = false;
    private bool b_less = false;
    [SerializeField] private EventReference playerLoop;
    public FMOD.Studio.EventInstance playerLoopInstance;

    //FEEDBACK ON TIMING
    [Header("Timing Feedbacks")]
    [SerializeField] private Color32 colorMiss;
    [SerializeField] private Color32 colorBad;
    [SerializeField] private Color32 colorGood;
    [SerializeField] private Color32 colorPerfect;
    private float FBadTiming;
    private float FZoneBadTiming;
    private float FGoodTiming;
    private float FZoneGoodTiming;
    private float FPerfectTiming;
    private float FZonePerfectTiming;
    private float FWaitTime;
    public bool BBad = false;
    public bool BGood = false;
    public bool BPerfect = false;
    public bool bBaitBad = false;
    public bool bBaitGood = false;
    public bool bBaitPerfect = false;
    [SerializeField] private TMP_Text txt_Feedback;
    public GameObject GOUiBad;
    public GameObject GOUiGood;
    public GameObject GOUiPerfect;

    [SerializeField] private float fFOVmin = 10f;
    [SerializeField] private float fFOVmax = 10.6f;

    private void Start()
    {
        //soundManager.PlayMusic("lvl0_Tambour");
        //FBPS = 60/FBPM;
        FBPS = FBPM / 60f;
        FSPB = 1f / FBPS;
        FPerfectTiming = 2 / 14f * FSPB;
        FGoodTiming = 4 / 14f * FSPB;
        FBadTiming = 6 / 14f * FSPB;
        FZoneBadTiming = FBadTiming;
        FZoneGoodTiming = FGoodTiming;
        FZonePerfectTiming = FPerfectTiming;
        FWaitTime = FSPB - FZoneBadTiming;
        StartCoroutine(wait());
        playerLoopInstance = RuntimeManager.CreateInstance(playerLoop);
        playerLoopInstance.start();
        playerLoopInstance.setParameterByName("fPausedVolume", 0.8f);
    }
    public void StartAfterTuto()
    {
        StartCoroutine(wait());
    }
    private void Update()
    {
        CheckIfInputOnTempo();
        Rythme();
        CameraRythm(Time.deltaTime, fFOVmax, fFOVmin);
    }

    //LE TEMPO
    IEnumerator wait()
    {
        if (!scPlayer.bisTuto)
        {
            scPlayer.bcanRotate = true;
        }
        scPlayer.RotationEnemies();
        yield return new WaitForSeconds(FWaitTime);
        StartCoroutine(bad());
    }
    IEnumerator bad()
    {
        scPlayer.canMove = true;
        txt_Feedback.text = "";
        txt_Feedback.color = new Color32(0, 0, 0, 0);
        BBad = true;
        yield return new WaitForSeconds(FZoneBadTiming);
        BBad = false;
        StartCoroutine(good());
        yield return new WaitForSeconds(FZoneGoodTiming + FZonePerfectTiming + FZoneGoodTiming);
    }
    IEnumerator good()
    {
        BGood = true;
        yield return new WaitForSeconds(FZoneGoodTiming);
        BGood = false;
        StartCoroutine(perfect());
        yield return new WaitForSeconds(FZonePerfectTiming);
    }
    IEnumerator perfect()
    {
        BPerfect = true;
        yield return new WaitForSeconds(FZonePerfectTiming);
        if (scPlayer.BisDetectedByAnyEnemy)
        {
            scPlayer.FDetectionLevel += scPlayer.fDetectionDangerosity;
        }
        BPerfect = false;
        scPlayer.canMove = false;
        if (BBad == false && BGood == false && BPerfect == false && scPlayer.bcanRotate == true)
        {
            txt_Feedback.text = "Miss";
            txt_Feedback.color = colorMiss;
            bBaitBad = false;
            bBaitGood = false;
            bBaitPerfect = false;
        }
        if (scPlayer.bisTuto == false)
        {
            scPlayer.CheckForward(scPlayer.lastMoveDirection, scPlayer.taggingRange);
        }
        StartCoroutine(wait());
    }
    private void CheckIfInputOnTempo()
    {
        if (scPlayer.bcanRotate && scPlayer.canMove && (((!scPlayer.bIsOnComputer || scPlayer.bOnControllerConstraint) && scPlayer.control.GamePlay.Move.triggered) || (scPlayer.bIsOnComputer && !scPlayer.bOnControllerConstraint && Input.GetButtonDown("Jump"))))
        {
            if (BBad == true)
            {
                scPlayer.FScore = scPlayer.FScore + 10f;
                txt_Feedback.text = "Bad";
                txt_Feedback.color = colorBad;
                bBaitBad = true;
                bBaitGood = false;
                bBaitPerfect = false;
            }
            else if (BGood == true)
            {
                scPlayer.FScore = scPlayer.FScore + 50f;
                txt_Feedback.text = "Good";
                txt_Feedback.color = colorGood;
                bBaitBad = false;
                bBaitGood = true;
                bBaitPerfect = false;
            }
            else if (BPerfect == true)
            {
                scPlayer.FScore = scPlayer.FScore + 100f;
                txt_Feedback.text = "Perfect!";
                txt_Feedback.color = colorPerfect;
                bBaitBad = false;
                bBaitGood = false;
                bBaitPerfect = true;
            }
            scPlayer.bcanRotate = false;
        }
    }
    private void Rythme()
    {
        if (BBad == true)
        {
            GOUiBad.SetActive(true);
        }
        if (BGood == true)
        {
            GOUiGood.SetActive(true);
        }
        if (BPerfect == true)
        {
            GOUiPerfect.SetActive(true);
        }
        if (BPerfect == false)
        {
            GOUiPerfect.SetActive(false);
        }
        if (BPerfect == false && BGood == false)
        {
            GOUiPerfect.SetActive(false);
            GOUiGood.SetActive(false);
        }
        if (BPerfect == false && BGood == false && BBad == false)
        {
            GOUiPerfect.SetActive(false);
            GOUiGood.SetActive(false);
            GOUiBad.SetActive(false);
        }
    }
    private void CameraRythm(float f_time, float f_max, float f_min)
    {
        float fov = FOVS.m_MinFOV;
        if (BPerfect == true)
        {
            b_more = true;
            b_less = false;
        }
        else if (BBad == true)
        {
            b_more = false;
            b_less = true;
        }
        if (b_less)
        {
            fov = Mathf.Lerp(f_max, f_min, -f_time);
            FOVS.m_Width = fov;
        }
        else if (b_more)
        {
            fov = Mathf.Lerp(f_min, f_max, f_time);
            FOVS.m_Width = fov;
        }
    }
}
