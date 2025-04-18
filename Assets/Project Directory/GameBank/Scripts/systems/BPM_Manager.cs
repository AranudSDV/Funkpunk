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
    //private float FBPS;
    public float FSPB;
    [SerializeField] private CinemachineFollowZoom FOVS;
    private bool b_more = false;
    private bool b_less = false;
    [SerializeField] private EventReference levelLoop;
    [SerializeField] private EventReference sfx_MissRythm;
    [SerializeField] private EventReference sfx_BadRythm;
    [SerializeField] private EventReference sfx_OkRythm;
    [SerializeField] private EventReference sfx_PerfectRythm;
    public FMOD.Studio.EventInstance playerLoopInstance;
    private bool isPlaying = false; // Prevent multiple starts
    private bool b_hasStarted = false;
    private int i_B = 0;
    [SerializeField] private TextMeshProUGUI textTimer;
    public int iTimer = 3;

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
    public bool BMiss = false;
    public bool BBad = false;
    public bool BGood = false;
    public bool BPerfect = false;
    public bool bPlayBad = false;
    public bool bPlayGood = false;
    public bool bPlayPerfect = false;
    private bool bMusicOnce = false;
    private double fMusicTimer = 0f;
    private double[] fNextReach = new double[4];
    [SerializeField] private UnityEngine.UI.Image soul_Feedback;
    [SerializeField] private RectTransform[] goSeparator;
    [SerializeField] private RectTransform[] goNoteRight;
    [SerializeField] private UnityEngine.UI.Image[] imNoteRight;
    [SerializeField] private RectTransform[] goNoteLeft;
    [SerializeField] private UnityEngine.UI.Image[] imNoteLeft;
    [SerializeField] private RectTransform canvasRect;
    private Vector2 newPos;
    private Vector2[] posSeparator = new Vector2[2];

    [SerializeField] private float fFOVmin = 10f;
    [SerializeField] private float fFOVmax = 10.6f;
    private bool bInitialized;

    private void Start()
    {
        //soundManager.PlayMusic("lvl0_Tambour");
        //FBPS = 60/FBPM;
        //FBPS = FBPM / 60f;
        FSPB = 1f / (FBPM / 60f);
        FPerfectTiming = 2 / 14f * FSPB;
        FGoodTiming = 4 / 14f * FSPB;
        FBadTiming = 6 / 14f * FSPB;
        FZoneBadTiming = FBadTiming;
        FZoneGoodTiming = FGoodTiming;
        FZonePerfectTiming = FPerfectTiming;
        FWaitTime = FZonePerfectTiming;
        posSeparator[0] = new Vector2((canvasRect.rect.width / 2f)*4/14f, 0f);
        posSeparator[1] = new Vector2((canvasRect.rect.width / 2f) * 8 / 14f, 0f);
        goSeparator[0].anchoredPosition = posSeparator[0];
        goSeparator[1].anchoredPosition = posSeparator[1];
        goSeparator[2].anchoredPosition = -posSeparator[0];
        goSeparator[3].anchoredPosition = -posSeparator[1];
        //fNextReach[0] = AudioSettings.dspTime + FWaitTime;
        soundManager = GetComponent<SoundManager>();
        newPos = new Vector2(canvasRect.rect.width / 2f + goNoteLeft[0].rect.width / 2f, 0f);
    }
    public void StartAfterTuto()
    {
        StartCoroutine(wait());
    }
    public void Init()
    {
        StartCoroutine(wait());
        BMiss = true;
        if (playerLoopInstance.isValid())
        {
            playerLoopInstance.getPlaybackState(out PLAYBACK_STATE state);
            if (state != PLAYBACK_STATE.STOPPED) return; // Only create a new instance if it's actually stopped
        }

        // Create and start the instance
        playerLoopInstance = RuntimeManager.CreateInstance(levelLoop);
        playerLoopInstance.start();

        isPlaying = true;
    }
    private void Update()
    {
        if (!bInitialized)
        {
            Init();
            bInitialized = true;
        }
        /*if(BMiss)
        {
            if(!bMusicOnce)
            {
                if (!scPlayer.bisTuto)
                {
                    scPlayer.bcanRotate = true;
                }
                scPlayer.RotationEnemies();
                MusicNotesMovingStart();
                bMusicOnce = true;
            }
            fMusicTimer
        }*/
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
        MusicNotesMovingStart();
        yield return new WaitForSeconds(FWaitTime);
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
    }
    IEnumerator good()
    {
        BGood = true;
        yield return new WaitForSeconds(FZoneGoodTiming);
        BGood = false;
        StartCoroutine(perfect());
    }
    IEnumerator perfect()
    {
        BPerfect = true;
        yield return new WaitForSeconds(FZonePerfectTiming);
        //NotesFade();
        //yield return new WaitForSeconds(FZonePerfectTiming/2);
        BPerfect = false;
        scPlayer.canMove = false;
        if (BBad == false && BGood == false && BPerfect == false && scPlayer.bcanRotate == true) // LE JOUEUR MISS
        {
            if (!scPlayer.bIsImune)
            {
                scPlayer.fNbBeat += 1f;
                SoundManager.Instance.PlayOneShot(sfx_MissRythm, this.transform.position);
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
            NotesFade();
        }
        if (scPlayer.BisDetectedByAnyEnemy)
        {
            scPlayer.FDetectionLevel += 20f;
        }
        if (scPlayer.bisTuto == false)
        {
            if(scPlayer.bIsImune)
            {
                scPlayer.CheckForward(Vector3.zero, scPlayer.taggingRange);
                iTimer -= 1;
                if (iTimer >= 0)
                {
                    textTimer.color = new Color32(255, 255, 255, 255);
                    textTimer.text = iTimer.ToString();
                }
                else
                {
                    textTimer.color = new Color32(255, 255, 255, 0);
                }
            }
            else
            {
                scPlayer.CheckForward(scPlayer.lastMoveDirection, scPlayer.taggingRange);
                if (iTimer <= 0)
                {
                    textTimer.color = new Color32(255, 255, 255, 0);
                }
            }
        }
        scPlayer.EyeDetection();
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
                    SoundManager.Instance.PlayOneShot(sfx_BadRythm, this.transform.position);
                }
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
                    SoundManager.Instance.PlayOneShot(sfx_OkRythm, this.transform.position);
                }
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
                    SoundManager.Instance.PlayOneShot(sfx_PerfectRythm, this.transform.position);
                }
            }
            NotesFade();
            scPlayer.bcanRotate = false;
        }
    }
    private void NotesFade()
    {
        if (i_B == 0 || i_B == 3)
        {
            imNoteRight[0].color = new Color32(0, 197, 255, 0);
            imNoteLeft[0].color = new Color32(0, 197, 255, 0);
        }
        else if (i_B == 1)
        {
            imNoteRight[1].color = new Color32(0, 197, 255, 0);
            imNoteLeft[1].color = new Color32(0, 197, 255, 0);
        }
        else if (i_B == 2)
        {
            imNoteRight[2].color = new Color32(0, 197, 255, 0);
            imNoteLeft[2].color = new Color32(0, 197, 255, 0);
        }
    }
    private void MusicNotesMovingStart()
    {
        if (i_B == 1)
        {
            goNoteRight[0].anchoredPosition = new Vector2(newPos.x, 0f);
            goNoteLeft[0].anchoredPosition = new Vector2(-newPos.x, 0f);
            goNoteRight[0].DOAnchorPos(Vector2.zero, (FSPB *9/14)* 3, false).SetEase(Ease.InSine).SetAutoKill(true);
            goNoteLeft[0].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14) * 3, false).SetEase(Ease.InSine).SetAutoKill(true);
            imNoteRight[0].color = new Color32(0, 197, 255, 255);
            imNoteLeft[0].color = new Color32(0, 197, 255, 255);
            i_B = 2;
        }
        else if(i_B == 2)
        {
            goNoteRight[1].anchoredPosition = new Vector2(newPos.x, 0f);
            goNoteLeft[1].anchoredPosition = new Vector2(-newPos.x, 0f);
            goNoteRight[1].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14) * 3, false).SetEase(Ease.InSine).SetAutoKill(true);
            goNoteLeft[1].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14) * 3, false).SetEase(Ease.InSine).SetAutoKill(true);
            imNoteRight[1].color = new Color32(0, 197, 255, 255);
            imNoteLeft[1].color = new Color32(0, 197, 255, 255);
            i_B = 3;
        }
        else if(i_B ==3)
        {
            goNoteRight[2].anchoredPosition = new Vector2(newPos.x, 0f);
            goNoteLeft[2].anchoredPosition = new Vector2(-newPos.x, 0f);
            goNoteRight[2].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14) * 3, false).SetEase(Ease.InSine).SetAutoKill(true);
            goNoteLeft[2].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14) * 3, false).SetEase(Ease.InSine).SetAutoKill(true);
            imNoteRight[2].color = new Color32(0, 197, 255, 255);
            imNoteLeft[2].color = new Color32(0, 197, 255, 255);
            i_B = 1;
        }

        if (!b_hasStarted)
        {
            goNoteRight[0].anchoredPosition = new Vector2(newPos.x, 0f);
            goNoteLeft[0].anchoredPosition = new Vector2(-newPos.x, 0f);
            goNoteRight[0].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14), false).SetEase(Ease.InSine).SetAutoKill(true);
            goNoteLeft[0].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14), false).SetEase(Ease.InSine).SetAutoKill(true);

            goNoteRight[1].anchoredPosition = new Vector2(newPos.x, 0f);
            goNoteLeft[1].anchoredPosition = new Vector2(-newPos.x, 0f);
            goNoteRight[1].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14) * 2, false).SetEase(Ease.InSine).SetAutoKill(true);
            goNoteLeft[1].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14) * 2, false).SetEase(Ease.InSine).SetAutoKill(true);

            goNoteRight[2].anchoredPosition = new Vector2(newPos.x, 0f);
            goNoteLeft[2].anchoredPosition = new Vector2(-newPos.x, 0f);
            goNoteRight[2].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14) * 3, false).SetEase(Ease.InSine).SetAutoKill(true);
            goNoteLeft[2].DOAnchorPos(Vector2.zero, (FSPB * 9 / 14) * 3, false).SetEase(Ease.InSine).SetAutoKill(true);
            b_hasStarted = true;
            i_B = 1;
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
    private void OnDestroy() // Clean up to prevent memory leaks
    {
        if (playerLoopInstance.isValid())
        {
            playerLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
            playerLoopInstance.release();
        }
    }
}
