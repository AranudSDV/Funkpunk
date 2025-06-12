using Cinemachine;
using DG.Tweening;
using FMOD;
using FMOD.Studio;
using FMODUnity;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text.RegularExpressions;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
//using static UnityEditor.ShaderGraph.Internal.KeywordDependentCollection;

public class BPM_Manager : SingletonManager<BPM_Manager>
{
    public bool bIsOnLvl = false;
    public bool bIsOnLoft = false;
    public SC_Player scPlayer;
    public MenuManager menuManager;
    public int iReplaying = 3;

    //LE BEAT
    [Header("Beat")]
    public float[] FBPM;
    [SerializeField] private float fDelayMusic = 0.1f;
    private float fTimer = 0f;
    //private float FBPS;
    public float FSPB;
    private bool b_more = false;
    private bool b_less = false;
    [SerializeField] private EventReference[] Loop;
    [SerializeField] private EventReference[] LoopDetected;
    [SerializeField] private EventReference[] LoopBeat;
    public FMOD.Studio.EventInstance basicLoopInstance;
    public FMOD.Studio.EventInstance detectedLoopInstance;
    public FMOD.Studio.EventInstance beatLoopInstance;
    public bool isPlaying = false; // Prevent multiple starts
    private int iNowNote = 0;
    private int i_B = 0;
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
    private Vector2 newPos;
    private DG.Tweening.Sequence[] sequences = new DG.Tweening.Sequence[3];
    private bool bInvisble = false; 
    private DG.Tweening.Sequence arrowSequence;

    public float fFOVmin = 10f;
    public float fFOVmax = 10.6f;
    private float fFovInstanceMax;
    public bool[] bInitialized = new bool[2] { false, false};

