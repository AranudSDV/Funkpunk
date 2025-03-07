using Cinemachine;
using DG.Tweening;
using FMOD.Studio;
using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;

public class BPM_Manager : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    private SoundManager soundManager;

    //LE BEAT
    [Header("Beat")]
    public float FBPM;
    private float FBPS;
    public float FSPB;
    [SerializeField] private CinemachineFollowZoom FOVS;
    private bool b_more = false;
    private bool b_less = false;
    [SerializeField] private EventReference levelLoop;
    [SerializeField] private EventReference sfx_OkRythm;
    [SerializeField] private EventReference sfx_PerfectRythm;
    public FMOD.Studio.EventInstance playerLoopInstance;
    private bool isPlaying = false; // Prevent multiple starts

    //FEEDBACK ON TIMING
    [Header("Timing Feedbacks")]
    public Color32 colorMiss;
    public Color32 colorBad;
    public Color32 colorGood;
    public Color32 colorPerfect;
    public Color32 colorBase;
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
    public bool bPlayBad = false;
    public bool bPlayGood = false;
    public bool bPlayPerfect = false;
    [SerializeField] private UnityEngine.UI.Image soul_Feedback;
    [SerializeField] private RectTransform goNoteRight;
    [SerializeField] private RectTransform goNoteLeft;

    [SerializeField] private float fFOVmin = 10f;
    [SerializeField] private float fFOVmax = 10.6f;
    private bool bInitialized;

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
        soundManager = GetComponent<SoundManager>();
    }
    public void StartAfterTuto()
    {
        StartCoroutine(wait());
    }
    public void Init()
    {
        StartCoroutine(wait());
        if (playerLoopInstance.isValid())
        {
            playerLoopInstance.getPlaybackState(out PLAYBACK_STATE state);
            if (state != PLAYBACK_STATE.STOPPED) return; // Only create a new instance if it's actually stopped
        }

        // Create and start the instance
        playerLoopInstance = RuntimeManager.CreateInstance(levelLoop);
        playerLoopInstance.start();
        playerLoopInstance.setParameterByName("fPausedVolume", 0.8f);

        isPlaying = true;
    }
    private void Update()
    {
        if (!bInitialized)
        {
            Init();
            bInitialized = true;
        }
        CheckIfInputOnTempo();
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
        MusicNotesMovingStart();
        StartCoroutine(bad());
    }
    IEnumerator bad()
    {
        scPlayer.canMove = true;
        soul_Feedback.color = colorBase;
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
        BPerfect = false;
        scPlayer.canMove = false;
        if (BBad == false && BGood == false && BPerfect == false && scPlayer.bcanRotate == true)
        {
            if (!scPlayer.bIsImune)
            {
                scPlayer.fNbBeat += 1f;
            }
            soul_Feedback.color = colorMiss;
            bPlayBad = false;
            bPlayGood = false;
            bPlayPerfect = false;
            scPlayer.bHasNoMiss = false;
            if (!scPlayer.BisDetectedByAnyEnemy && SceneManager.GetActiveScene().name != "Loft")
            {
                scPlayer.FDetectionLevel += 2f;
            }
        }
        if (scPlayer.BisDetectedByAnyEnemy)
        {
            scPlayer.FDetectionLevel += 20f;
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
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 35f;
                    scPlayer.fNbBeat += 1f;
                }
                soul_Feedback.color = colorBad;
                bPlayBad = true;
                bPlayGood = false;
                bPlayPerfect = false;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 2f;
                }
                SoundManager.Instance.PlayOneShot(sfx_OkRythm);
            }
            else if (BGood == true)
            {
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 75f;
                    scPlayer.fNbBeat += 1f;
                }
                soul_Feedback.color = colorGood;
                bPlayBad = false;
                bPlayGood = true;
                bPlayPerfect = false;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 5f;
                }
                SoundManager.Instance.PlayOneShot(sfx_OkRythm);
            }
            else if (BPerfect == true)
            {
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 100f;
                    scPlayer.fNbBeat += 1f;
                }
                soul_Feedback.color = colorPerfect;
                bPlayBad = false;
                bPlayGood = false;
                bPlayPerfect = true;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 10f;
                }
               SoundManager.Instance.PlayOneShot(sfx_PerfectRythm);
            }
            scPlayer.bcanRotate = false;
        }
    }
    private void MusicNotesMovingStart()
    {
        goNoteRight.anchoredPosition = new Vector2(500f, 0f);
        goNoteLeft.anchoredPosition = new Vector2(-500f, 0f);
        goNoteRight.DOAnchorPos(Vector2.zero, FSPB, false).SetAutoKill(true);
        goNoteLeft.DOAnchorPos(Vector2.zero, FSPB, false).SetAutoKill(true);
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
    private void OnDestroy() // Clean up to prevent memory leaks
    {
        if (playerLoopInstance.isValid())
        {
            playerLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
            playerLoopInstance.release();
        }
    }
}
