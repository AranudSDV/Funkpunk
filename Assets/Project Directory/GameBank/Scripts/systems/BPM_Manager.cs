using Cinemachine;
using DG.Tweening;
using FMOD.Studio;
using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UIElements;

public class BPM_Manager : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    private SoundManager soundManager;
    public int iReplaying = 3;

    //LE BEAT
    [Header("Beat")]
    public float FBPM;
    [SerializeField] private float fDelayMusic = 0.1f;
    private float fTimer = 0f;
    //private float FBPS;
    public float FSPB;
    [SerializeField] private CinemachineFollowZoom FOVS;
    private bool b_more = false;
    private bool b_less = false;
    [SerializeField] private EventReference levelLoop;
    [SerializeField] private EventReference levelLoopDetected;
    [SerializeField] private EventReference levelLoopBeat;
    public FMOD.Studio.EventInstance basicLoopInstance;
    public FMOD.Studio.EventInstance detectedLoopInstance;
    public FMOD.Studio.EventInstance beatLoopInstance;
    private bool isPlaying = false; // Prevent multiple starts
    private bool b_hasStarted = false;
    private int iNowNote = 0;
    private int i_B = 0;
    public TextMeshProUGUI textTimer;
    public int iTimer = 3;

    //FEEDBACK ON TIMING
    [Header("Timing Feedbacks")]
    [Tooltip("0 est compliqué, 1 est normal, 2 est facile")] public int iDifficulty = 0;
    [Tooltip("Fraction de tolerence, perfect/good/bad/miss. D'abord compliqué, puis normal, puis facile")] public float[] fAllTolerence = new float[12] { 2f, 4f, 6f, 2f, 4f, 6f, 3f, 1f, 5f, 7f, 2f, 0f};
    [Tooltip("Fraction de tolerence, d'abord perfect, puis good, puis bad, puis miss")]public float[] fTolerence = new float[4] { 2f, 4f, 6f, 2f};
    [Tooltip("sur combien")][SerializeField] private float fFraction = 14f;
    public Color32 colorMiss;
    public Color32 colorBad;
    public Color32 colorGood;
    public Color32 colorPerfect;
    public Color32 colorBase;
    private float[] FTiming = new float[4];
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
    private Vector2[] posSeparator = new Vector2[3];
    private DG.Tweening.Sequence[] sequences = new DG.Tweening.Sequence[3];

    [SerializeField] private float fFOVmin = 10f;
    [SerializeField] private float fFOVmax = 10.6f;
    private bool[] bInitialized = new bool[2] { false, false};

    private void Start()
    {
        FSPB = 1f / (FBPM / 60f);
    }
    public void StartBPM()
    {
        for (int i = 0; i<3; i++)
        {
            if(i == Mathf.RoundToInt(iDifficulty))
            {
                for (int y = 0; y < 4; y++)
                {
                    fTolerence[y] = fAllTolerence[y+4* iDifficulty];
                    FTiming[y] = fTolerence[y] / fFraction * FSPB;
                }
            }
        }
        posSeparator[0] = new Vector2((canvasRect.rect.width / 2f) * (fTolerence[0]/fFraction)- goSeparator[0].rect.width, 0f);
        posSeparator[1] = new Vector2((canvasRect.rect.width / 2f)*((fTolerence[0]+ fTolerence[1])/ fFraction) - goSeparator[0].rect.width, 0f);
        posSeparator[2] = new Vector2((canvasRect.rect.width / 2f) * ((fTolerence[0] + fTolerence[1]+ fTolerence[2])/ fFraction)- goSeparator[0].rect.width, 0f);
        goSeparator[0].anchoredPosition = posSeparator[0];
        goSeparator[1].anchoredPosition = posSeparator[1];
        goSeparator[2].anchoredPosition = posSeparator[2];
        goSeparator[3].anchoredPosition = -posSeparator[0];
        goSeparator[4].anchoredPosition = -posSeparator[1];
        goSeparator[5].anchoredPosition = -posSeparator[2];
        if(soundManager == null)
        {
            soundManager = this.GetComponent<SoundManager>();
        }
        newPos = new Vector2(canvasRect.rect.width / 2f + goNoteLeft[0].rect.width / 2f, 0f);
    }
    public void StartAfterTuto()
    {
        StartCoroutine(wait());
    }
    public void Init(float f_Timer)
    {
        if (!bInitialized[1])
        {
            StartBPM();
            StartCoroutine(wait());
            BMiss = true;
            if (basicLoopInstance.isValid())
            {
                basicLoopInstance.getPlaybackState(out PLAYBACK_STATE state);
                if (state != PLAYBACK_STATE.STOPPED) return; 
            }
            bInitialized[1] = true;
        }
        fTimer += f_Timer;
        if (fTimer >= fDelayMusic)
        {
            basicLoopInstance = RuntimeManager.CreateInstance(levelLoop);
            basicLoopInstance.start();

            detectedLoopInstance = RuntimeManager.CreateInstance(levelLoopDetected);
            detectedLoopInstance.start();

            beatLoopInstance = RuntimeManager.CreateInstance(levelLoopBeat);
            beatLoopInstance.start();

            scPlayer.menuManager.SetMusicVolume();

            isPlaying = true;
            bInitialized[0] = true;
        }
    }
    private void Update()
    {
        if (!bInitialized[0])
        {
            Init(Time.unscaledDeltaTime);
        }
        if (scPlayer != null && scPlayer.menuManager != null)
        {
            iDifficulty = scPlayer.menuManager.iDifficulty;
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
        MusicNotesMovingStart();
        yield return new WaitForSeconds(FTiming[3]);
        StartCoroutine(bad());
    }
    IEnumerator bad()
    {
        scPlayer.canMove = true;
        soul_Feedback.color = colorBase;
        BBad = true;
        yield return new WaitForSeconds(FTiming[2]);
        BBad = false;
        StartCoroutine(good());
    }
    IEnumerator good()
    {
        BGood = true;
        yield return new WaitForSeconds(FTiming[1]);
        BGood = false;
        StartCoroutine(perfect());
    }
    IEnumerator perfect()
    {
        BPerfect = true;
        yield return new WaitForSeconds(FTiming[0]);
        BPerfect = false;
        scPlayer.canMove = false;
        if (BBad == false && BGood == false && BPerfect == false && scPlayer.bcanRotate == true) // LE JOUEUR MISS
        {
            scPlayer.menuManager.fBeatMusicVolume = scPlayer.menuManager.fBeatVolume[0];
            if (!scPlayer.bIsImune)
            {
                scPlayer.fNbBeat += 1f;
            }
            soul_Feedback.color = colorMiss;
            bPlayBad = false;
            bPlayGood = false;
            bPlayPerfect = false;
            scPlayer.bHasNoMiss = false;
            if (!scPlayer.BisDetectedByAnyEnemy && SceneManager.GetActiveScene().name != "Loft" && !scPlayer.bIsImune)
            {
                scPlayer.FDetectionLevel += 2f;
            }
            NotesFade();
        }
        /*else if(BBad == false && BGood == false && BPerfect == false && !scPlayer.bcanRotate && scPlayer.bisTuto)
        {
            NotesFade();
        }*/
        if (scPlayer.BisDetectedByAnyEnemy &&!scPlayer.bIsImune)
        {
            scPlayer.FDetectionLevel += 20f;
        }
        if(scPlayer.bIsReplaying)
        {
            iReplaying -= 1;
            scPlayer.menuManager.progressBar.value = (iReplaying-3) / 3;
            if (iReplaying<=0)
            {
                scPlayer.menuManager.CgLoadingScreen.alpha = 0f;
                scPlayer.menuManager.RtLoadingScreen.anchorMin = new Vector2(0, 1);
                scPlayer.menuManager.RtLoadingScreen.anchorMax = new Vector2(1, 2);
                scPlayer.menuManager.RtLoadingScreen.offsetMax = new Vector2(0f, 0f);
                scPlayer.menuManager.RtLoadingScreen.offsetMin = new Vector2(0f, 0f);
                StartCoroutine(scPlayer.menuManager.ImuneToPause(this));
                scPlayer.bIsReplaying = false;
                iReplaying = 3;
                scPlayer.menuManager.progressBar.value = (iReplaying - 3) / 3;
            }
        }
        IsImuneCheck();
        scPlayer.EyeDetection();
        scPlayer.menuManager.SetMusicVolume();
        StartCoroutine(wait());
    }
    private void IsImuneCheck()
    {
        if (scPlayer.bisTuto == false)
        {
            if (scPlayer.bIsImune)
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
                    scPlayer.bIsImune = false;
                }
            }
            else
            {
                scPlayer.CheckForward(scPlayer.lastMoveDirection, scPlayer.taggingRange);
                if (iTimer <= 0)
                {
                    textTimer.color = new Color32(255, 255, 255, 0);
                    if (scPlayer.bIsImune == true)
                    {
                        scPlayer.bIsImune = false;
                    }
                }
            }
        }
    }
    private void CheckIfInputOnTempo()
    {
        if (scPlayer.bcanRotate && scPlayer.canMove && scPlayer.bHasController && scPlayer.control.GamePlay.Move.triggered)
        {
            if (BBad == true)
            {
                Debug.Log("bad");
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 35f;
                    scPlayer.fNbBeat += 1f;
                }
                scPlayer.menuManager.fBeatMusicVolume = scPlayer.menuManager.fBeatVolume[1];
                soul_Feedback.color = colorBad;
                bPlayBad = true;
                bPlayGood = false;
                bPlayPerfect = false;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 2f;
                }
            }
            else if (BGood == true)
            {
                Debug.Log("good");
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 75f;
                    scPlayer.fNbBeat += 1f;
                }
                scPlayer.menuManager.fBeatMusicVolume = scPlayer.menuManager.fBeatVolume[2];
                soul_Feedback.color = colorGood;
                bPlayBad = false;
                bPlayGood = true;
                bPlayPerfect = false;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 5f;
                }
            }
            else if (BPerfect == true)
            {
                Debug.Log("perfect");
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 100f;
                    scPlayer.fNbBeat += 1f;
                }
                scPlayer.menuManager.fBeatMusicVolume = scPlayer.menuManager.fBeatVolume[3];
                soul_Feedback.color = colorPerfect;
                bPlayBad = false;
                bPlayGood = false;
                bPlayPerfect = true;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 10f;
                }
            }
            NotesFade();
            scPlayer.bcanRotate = false;
        }
        /*else if (!scPlayer.bcanRotate && scPlayer.bisTuto && scPlayer.canMove && scPlayer.bHasController && scPlayer.control.GamePlay.Move.triggered)
        {
            NotesFade();
        }*/
    }
    private void NotesFade()
    {
        CheckNearestNote();
        if (iNowNote ==0)
        {
            sequences[0].Kill();
            imNoteRight[0].color = new Color32(255, 255, 255, 0);
            imNoteLeft[0].color = new Color32(255, 255, 255, 0);
        }
        else if (iNowNote == 1)
        {
            sequences[1].Kill();
            imNoteRight[1].color = new Color32(255, 255, 255, 0);
            imNoteLeft[1].color = new Color32(255, 255, 255, 0);
        }
        else if (iNowNote == 2)
        {
            sequences[2].Kill();
            imNoteRight[2].color = new Color32(255, 255, 255, 0);
            imNoteLeft[2].color = new Color32(255, 255, 255, 0);
        }
    }
    private void CheckNearestNote()
    {
       float x = goNoteRight[0].anchoredPosition.x - goNoteRight[1].anchoredPosition.x;
        if (x > 0) //La note 1 est plus proche du centre que la 0
        {
            float x1 = goNoteRight[1].anchoredPosition.x - goNoteRight[2].anchoredPosition.x;
            if(x1>0) //la note 2 est plus proche du centre que la 1
            {
                iNowNote = 2;
            }
            else
            {
                iNowNote = 1;
            }
        }
        else //la note 0 est plus proche du centre que la 1
        {
            float x1 = goNoteRight[0].anchoredPosition.x - goNoteRight[2].anchoredPosition.x;
            if (x1 > 0) //la note 2 est plus proche du centre que la 0
            {
                iNowNote = 2;
            }
            else
            {
                iNowNote = 0;
            }
        }
    }
    private void MusicNotesMovingStart()
    {
        float canvas = (FTiming[3]+ FTiming[0] )/ FSPB;
        if (i_B == 1)
        {
            goNoteRight[0].anchoredPosition = new Vector2(newPos.x * (1 + 3 * canvas), 0f);
            goNoteLeft[0].anchoredPosition = new Vector2(-newPos.x * (1 + 3 * canvas), 0f);
            imNoteRight[0].color = new Color32(0, 197, 255, 255);
            imNoteLeft[0].color = new Color32(0, 197, 255, 255);
            sequences[0] = DOTween.Sequence();
            sequences[0].Append(goNoteRight[0].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true));
            sequences[0].Join(goNoteLeft[0].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true));
            /*sequences[0].OnComplete(() =>
            {
                imNoteRight[0].color = new Color32(255, 255, 255, 0);
                imNoteLeft[0].color = new Color32(255, 255, 255, 0);
                iNowNote = 1;
            });*/
            i_B = 2;
        }
        else if (i_B == 2)
        {
            goNoteRight[1].anchoredPosition = new Vector2(newPos.x * (1 + 3 * canvas), 0f);
            goNoteLeft[1].anchoredPosition = new Vector2(-newPos.x * (1 + 3 * canvas), 0f);
            imNoteRight[1].color = new Color32(0, 197, 255, 255);
            imNoteLeft[1].color = new Color32(0, 197, 255, 255);
            sequences[1] = DOTween.Sequence();
            sequences[1].Append(goNoteRight[1].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB *3, false).SetEase(Ease.Linear).SetAutoKill(true));
            sequences[1].Join(goNoteLeft[1].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true));
            /*sequences[1].OnComplete(() =>
            {
                imNoteRight[1].color = new Color32(255, 255, 255, 0);
                imNoteLeft[1].color = new Color32(255, 255, 255, 0);
                iNowNote = 2;
            });*/
            i_B = 3;
        }
        else if (i_B == 3)
        {
            goNoteRight[2].anchoredPosition = new Vector2(newPos.x * (1 + 3 * canvas), 0f);
            goNoteLeft[2].anchoredPosition = new Vector2(-newPos.x * (1 + 3 * canvas), 0f);
            imNoteRight[2].color = new Color32(0, 197, 255, 255);
            imNoteLeft[2].color = new Color32(0, 197, 255, 255);
            sequences[2] = DOTween.Sequence();
            sequences[2].Append(goNoteRight[2].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true));
            sequences[2].Join(goNoteLeft[2].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true));
            /*sequences[2].OnComplete(() =>
            {
                imNoteRight[2].color = new Color32(255, 255, 255, 0);
                imNoteLeft[2].color = new Color32(255, 255, 255, 0);
                iNowNote = 0;
            });*/
            i_B = 1;
        }
        else
        {
            iNowNote = 0;
            goNoteRight[0].anchoredPosition = new Vector2(newPos.x * (1+ canvas), 0f);
            goNoteLeft[0].anchoredPosition = new Vector2(-newPos.x * (1 + canvas), 0f);
            sequences[0] = DOTween.Sequence();
            sequences[0].Append(goNoteRight[0].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB, false).SetEase(Ease.Linear).SetAutoKill(true));
            sequences[0].Join(goNoteLeft[0].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB, false).SetEase(Ease.Linear).SetAutoKill(true));
            /*sequences[0].OnComplete(() =>
            {
                imNoteRight[0].color = new Color32(255, 255, 255, 0);
                imNoteLeft[0].color = new Color32(255, 255, 255, 0);
                iNowNote = 1;
            });*/

            goNoteRight[1].anchoredPosition = new Vector2(newPos.x * (1+2* canvas), 0f);
            goNoteLeft[1].anchoredPosition = new Vector2(-newPos.x * (1+2* canvas), 0f);
            sequences[1] = DOTween.Sequence();
            sequences[1].Append(goNoteRight[1].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB * 2, false).SetEase(Ease.Linear).SetAutoKill(true));
            sequences[1].Join(goNoteLeft[1].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 2, false).SetEase(Ease.Linear).SetAutoKill(true));
            /*sequences[1].OnComplete(() =>
            {
                imNoteRight[1].color = new Color32(255, 255, 255, 0);
                imNoteLeft[1].color = new Color32(255, 255, 255, 0);
                iNowNote = 2;
            });*/

            goNoteRight[2].anchoredPosition = new Vector2(newPos.x * (1+canvas), 0f);
            goNoteLeft[2].anchoredPosition = new Vector2(-newPos.x * (1+canvas), 0f);
            sequences[2] = DOTween.Sequence();
            sequences[2].Append(goNoteRight[2].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true));
            sequences[2].Join(goNoteLeft[2].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true));
            /*sequences[2].OnComplete(() =>
            {
                imNoteRight[2].color = new Color32(255, 255, 255, 0);
                imNoteLeft[2].color = new Color32(255, 255, 255, 0);
                iNowNote = 0;
            });*/
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
        if (basicLoopInstance.isValid())
        {
            basicLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
            basicLoopInstance.release();
        }
        if(detectedLoopInstance.isValid())
        {
            detectedLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
            detectedLoopInstance.release();
        }
        if (beatLoopInstance.isValid())
        {
            beatLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
            beatLoopInstance.release();
        }
        DOTween.KillAll();
    }
}