    private void Start()
    {
        FSPB = 1f / (FBPM[4] / 60f);
    }
    private IEnumerator WaitForPlayer()
    {
        yield return new WaitUntil(() => SC_Player.instance != null);
        scPlayer = SC_Player.instance;
        StartBPMPlayer();
        StartCoroutine(wait());
        BMiss = true;
    }
    public void StartBPMPlayer()
    {
        for (int i = 0; i<3; i++)
        {
            if(i == menuManager.iDifficulty)
            {
                for (int y = 0; y < 4; y++)
                {
                    fTolerence[y] = fAllTolerence[y+(4* menuManager.iDifficulty)];
                    FTiming[y] = fTolerence[y] / fFraction * FSPB;
                }
            }
        }
        scPlayer.posSeparator[0] = new Vector2((scPlayer.canvasRect.rect.width / 2f) * (fTolerence[0]/fFraction)- scPlayer.goSeparator[0].rect.width, 0f);
        scPlayer.posSeparator[1] = new Vector2((scPlayer.canvasRect.rect.width / 2f)*((fTolerence[0]+ fTolerence[1])/ fFraction) - scPlayer.goSeparator[0].rect.width, 0f);
        scPlayer.posSeparator[2] = new Vector2((scPlayer.canvasRect.rect.width / 2f) * ((fTolerence[0] + fTolerence[1]+ fTolerence[2])/ fFraction)- scPlayer.goSeparator[0].rect.width, 0f);
        scPlayer.goSeparator[0].anchoredPosition = scPlayer.posSeparator[0];
        scPlayer.goSeparator[1].anchoredPosition = scPlayer.posSeparator[1];
        scPlayer.goSeparator[2].anchoredPosition = scPlayer.posSeparator[2];
        scPlayer.goSeparator[3].anchoredPosition = -scPlayer.posSeparator[0];
        scPlayer.goSeparator[4].anchoredPosition = -scPlayer.posSeparator[1];
        scPlayer.goSeparator[5].anchoredPosition = -scPlayer.posSeparator[2];
        newPos = new Vector2(scPlayer.canvasRect.rect.width / 2f + scPlayer.goNoteLeft[0].rect.width / 2f, 0f);
    }
    public void StartAfterTuto()
    {
        StartCoroutine(wait());
    }
    public void Init(float f_Timer)
    {
        if (!bInitialized[1])
        {
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
            if (bIsOnLvl)
            {
                Shader.SetGlobalFloat("BPM", FBPM[menuManager.iPreviousLevelPlayed]);
                basicLoopInstance = RuntimeManager.CreateInstance(Loop[menuManager.iPreviousLevelPlayed]);
                basicLoopInstance.start();
                detectedLoopInstance = RuntimeManager.CreateInstance(LoopDetected[menuManager.iPreviousLevelPlayed]);
                detectedLoopInstance.start();
                beatLoopInstance = RuntimeManager.CreateInstance(LoopBeat[menuManager.iPreviousLevelPlayed]);
                beatLoopInstance.start();
                menuManager.SetMusicVolume();
            }
            else
            {
                Shader.SetGlobalFloat("BPM", FBPM[4]);
                basicLoopInstance = RuntimeManager.CreateInstance(Loop[4]);
                basicLoopInstance.start();
                detectedLoopInstance = RuntimeManager.CreateInstance(LoopDetected[4]);
                detectedLoopInstance.start();
                beatLoopInstance = RuntimeManager.CreateInstance(LoopBeat[4]);
                beatLoopInstance.start();
                menuManager.SetMusicVolume();
            }
            isPlaying = true; 
            if (bIsOnLvl || bIsOnLoft)
            {
                if(bIsOnLoft)
                {
                    FSPB = 1f / (FBPM[4] / 60f);
                }
                else
                {
                    FSPB = 1f / (FBPM[menuManager.iPreviousLevelPlayed] / 60f);
                }
                StartCoroutine(WaitForPlayer());
            }
            bInitialized[0] = true;
        }
        /*else if(bSimulateLvl3 || SceneManager.GetActiveScene().name == "SceneLvl3")
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

                menuManager.SetMusicVolume();

                isPlaying = true;
                bInitialized[0] = true;
            }
        }*/
        fFovInstanceMax = fFOVmax;
    }
    private void Update()
    {
        if (!bInitialized[0])
        {
            Init(Time.unscaledDeltaTime);
        }
        else if (coreSystem.hasHandle())
        {
            coreSystem.update();
        }
        if (bIsOnLvl || bIsOnLoft)
        {
            if (scPlayer != null && menuManager != null)
            {
                if (menuManager.bGameIsPaused)
                {
                    foreach (UnityEngine.UI.Image notesRight in scPlayer.imNoteRight)
                    {
                        notesRight.color = new Color32(255, 255, 255, 0);
                    }
                    foreach (UnityEngine.UI.Image notesLeft in scPlayer.imNoteLeft)
                    {
                        notesLeft.color = new Color32(255, 255, 255, 0);
                    }
                    bInvisble = true;
                }
                else if (!menuManager.bGameIsPaused && bInvisble)
                {
                    foreach (UnityEngine.UI.Image notesRight in scPlayer.imNoteRight)
                    {
                        notesRight.color = new Color32(255, 255, 255, 200);
                    }
                    foreach (UnityEngine.UI.Image notesLeft in scPlayer.imNoteLeft)
                    {
                        notesLeft.color = new Color32(255, 255, 255, 200);
                    }
                    bInvisble = false;
                }
            }
            if (scPlayer != null && menuManager != null && !menuManager.bGameIsPaused)
            {
                CheckIfInputOnTempo();
            }
            if(scPlayer != null)
            {
                CameraRythm(Time.unscaledDeltaTime, fFovInstanceMax, fFOVmin);
            }
        }
    }

