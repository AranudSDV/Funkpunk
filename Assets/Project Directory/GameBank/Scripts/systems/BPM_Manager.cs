using Cinemachine;
using DG.Tweening;
using FMOD;
using FMOD.Studio;
using FMODUnity;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class BPM_Manager : MonoBehaviour
{
    public bool bSimulateLvl3 = false;
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
    public CinemachineFollowZoom FOVS;
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
    // FMOD Studio system
    private FMOD.System coreSystem;
    // Our 3 sounds (programmer instrument style, streaming)
    private FMOD.Sound[] musicSounds = new FMOD.Sound[3];
    private FMOD.Channel[] musicChannels = new FMOD.Channel[3];
    private DSP[] pitchShifters = new DSP[3];
    private float[] baseFrequencies = new float[3];
    // Paths to your audio files (replace with your actual files)
    private string[] musicPaths = new string[3]
    {
        "Assets/StreamingAssets/FMOD/Music/music_lvl3_basic.ogg",
        "Assets/StreamingAssets/FMOD/Music/music_lvl3_beat.ogg",
        "Assets/StreamingAssets/FMOD/Music/music_lvl3_detected.ogg"
    };
    RESULT result;

    //FEEDBACK ON TIMING
    [Header("Timing Feedbacks")]
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
    [SerializeField] private RectTransform[] goSeparator;
    [SerializeField] private RectTransform[] goNoteRight;
    [SerializeField] private UnityEngine.UI.Image[] imNoteRight;
    [SerializeField] private RectTransform[] goNoteLeft;
    [SerializeField] private UnityEngine.UI.Image[] imNoteLeft;
    [SerializeField] private RectTransform canvasRect;
    private Vector2 newPos;
    private Vector2[] posSeparator = new Vector2[3];
    private DG.Tweening.Sequence[] sequences = new DG.Tweening.Sequence[3];
    private bool bInvisble = false;

    public float fFOVmin = 10f;
    public float fFOVmax = 10.6f;
    private float fFovInstanceMax;
    private bool[] bInitialized = new bool[2] { false, false};

    private void Start()
    {
        FSPB = 1f / (FBPM / 60f);
    }
    public void StartBPM()
    {
        for (int i = 0; i<3; i++)
        {
            if(i == scPlayer.menuManager.iDifficulty)
            {
                for (int y = 0; y < 4; y++)
                {
                    fTolerence[y] = fAllTolerence[y+(4* scPlayer.menuManager.iDifficulty)];
                    UnityEngine.Debug.Log(y + (4 * scPlayer.menuManager.iDifficulty));
                    UnityEngine.Debug.Log(scPlayer.menuManager.iDifficulty);
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
        if(SceneManager.GetActiveScene().name != "SceneLvl3" && !bSimulateLvl3)
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
                Shader.SetGlobalFloat("BPM", FBPM);
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
        else if(bSimulateLvl3 || SceneManager.GetActiveScene().name == "SceneLvl3")
        {
            if (!bInitialized[1])
            {
                StartBPM();
                StartCoroutine(wait());
                BMiss = true;
                Shader.SetGlobalFloat("BPM", FBPM);
                bInitialized[1] = true;
                coreSystem = RuntimeManager.CoreSystem; 
            }
            fTimer += f_Timer;
            if (fTimer >= fDelayMusic)
            {
                for (int i = 0; i < 3; i++)
                {
                    // Create streaming sound (non-blocking recommended for music)
                    result = coreSystem.createSound(musicPaths[i], MODE.CREATESTREAM, out musicSounds[i]);
                    if (result != RESULT.OK)
                    {
                        UnityEngine.Debug.LogError($"Failed to create sound {musicPaths[i]}: {result}");
                        continue;
                    }

                    // Play sound and get channel
                    result  = coreSystem.playSound(musicSounds[i], default(ChannelGroup), false, out musicChannels[i]);
                    if (result != RESULT.OK)
                    {
                        UnityEngine.Debug.LogError($"Failed to play sound {musicPaths[i]}: {result}");
                        continue;
                    }

                    // Get and store base frequency
                    musicChannels[i].getFrequency(out baseFrequencies[i]);

                    // Create and attach pitch shifter DSP
                    coreSystem.createDSPByType(DSP_TYPE.PITCHSHIFT, out pitchShifters[i]);
                    musicChannels[i].addDSP(0, pitchShifters[i]);

                    // Initialize pitch shifter to zero (no shift)
                    pitchShifters[i].setParameterFloat((int)DSP_PITCHSHIFT.PITCH, 0f);
                }

                scPlayer.menuManager.SetMusicVolume();

                isPlaying = true;
                bInitialized[0] = true;
            }
        }
        fFovInstanceMax = fFOVmax;
    }
    private void Update()
    {
        if (!bInitialized[0])
        {
            Init(Time.unscaledDeltaTime);
        }
        else if(coreSystem.hasHandle())
        {
            coreSystem.update();
        }
        if (scPlayer != null && scPlayer.menuManager != null)
        {
            if(scPlayer.menuManager.bGameIsPaused)
            {
                foreach (UnityEngine.UI.Image notesRight in imNoteRight)
                {
                    notesRight.color = new Color32(255,255,255,0);
                }
                foreach(UnityEngine.UI.Image notesLeft in imNoteLeft)
                {
                    notesLeft.color = new Color32(255, 255, 255, 0);
                }
                bInvisble = true;
            }
            else if(!scPlayer.menuManager.bGameIsPaused && bInvisble)
            {
                foreach (UnityEngine.UI.Image notesRight in imNoteRight)
                {
                    notesRight.color = new Color32(255, 255, 255, 200);
                }
                foreach (UnityEngine.UI.Image notesLeft in imNoteLeft)
                {
                    notesLeft.color = new Color32(255, 255, 255, 200);
                }
                bInvisble = false;
            }
        }
        if(scPlayer!=null&&scPlayer.menuManager!=null&&!scPlayer.menuManager.bGameIsPaused)
        {
            CheckIfInputOnTempo();
        }
        CameraRythm(Time.unscaledDeltaTime, fFovInstanceMax, fFOVmin);
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
        yield return new WaitForSecondsRealtime(FTiming[3]);
        StartCoroutine(bad());
    }
    IEnumerator bad()
    {
        scPlayer.canMove = true;
        BBad = true;
        yield return new WaitForSecondsRealtime(FTiming[2]);
        BBad = false;
        StartCoroutine(good());
    }
    IEnumerator good()
    {
        BGood = true;
        yield return new WaitForSecondsRealtime(FTiming[1]);
        BGood = false;
        StartCoroutine(perfect());
    }
    IEnumerator perfect()
    {
        BPerfect = true;
        yield return new WaitForSecondsRealtime(FTiming[0]);
        BPerfect = false;
        scPlayer.canMove = false;
        if (BBad == false && BGood == false && BPerfect == false && scPlayer.bcanRotate == true) // LE JOUEUR MISS
        {
            scPlayer.menuManager.fBeatMusicVolume = scPlayer.menuManager.fBeatVolume[0];
            if (!scPlayer.bIsImune)
            {
                scPlayer.fNbBeat += 1f;
            }
            bPlayBad = false;
            bPlayGood = false;
            bPlayPerfect = false;
            scPlayer.bHasNoMiss = false;
            if (!scPlayer.BisDetectedByAnyEnemy && SceneManager.GetActiveScene().name != "Loft" && !scPlayer.bIsImune)
            {
                scPlayer.FDetectionLevel += 2f;
            }
            fFovInstanceMax = fFOVmax *(80f/100f);
            NotesFade();
            scPlayer.fJudmgentToJump = 0.3f;
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
                    textTimer.text = iTimer.ToString();
                    textTimer.color = new Color32(255, 255, 255, 0);
                    if (scPlayer.bIsImune == true)
                    {
                        scPlayer.bIsImune = false;
                    }
                }
                else
                {
                    iTimer -= 1;
                    textTimer.text = iTimer.ToString();
                    scPlayer.bIsImune = true;
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
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 35f;
                    scPlayer.fNbBeat += 1f;
                }
                scPlayer.menuManager.fBeatMusicVolume = scPlayer.menuManager.fBeatVolume[1];
                bPlayBad = true;
                bPlayGood = false;
                bPlayPerfect = false;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 2f;
                }
                fFovInstanceMax = fFOVmax * (90f / 100f);
                scPlayer.fJudmgentToJump = 0.6f;
                StartCoroutine(VibrationVfx(0.05f, 0f,0.3f));
            }
            else if (BGood == true)
            {
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 75f;
                    scPlayer.fNbBeat += 1f;
                }
                scPlayer.menuManager.fBeatMusicVolume = scPlayer.menuManager.fBeatVolume[2];
                bPlayBad = false;
                bPlayGood = true;
                bPlayPerfect = false;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 5f;
                }
                fFovInstanceMax = fFOVmax * (95f / 100f);
                scPlayer.fJudmgentToJump = 0.9f;
                StartCoroutine(VibrationVfx(0.05f, 0.3f, 0.6f));
            }
            else if (BPerfect == true)
            {
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 100f;
                    scPlayer.fNbBeat += 1f;
                }
                scPlayer.menuManager.fBeatMusicVolume = scPlayer.menuManager.fBeatVolume[3];
                bPlayBad = false;
                bPlayGood = false;
                bPlayPerfect = true;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 10f;
                }
                fFovInstanceMax = fFOVmax;
                scPlayer.fJudmgentToJump = 1.2f;
                StartCoroutine(VibrationVfx(0.05f, 0.6f, 1f));
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
            sequences[0].Kill();
            sequences[0] = DOTween.Sequence();
            sequences[0].Append(goNoteRight[0].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
            sequences[0].Join(goNoteLeft[0].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
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
            sequences[1].Kill();
            sequences[1] = DOTween.Sequence();
            sequences[1].Append(goNoteRight[1].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB *3, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
            sequences[1].Join(goNoteLeft[1].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
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
            sequences[2].Kill();
            sequences[2] = DOTween.Sequence();
            sequences[2].Append(goNoteRight[2].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
            sequences[2].Join(goNoteLeft[2].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
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
            sequences[0].Kill();
            sequences[0] = DOTween.Sequence();
            sequences[0].Append(goNoteRight[0].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
            sequences[0].Join(goNoteLeft[0].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
            /*sequences[0].OnComplete(() =>
            {
                imNoteRight[0].color = new Color32(255, 255, 255, 0);
                imNoteLeft[0].color = new Color32(255, 255, 255, 0);
                iNowNote = 1;
            });*/

            goNoteRight[1].anchoredPosition = new Vector2(newPos.x * (1+2* canvas), 0f);
            goNoteLeft[1].anchoredPosition = new Vector2(-newPos.x * (1+2* canvas), 0f);
            sequences[1].Kill();
            sequences[1] = DOTween.Sequence();
            sequences[1].Append(goNoteRight[1].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB * 2, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
            sequences[1].Join(goNoteLeft[1].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 2, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
            /*sequences[1].OnComplete(() =>
            {
                imNoteRight[1].color = new Color32(255, 255, 255, 0);
                imNoteLeft[1].color = new Color32(255, 255, 255, 0);
                iNowNote = 2;
            });*/

            goNoteRight[2].anchoredPosition = new Vector2(newPos.x * (1+canvas), 0f);
            goNoteLeft[2].anchoredPosition = new Vector2(-newPos.x * (1+canvas), 0f);
            sequences[2].Kill();
            sequences[2] = DOTween.Sequence();
            sequences[2].Append(goNoteRight[2].DOAnchorPos(new Vector2(goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
            sequences[2].Join(goNoteLeft[2].DOAnchorPos(new Vector2(-goNoteLeft[0].rect.width / 4f, 0f), FSPB * 3, false).SetEase(Ease.Linear).SetAutoKill(true)).SetUpdate(true);
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
    public void SetSpeed(float speedMultiplier)
    {
        if (speedMultiplier <= 0f)
        {
            UnityEngine.Debug.LogWarning("Speed multiplier must be > 0");
            return;
        }

        for (int i = 0; i < 3; i++)
        {
            // Change playback frequency for speed
            float newFreq = baseFrequencies[i] * speedMultiplier;
            musicChannels[i].setFrequency(newFreq);

            // Calculate pitch shift in octaves to preserve pitch
            float pitchShiftInOctaves = (float)(-Mathf.Log(speedMultiplier, 2));
            pitchShifters[i].setParameterFloat((int)DSP_PITCHSHIFT.PITCH, pitchShiftInOctaves);
        }
        FBPM = FBPM * speedMultiplier;
        FSPB = 1f / (FBPM / 60f);
        StartBPM();
        Shader.SetGlobalFloat("BPM", FBPM);

    }
    //FEEDBACK
    private IEnumerator VibrationVfx(float time, float lowFreq, float highFreq)
    {
        Gamepad gamepad = Gamepad.current;
        if (gamepad != null)
        {
            gamepad.SetMotorSpeeds(lowFreq, highFreq);
            yield return new WaitForSeconds(time);
            gamepad.SetMotorSpeeds(0, 0); // stop vibration
        }
        else
        {
            UnityEngine.Debug.LogWarning("No gamepad connected");
        }
    }
    private void OnDestroy() // Clean up to prevent memory leaks
    {
        for (int i = 0; i < 3; i++)
        {
            if (musicChannels[i].hasHandle())
                musicChannels[i].stop();

            if (musicSounds[i].hasHandle())
                musicSounds[i].release();

            if (pitchShifters[i].hasHandle())
            {
                pitchShifters[i].release();
                pitchShifters[i].clearHandle();
            }
        }
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