    //LE TEMPO
    IEnumerator wait()
    {
        if(scPlayer!=null)
        {
            if (!menuManager.bGameIsPaused)
            {
                if (!scPlayer.bisTuto)
                {
                    scPlayer.bcanRotate = true;
                }
                scPlayer.RotationEnemies();
            }
            MusicNotesMovingStart();
        }
        yield return new WaitForSecondsRealtime(FTiming[3]);
        StartCoroutine(bad());
    }
    IEnumerator bad()
    {
        if (!menuManager.bGameIsPaused)
        {
            scPlayer.canMove = true;
        }
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
        if(scPlayer!=null)
        {
            if (!menuManager.bGameIsPaused)
            {
                scPlayer.canMove = false;
                if (BBad == false && BGood == false && BPerfect == false && scPlayer.bcanRotate == true) // LE JOUEUR MISS
                {
                    menuManager.fBeatMusicVolume = menuManager.fBeatVolume[0];
                    if (!scPlayer.bIsImune)
                    {
                        scPlayer.fNbBeat += 1f;
                        scPlayer.fScoreDetails[0] += 1f;
                    }
                    bPlayBad = false;
                    bPlayGood = false;
                    bPlayPerfect = false;
                    scPlayer.bHasNoMiss = false;
                    if (!scPlayer.BisDetectedByAnyEnemy && SceneManager.GetActiveScene().name != "Loft" && !scPlayer.bIsImune)
                    {
                        scPlayer.FDetectionLevel += 2f;
                    }
                    fFovInstanceMax = fFOVmax * (80f / 100f);
                    NotesFade();
                }
                if (scPlayer.BisDetectedByAnyEnemy && !scPlayer.bIsImune)
                {
                    scPlayer.FDetectionLevel += 20f;
                }
                if (scPlayer.bIsReplaying)
                {
                    iReplaying -= 1;
                    menuManager.progressBar.value = (iReplaying - 3) / 3;
                    if (iReplaying <= 0)
                    {
                        menuManager.CgLoadingScreen.alpha = 0f;
                        menuManager.RtLoadingScreen.anchorMin = new Vector2(0, 1);
                        menuManager.RtLoadingScreen.anchorMax = new Vector2(1, 2);
                        menuManager.RtLoadingScreen.offsetMax = new Vector2(0f, 0f);
                        menuManager.RtLoadingScreen.offsetMin = new Vector2(0f, 0f);
                        StartCoroutine(menuManager.ImuneToPause(this));
                        scPlayer.bIsReplaying = false;
                        iReplaying = 3;
                        menuManager.progressBar.value = (iReplaying - 3) / 3;
                    }
                }
                IsImuneCheck();
                scPlayer.EyeDetection();
                menuManager.SetMusicVolume();
            }
            else if (menuManager.bGameIsPaused && BBad == false && BGood == false && BPerfect == false)
            {
                NotesFade();
            }
        }
        StartCoroutine(wait());
    }
    private void IsImuneCheck()
    {
        if (scPlayer.bisTuto == false)
        {
            if (scPlayer.bIsImune)
            {
                scPlayer.CheckForward(Vector3.zero);
                iTimer -= 1;
                if (iTimer >= 0)
                {
                    scPlayer.textTimer.color = new Color32(255, 255, 255, 255);
                    scPlayer.textTimer.text = iTimer.ToString();
                }
                else
                {
                    scPlayer.textTimer.color = new Color32(255, 255, 255, 0);
                    scPlayer.bIsImune = false;
                }
            }
            else
            {
                if(bPlayBad || bPlayGood || bPlayPerfect)
                {
                    scPlayer.CheckForward(scPlayer.lastMoveDirection);
                }
                else
                {
                    scPlayer.CheckForward(Vector3.zero);
                }
                if (iTimer <= 0)
                {
                    scPlayer.textTimer.text = iTimer.ToString();
                    scPlayer.textTimer.color = new Color32(255, 255, 255, 0);
                    if (scPlayer.bIsImune == true)
                    {
                        scPlayer.bIsImune = false;
                    }
                }
                else
                {
                    iTimer -= 1;
                    scPlayer.textTimer.text = iTimer.ToString();
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
                    scPlayer.fScoreDetails[1] += 1f;
                }
                menuManager.fBeatMusicVolume = menuManager.fBeatVolume[1];
                bPlayBad = true;
                bPlayGood = false;
                bPlayPerfect = false;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 2f;
                }
                fFovInstanceMax = fFOVmax * (90f / 100f);
                StartCoroutine(VibrationVfx(0.05f, 0f,0.3f));
            }
            else if (BGood == true)
            {
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 75f;
                    scPlayer.fNbBeat += 1f;
                    scPlayer.fScoreDetails[2] += 1f;
                }
                menuManager.fBeatMusicVolume = menuManager.fBeatVolume[2];
                bPlayBad = false;
                bPlayGood = true;
                bPlayPerfect = false;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 5f;
                }
                fFovInstanceMax = fFOVmax * (95f / 100f);
                StartCoroutine(VibrationVfx(0.05f, 0.3f, 0.6f));
            }
            else if (BPerfect == true)
            {
                if (!scPlayer.bIsImune)
                {
                    scPlayer.FScore = scPlayer.FScore + 100f;
                    scPlayer.fNbBeat += 1f;
                    scPlayer.fScoreDetails[3] += 1f;
                }
                menuManager.fBeatMusicVolume = menuManager.fBeatVolume[3];
                bPlayBad = false;
                bPlayGood = false;
                bPlayPerfect = true;
                if (!scPlayer.BisDetectedByAnyEnemy)
                {
                    scPlayer.FDetectionLevel -= 10f;
                }
                fFovInstanceMax = fFOVmax;
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
        if(scPlayer != null)
        {
            CheckNearestNote();
            if (iNowNote == 0)
            {
                sequences[0].Kill();
                scPlayer.imNoteRight[0].color = new Color32(255, 255, 255, 0);
                scPlayer.imNoteLeft[0].color = new Color32(255, 255, 255, 0);
                scPlayer.goNoteRight[0].localScale = new Vector3(1f, 1f, 1f);
                scPlayer.goNoteLeft[0].localScale = new Vector3(1f, 1f, 1f);
            }
            else if (iNowNote == 1)
            {
                sequences[1].Kill();
                scPlayer.imNoteRight[1].color = new Color32(255, 255, 255, 0);
                scPlayer.imNoteLeft[1].color = new Color32(255, 255, 255, 0);
                scPlayer.goNoteRight[1].localScale = new Vector3(1f, 1f, 1f);
                scPlayer.goNoteLeft[1].localScale = new Vector3(1f, 1f, 1f);
            }
            else if (iNowNote == 2)
            {
                sequences[2].Kill();
                scPlayer.imNoteRight[2].color = new Color32(255, 255, 255, 0);
                scPlayer.imNoteLeft[2].color = new Color32(255, 255, 255, 0);
                scPlayer.goNoteRight[2].localScale = new Vector3(1f, 1f, 1f);
                scPlayer.goNoteLeft[2].localScale = new Vector3(1f, 1f, 1f);
            }
        }
    }
    private void CheckNearestNote()
    {
        if(scPlayer!=null)
        {
            float x = scPlayer.goNoteRight[0].anchoredPosition.x - scPlayer.goNoteRight[1].anchoredPosition.x;
            if (x > 0) //La note 1 est plus proche du centre que la 0
            {
                float x1 = scPlayer.goNoteRight[1].anchoredPosition.x - scPlayer.goNoteRight[2].anchoredPosition.x;
                if (x1 > 0) //la note 2 est plus proche du centre que la 1
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
                float x1 = scPlayer.goNoteRight[0].anchoredPosition.x - scPlayer.goNoteRight[2].anchoredPosition.x;
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
    }
    private void MusicNotesMovingStart()
    {
        float canvas = (FTiming[3]+ FTiming[0] )/ FSPB;
        if(scPlayer != null)
        {
            arrowSequence.Kill();
            arrowSequence = DOTween.Sequence().SetAutoKill(true);
            arrowSequence.Append(scPlayer.GoCanvasArrow.transform.DOScale(1.27f, 2f*FSPB/3f)
            .SetEase(Ease.OutCirc));
            arrowSequence.Append(scPlayer.GoCanvasArrow.transform.DOScale(0.79f, FSPB / 3f)
            .SetEase(Ease.InExpo));
        }
        if (i_B == 1)
        {
            scPlayer.goNoteRight[0].anchoredPosition = new Vector2(newPos.x * (1 + 3 * canvas)+ scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteRight[0].localScale = new Vector3(1f,1f,1f);
            scPlayer.goNoteLeft[0].anchoredPosition = new Vector2(-newPos.x * (1 + 3 * canvas)- scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteLeft[0].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.imNoteRight[0].color = new Color32(0, 197, 255, 255);
            scPlayer.imNoteLeft[0].color = new Color32(0, 197, 255, 255);
            sequences[0].Kill();
            sequences[0] = DOTween.Sequence();
            sequences[0].Append(scPlayer.goNoteRight[0].DOAnchorPos(new Vector2(scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 3)-(FSPB/7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteLeft[0].DOScale(1.5f, (FSPB * 3) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteRight[0].DOScale(1.5f, (FSPB * 3) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteLeft[0].DOAnchorPos(new Vector2(-scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 3) - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[0].Append(scPlayer.goNoteRight[0].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteLeft[0].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteLeft[0].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteRight[0].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            i_B = 2;
        }
        else if (i_B == 2)
        {
            scPlayer.goNoteRight[1].anchoredPosition = new Vector2(newPos.x * (1 + 3 * canvas)+ scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteLeft[1].anchoredPosition = new Vector2(-newPos.x * (1 + 3 * canvas) - scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteRight[1].localScale = new Vector3(1f, 1f, 1f);
           scPlayer.goNoteLeft[1].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.imNoteRight[1].color = new Color32(0, 197, 255, 255);
            scPlayer.imNoteLeft[1].color = new Color32(0, 197, 255, 255);
            sequences[1].Kill();
            sequences[1] = DOTween.Sequence();
            sequences[1].Append(scPlayer.goNoteRight[1].DOAnchorPos(new Vector2(scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 3) - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteLeft[1].DOScale(1.5f, (FSPB * 3) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteRight[1].DOScale(1.5f, (FSPB * 3) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteLeft[1].DOAnchorPos(new Vector2(-scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 3) - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[1].Append(scPlayer.goNoteRight[1].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteLeft[1].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteLeft[1].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteRight[1].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            i_B = 3;
        }
        else if (i_B == 3)
        {
            scPlayer.goNoteRight[2].anchoredPosition = new Vector2(newPos.x * (1 + 3 * canvas) + scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteLeft[2].anchoredPosition = new Vector2(-newPos.x * (1 + 3 * canvas) - scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteRight[2].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.goNoteLeft[2].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.imNoteRight[2].color = new Color32(0, 197, 255, 255);
            scPlayer.imNoteLeft[2].color = new Color32(0, 197, 255, 255);
            sequences[2].Kill();
            sequences[2] = DOTween.Sequence();
            sequences[2].Append(scPlayer.goNoteRight[2].DOAnchorPos(new Vector2(scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 3) - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteLeft[2].DOScale(1.5f, (FSPB * 3) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteRight[2].DOScale(1.5f, (FSPB * 3) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteLeft[2].DOAnchorPos(new Vector2(-scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 3) - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[2].Append(scPlayer.goNoteRight[2].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteLeft[2].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteLeft[2].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteRight[2].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            i_B = 1;
        }
        else
        {
            iNowNote = 0;
            scPlayer.goNoteRight[0].anchoredPosition = new Vector2(newPos.x * (1+ canvas)+ scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteLeft[0].anchoredPosition = new Vector2(-newPos.x * (1 + canvas)- scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteRight[0].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.goNoteLeft[0].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.imNoteRight[0].color = new Color32(0, 197, 255, 255);
            scPlayer.imNoteLeft[0].color = new Color32(0, 197, 255, 255);
            sequences[0].Kill();
            sequences[0] = DOTween.Sequence();
            sequences[0].Append(scPlayer.goNoteRight[0].DOAnchorPos(new Vector2(scPlayer.goNoteLeft[0].rect.width / 2f, 0f), FSPB - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteLeft[0].DOScale(1.5f,  FSPB- (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteRight[0].DOScale(1.5f, FSPB - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteLeft[0].DOAnchorPos(new Vector2(-scPlayer.goNoteLeft[0].rect.width / 2f, 0f), FSPB - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[0].Append(scPlayer.goNoteRight[0].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteLeft[0].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteLeft[0].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            sequences[0].Join(scPlayer.goNoteRight[0].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);

            scPlayer.goNoteRight[1].anchoredPosition = new Vector2(newPos.x * (1+2* canvas), 0f);
            scPlayer.goNoteLeft[1].anchoredPosition = new Vector2(-newPos.x * (1+2* canvas), 0f);
            scPlayer.goNoteRight[1].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.goNoteLeft[1].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.imNoteRight[1].color = new Color32(0, 197, 255, 255);
            scPlayer.imNoteLeft[1].color = new Color32(0, 197, 255, 255);
            sequences[1].Kill();
            sequences[1] = DOTween.Sequence();
            sequences[1].Append(scPlayer.goNoteRight[1].DOAnchorPos(new Vector2(scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 2) - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteLeft[1].DOScale(1.5f, (FSPB * 2) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteRight[1].DOScale(1.5f, (FSPB * 2) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteLeft[1].DOAnchorPos(new Vector2(-scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 2) - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[1].Append(scPlayer.goNoteRight[1].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteLeft[1].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteLeft[1].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            sequences[1].Join(scPlayer.goNoteRight[1].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);

            scPlayer.goNoteRight[2].anchoredPosition = new Vector2(newPos.x * (1+3*canvas)+ scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteLeft[2].anchoredPosition = new Vector2(-newPos.x * (1+3*canvas)- scPlayer.goNoteLeft[0].rect.width / 4f, 0f);
            scPlayer.goNoteRight[2].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.goNoteLeft[2].localScale = new Vector3(1f, 1f, 1f);
            scPlayer.imNoteRight[2].color = new Color32(0, 197, 255, 255);
            scPlayer.imNoteLeft[2].color = new Color32(0, 197, 255, 255);
            sequences[2].Kill();
            sequences[2] = DOTween.Sequence();
            sequences[2].Append(scPlayer.goNoteRight[2].DOAnchorPos(new Vector2(scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 3) - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteLeft[2].DOScale(1.5f, (FSPB * 3) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteRight[2].DOScale(1.5f, (FSPB * 3) - (FSPB / 7)).SetEase(Ease.InBack)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteLeft[2].DOAnchorPos(new Vector2(-scPlayer.goNoteLeft[0].rect.width / 2f, 0f), (FSPB * 3) - (FSPB / 7), false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[2].Append(scPlayer.goNoteRight[2].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteLeft[2].DOAnchorPos(Vector2.zero, FSPB / 7, false).SetEase(Ease.Linear)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteLeft[2].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            sequences[2].Join(scPlayer.goNoteRight[2].DOScale(0.1f, FSPB / 7).SetEase(Ease.InBack).SetAutoKill(true)).SetUpdate(true);
            i_B = 1;
        }
    }
    private void CameraRythm(float f_time, float f_max, float f_min)
    {
        float fov = scPlayer.FOVS.m_MinFOV;
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
            scPlayer.FOVS.m_Width = fov;
        }
        else if (b_more)
        {
            fov = Mathf.Lerp(f_min, f_max, f_time);
            scPlayer.FOVS.m_Width = fov;
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
        FBPM[Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value)] = FBPM[Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value)] * speedMultiplier;
        FSPB = 1f / (FBPM[Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value)] / 60f);
        StartBPMPlayer();
        Shader.SetGlobalFloat("BPM", FBPM[Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value)]);
    }
    //FEEDBACK
    public IEnumerator VibrationVfx(float time, float lowFreq, float highFreq)
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
