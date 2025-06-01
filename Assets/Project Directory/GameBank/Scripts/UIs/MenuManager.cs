using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using Unity.VisualScripting;
using TMPro;
using static MenuManager;
using UnityEngine.EventSystems;
using FMODUnity;
using UnityEngine.LowLevel;
using FMOD.Studio;

public class MenuManager : SingletonManager<MenuManager>
{
    public EventSystem EventSystem;
    public SC_Player scPlayer;
    public bool bGameIsPaused = false;
    private sc_levelChoosing_ _scLevels;
    public int iPreviousLevelPlayed = 0;
    public bool bIsOnTestScene = false;

    //NAVIGATION UX
    [Header("Controller")]
    public PlayerControl control;
    public bool controllerConnected = false;
    private bool bWaitController = false;
    public CanvasGroup CgControllerWarning;
    public RectTransform RtControllerWarning;

    //NAVIGATION UX
    [Header("PauseMenu")]
    [SerializeField] private GameObject GoPauseMenu;
    public CanvasGroup CgPauseMenu;
    [SerializeField] private RectTransform RtPauseMenu;
    private bool bActif = false;
    [SerializeField] private GameObject GoPausedFirstButtonSelected;
    [SerializeField] private UnityEngine.UI.Button[] buttonsPausePannel;
    [SerializeField] private UnityEngine.UI.Image[] imagesButtonPausePannel;


    //NAVIGATION UX
    [Header("Options General")]
    [SerializeField] private GameObject GoOptionGeneralFirstButtonSelected;
    [SerializeField] private UnityEngine.UI.Selectable ButtonOptionGeneral;
    [SerializeField] private UnityEngine.UI.Button[] ButtonsOptionGeneral_fromGeneral;
    [SerializeField] private UnityEngine.UI.Button[] ButtonsOptionAudio_fromGeneral;
    [SerializeField] private GameObject GoOptionAudioButton;
    [SerializeField] private UnityEngine.UI.Selectable ButtonOptionAudio;
    [SerializeField] private UnityEngine.UI.Button[] ButtonsOptionGeneral_fromAudio;
    [SerializeField] private UnityEngine.UI.Button[] ButtonsOptionAudio_fromAudio;
    [SerializeField] private UnityEngine.UI.Slider[] SliderOptionAudio = new UnityEngine.UI.Slider[3];
    [SerializeField] private UnityEngine.UI.Button[] ButtonOptionGeneral_ = new UnityEngine.UI.Button[2];
    [SerializeField] private UnityEngine.UI.Image[] ImageSliderHandlerAudio = new UnityEngine.UI.Image[3];
    [SerializeField] private UnityEngine.UI.Image[] ImageButtonGeneral = new UnityEngine.UI.Image[2];
    [Tooltip("first language english, french, then difficulty hard to easy")][SerializeField] private Material[] M_materialButtonGeneral;
    public CanvasGroup CgOptionPannel;
    public RectTransform RtOptionPannel;
    public CanvasGroup CgOptionGeneral;
    public int iDifficulty = 0;
    [SerializeField] private EventReference[] sfx_ui_button;
    private bool[] bNowSelectedGeneral = new bool[2] { false, false };
    private bool[] bNowSelectedAudio = new bool[3] { false, false, false };
    private int iSelectedGeneral = -1;
    private int iSelectedAudio = -1;
    public bool bOnceGrid = false;
    private bool[] bOnceOptions = new bool[3] { false, false, false };

    [Header("Sound")]
    public FMOD.Studio.VCA music_basic_VCA;
    public FMOD.Studio.VCA music_detected_VCA;
    public FMOD.Studio.VCA music_beat_VCA;
    public FMOD.Studio.VCA sfxVCA;
    public FMOD.Studio.VCA ambianceVCA;
    public float playerMusicVolume = 1f;
    public float fDetectedVolume = 0f;
    public float fBeatMusicVolume = 0.7f;
    public float[] fBeatVolume = new float[4] {0.7f, 0.8f, 0.9f,1f };
    public CanvasGroup CgOptionAudio;
    [SerializeField] private UnityEngine.UI.Slider SfxSlider;
    [SerializeField] private UnityEngine.UI.Slider MusicSlider;
    [SerializeField] private UnityEngine.UI.Slider AmbianceSlider;
    [SerializeField] private EventReference menuLoop;
    [SerializeField] private EventReference menuLoopDetected;
    [SerializeField] private EventReference menuLoopBeat;
    public FMOD.Studio.EventInstance basicLoopInstance;
    public FMOD.Studio.EventInstance detectedLoopInstance;
    public FMOD.Studio.EventInstance beatLoopInstance;

    //NAVIGATION UX
    [Header("Navigation UX")]
    [SerializeField] private GameObject[] GoGameChoose = new GameObject[5];
    public GameObject[] GoLevelsButton;
    private GameObject GoLevelBackButton;
    public GameObject[] GoLevelStars;
    public Sprite sprite_star_completed;
    public Sprite sprite_star_empty;
    [SerializeField] private Sprite spriteLevel_done;
    [SerializeField] private Sprite spriteLevel_notDone;
    [SerializeField] private Material m_buttonLevel;
    [SerializeField] private Color32 colorFoes;
    [SerializeField] private Color32 colorPlayer;
    public GameObject GoScoringFirstButtonSelected;
    private bool bMenuOnTriggered = false;
    [SerializeField] private SplineTrainMover_WithSpacing trainMenu = null;
    private bool bWaitTrain = false;
    private bool bTrainIsHere = false;

    //END DIALOGUE
    [Header("EndGame")]
    public TMP_Text textBravo;

    //SCORING
    [Header("Scoring")]
    public TMP_Text txt_Title;
    public CanvasGroup CgScoring;
    public RectTransform RtScoring;
    public TMP_Text txtScoringJudgment;
    public TMP_Text txtScoringScore;
    public UnityEngine.UI.Image ImgScoringBackground;
    public Sprite[] spritesScoringBackground;
    public GameObject GoScoringSuccess;
    public CanvasGroup CgScoringSuccess;
    public RectTransform RtScoringSuccess;
    public GameObject GoScoringButtons;
    public RectTransform RtScoringButtons;

    //END DIALOGUE
    [Header("EndDialogue")]
    public CanvasGroup CgEndDialogue;
    public RectTransform RtEndDialogue;
    public UnityEngine.UI.Image ImgEndDialogueBackground;
    [Tooltip("int from the chara to be on the right, then on the left, for each levels, 0 is Jett, 1 is Scraffi, 2 is Scravinsky, 3 is Screonardo")][SerializeField] private int[] iWhichCharaToRightToLeft;
    public Sprite[] spritesEndDialogueBackground;
    [Tooltip("0 is Jett (*3, basic, thinking, suprised), 1 is Scraffi (*3, basic, explaining, surprised), 2 is Scravinsky (*2), 3 is Screonardo (*2)")] public Sprite[] spritesEndDialogueCharacters;
    [Tooltip("0 is Jett (*3, basic, thinking, suprised), 1 is Scraffi (*3, basic, explaining, surprised), 2 is Scravinsky (*2), 3 is Screonardo (*2)")] public Sprite[] spritesEndDialogueCharactersNotSpeak;
    [Tooltip("0 is right, 1 is left.")][SerializeField] private UnityEngine.UI.Image[] imgCharactersSpace;
    public bool bIsOnEndDialogue = false;

    [Header("EndDialogueDetails")]
    private int iNbTextNow = 0;
    [Tooltip("0 is right, 1 is left.")][SerializeField] private RectTransform[] charactersImages;
    [SerializeField] private RectTransform rectBoxTextImage;
    [SerializeField] private UnityEngine.UI.Image imgBoxText;
    [Tooltip("0 is the 1st Jeff,  1 is Scraffi, 2 is Scravinsky, 3 is Screonardo.")][SerializeField] private Sprite[] spritesCharactersBoxesRight;
    [Tooltip("0 is the 1st Jeff,  1 is Scraffi,2 is Scravinsky, 3 is Screonardo.")][SerializeField] private Sprite[] spritesCharactersBoxesLeft;
    [SerializeField] private sc_textChange _sc_textChange;
    [SerializeField] private int[] iNbDialoguePerLevel;
    [SerializeField] private int[] iNbDialoguePerLevelAdd;
    [Tooltip("see int character and emotions, 0 to 2 for 0 | 3 to 5 for 1 | 6 to 7 for 2 | 8 to 9 for 3")] public int[] iCharaToSpeakPerTextes;
    [Tooltip("see int character and emotions, 0 to 2 for 0 | 3 to 5 for 1 | 6 to 7 for 2 | 8 to 9 for 3")] public int[] iCharaToNotSpeakPerTextes;
    [SerializeField] private string[] sDialogueEnglish;
    [SerializeField] private string[] sDialogueFrench;
    public bool bWaitNextDialogue = false;
    private int iLevelDialogue;

    //SCENE LOADING
    [Header("Loading Scene")]
    public string sSceneToLoad;
    public static bool isLoadingScene = false;
    public UnityEngine.UI.Slider progressBar;
    [SerializeField] private GameObject loadingScreen;
    public CanvasGroup CgLoadingScreen;
    public RectTransform RtLoadingScreen;
    private AsyncOperation loadingOperation;

    //DATA PLAYER
    [Header("Datas")]
    public PlayerData _playerData;
    public Level[] _levels;
    private bool isPlaying = false; // Prevent multiple starts
    //DATA LEVEL
    public int[] iNbTaggs = new int[4];
    static int Hasard(int a, int b) //Choisi un random.
    {
        System.Random rdm = new System.Random();
        int hasard = rdm.Next(a, b + 1); //Aller jusqu'a le b inclu.
        return hasard;
    }
    [System.Serializable]
    public class Level 
    {
        public int i_level;
        public UnityEngine.UI.Button button_level;
        public GameObject Go_LevelButton;
        public string sScene_Level;
        public UnityEngine.UI.Image img_lvl;

        public Level(int i_nb, GameObject[]Go_buttons)
        {
            i_level = i_nb;
            Go_LevelButton = Go_buttons[i_nb];
            button_level = Go_buttons[i_nb].GetComponent<UnityEngine.UI.Button>();
            sScene_Level = "SceneLvl" + i_level;
            img_lvl = Go_buttons[i_nb].GetComponent<UnityEngine.UI.Image>();
        }
    }
    private void OnEnable()
    {
        OnEnableController();
    }
    private void OnEnableController()
    {
        if (controllerConnected)
        {
            control = new PlayerControl();
            control.GamePlay.Enable();
        }
    }
    void OnDisable()
    {
        if (controllerConnected && control!=null)
        {
            control.GamePlay.Disable();
        }
    }
    private void Awake()
    {
        CheckControllerStatus();
        LoadTargetUIMenus(); 
        if (instance != null && instance != this)
        {
            Debug.LogWarning("Duplicate MenuManager found. Destroying this one.");
            Destroy(this.gameObject);
            return;
        }
        instance = this;
        DontDestroyOnLoad(gameObject);
        //control = new PlayerControl();
        //EventSystem = GameObject.FindObjectOfType<EventSystem>();
        isLoadingScene = false;
    }
    private void Start()
    {
        UnityEngine.Cursor.lockState = CursorLockMode.Locked;
        music_basic_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_basic");
        music_beat_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_beat");
        music_detected_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_detected");
        sfxVCA = FMODUnity.RuntimeManager.GetVCA("vca:/SFX");
        ambianceVCA = FMODUnity.RuntimeManager.GetVCA("vca:/Ambiance"); 
        if (basicLoopInstance.isValid())
        {
            basicLoopInstance.getPlaybackState(out PLAYBACK_STATE state);
            if (state != PLAYBACK_STATE.STOPPED) return;
        }
        basicLoopInstance = RuntimeManager.CreateInstance(menuLoop);
        basicLoopInstance.start();

        detectedLoopInstance = RuntimeManager.CreateInstance(menuLoopDetected);
        detectedLoopInstance.start();

        beatLoopInstance = RuntimeManager.CreateInstance(menuLoopBeat);
        beatLoopInstance.start();
        isPlaying = true;

        SetMusicVolume();
        SetSFXVolume();
    }
    // Update is called once per frame
    void Update()
    {
        CheckControllerStatus();
        if (!bMenuOnTriggered && controllerConnected && control !=null && control.GamePlay.Move.triggered && SceneManager.GetActiveScene().name == "SceneSplash")
        {
            bMenuOnTriggered = true;
            if (GoGameChoose[4] == null)
            {
                Debug.Log("null");
            }
            GoGameChoose[4].transform.GetComponent<UnityEngine.UI.Image>().color = new Color32(255, 255, 255, 0);
            TrainAndUION();
            //LoadScene(sSceneToLoad);
        }
        if(bWaitTrain && bMenuOnTriggered)
        {
            TrainAndUION();
        }
        UXNavigation();
        if (isLoadingScene)
        {
            progressBar.value = Mathf.Clamp01(loadingOperation.progress / 0.9f);
        }
        else if((scPlayer !=null && !scPlayer.bIsReplaying) || scPlayer == null)
        {
            progressBar.value = 0f;
        }
        //Racourcis
        if(Input.GetKeyDown(KeyCode.J))
        {
            Debug.Log("passer le niveau");
            _playerData.iLevelPlayer += 1;
            _playerData.iScorePerLvlPlayer[_playerData.iLevelPlayer-1] = 70;
        }
    }
    //CHECKS AND UI CHANGES
    private void TrainAndUION()
    {
        if (trainMenu.progress[0] > 0.52f) //le train est déjà passé
        {
            trainMenu.progress[0] = 1f;
            trainMenu.progress[1] = 1f;
            trainMenu.pauseTimer[0] = trainMenu.pauseDuration;
            trainMenu.pauseTimer[1] = trainMenu.pauseDuration;
            bWaitTrain = true;
            bTrainIsHere = false;
        }
        else if(trainMenu.progress[0] < 0.5f) //le train va passer
        {
            bWaitTrain = true;
            bTrainIsHere = false;
        }
        else if(trainMenu.progress[0] > 0.51f && trainMenu.progress[0] < 0.519f)//le train passe
        {
            bWaitTrain = false;
            bTrainIsHere = true;
        }
        if(bTrainIsHere)
        {
            UnityEngine.UI.Button btnNewLoad = GoGameChoose[0].GetComponent<UnityEngine.UI.Button>();
            TrainSplashLanguage();
            GoGameChoose[3].transform.GetComponent<CanvasGroup>().alpha = 1f;
            bWaitTrain = false;
            bTrainIsHere = false;
            SelectionEnsurance();
        }
    }
    private void TrainSplashLanguage()
    {
        if (_playerData.iLevelPlayer > 0)
        {
            TextMeshProUGUI txt = GoGameChoose[0].transform.GetChild(0).gameObject.GetComponent<TextMeshProUGUI>();
            if (_playerData.iLanguageNbPlayer == 1)
            {
                txt.text = "Continuer";
            }
            else
            {
                txt.text = "Continue";
            }
        }
        else
        {
            TextMeshProUGUI txt = GoGameChoose[0].transform.GetChild(0).gameObject.GetComponent<TextMeshProUGUI>();
            if (_playerData.iLanguageNbPlayer == 1)
            {
                txt.text = "Nouvelle Partie";
            }
            else
            {
                txt.text = "New Game";
            }
        }
    }
    private void CheckCurrentSelectable()
    {
        if (CgPauseMenu.alpha == 1f)
        {
            for (int i = 0; i < buttonsPausePannel.Length; i++)
            {
                if (EventSystem.currentSelectedGameObject == buttonsPausePannel[i])
                {
                    imagesButtonPausePannel[i].material.SetFloat("NoColorsWhiteValue", 1f);
                }
                if (EventSystem.currentSelectedGameObject != buttonsPausePannel[i])
                {
                    imagesButtonPausePannel[i].material.SetFloat("NoColorsWhiteValue", 0.5f);
                }
            }
        }
        else if (CgOptionAudio.alpha == 1f)
        {
            for (int i = 0; i < 3; i++)
            {
                if (EventSystem.currentSelectedGameObject == SliderOptionAudio[i] && !bNowSelectedAudio[i])
                {
                    bNowSelectedAudio[i] = true;
                    if (iSelectedAudio > -1)
                    {
                        bNowSelectedAudio[iSelectedAudio] = false;
                        iSelectedAudio = i;
                    }
                    else
                    {
                        iSelectedAudio = i;
                    }
                    ImageSliderHandlerAudio[iSelectedAudio].material.SetFloat("NoColorsWhiteValue", 1f);
                }
                else
                {
                    ImageSliderHandlerAudio[i].material.SetFloat("NoColorsWhiteValue", 0.5f);
                }
                if (i < bNowSelectedGeneral.Length)
                {
                    bNowSelectedGeneral[i] = false;
                }
                iSelectedGeneral = -1;
            }
        }
        else if (CgOptionGeneral.alpha == 1f)
        {
            for (int i = 0; i < 2; i++)
            {
                if (EventSystem.currentSelectedGameObject == ButtonOptionGeneral_[i] && !bNowSelectedGeneral[i])
                {
                    bNowSelectedAudio[i] = true;
                    if (iSelectedGeneral > -1)
                    {
                        bNowSelectedAudio[iSelectedGeneral] = false;
                        iSelectedGeneral = i;
                    }
                    else
                    {
                        iSelectedGeneral = i;
                    }
                    ImageButtonGeneral[iSelectedGeneral].material.SetFloat("NoColorsWhiteValue", 1f);
                }
                else
                {
                    ImageButtonGeneral[i].material.SetFloat("NoColorsWhiteValue", 0.5f);
                }
                if (i < bNowSelectedAudio.Length)
                {
                    bNowSelectedAudio[i] = false;
                }
                iSelectedAudio = -1;
            }
        }
    }
    private void SelectionEnsurance()
    {
        if (EventSystem!=null && EventSystem.currentSelectedGameObject == null)
        {
            if(CgPauseMenu.alpha == 0f)
            {
                if (SceneManager.GetActiveScene().name == "LevelChoosing")
                {
                    if(GoLevelsButton != null && GoLevelsButton[0]!=null)
                    {
                        EventSystem.SetSelectedGameObject(GoLevelsButton[0]);
                    }
                }
                else if (SceneManager.GetActiveScene().name == "SceneSplash" && bMenuOnTriggered)
                {
                    if (GoGameChoose[0] != null)
                    {
                        EventSystem.SetSelectedGameObject(GoGameChoose[0]);
                    }
                }
            }
            else if(CgPauseMenu.alpha == 0f && CgScoring.alpha == 1f)
            {
                if (GoScoringFirstButtonSelected != null)
                {
                    EventSystem.SetSelectedGameObject(GoScoringFirstButtonSelected);
                }
            }
            else if(CgPauseMenu.alpha == 1f)
            {
                if(CgOptionPannel.alpha == 1f)
                {
                    if (GoOptionGeneralFirstButtonSelected != null)
                    {
                        EventSystem.SetSelectedGameObject(GoOptionGeneralFirstButtonSelected);
                    }
                }
                else
                {
                    if (GoPausedFirstButtonSelected != null)
                    {
                        EventSystem.SetSelectedGameObject(GoPausedFirstButtonSelected);
                    }
                }
            }
            else if(CgEndDialogue.alpha == 1f)
            {
                if (rectBoxTextImage.gameObject != null)
                {
                    EventSystem.SetSelectedGameObject(rectBoxTextImage.gameObject);
                    Debug.Log("ensurance for " + EventSystem.currentSelectedGameObject);
                }
            }
        }
    }
    private void CheckControllerStatus()
    {
        string[] controllers = Input.GetJoystickNames();

        // Check if at least one controller is connected
        bool isConnected = false;
        foreach (string controller in controllers)
        {
            if (!string.IsNullOrEmpty(controller)) // Check for valid controller name
            {
                isConnected = true;
                break;
            }
        }
        // Detect changes in connection status
        if (isConnected != controllerConnected)
        {
            controllerConnected = isConnected;

            if (controllerConnected)
            {
                Debug.Log("Controller connected!");
                if (control==null)
                {
                    OnEnableController();
                }
            }
            else
            {
                Debug.Log("No controllers connected!");
            }
        }
    }
    public IEnumerator wait()
    {
        yield return new WaitForSecondsRealtime(0.5f);
        if (CgPauseMenu.alpha == 1f && !bActif)
        {
            bActif = true;
        }
        else if (CgPauseMenu.alpha == 0f && bActif)
        {
            bActif = false;
        }
    }
    private void LoadTargetUIMenus()
    {
        _playerData = this.gameObject.GetComponent<PlayerData>();
        GameObject[] GoTargetUI = GameObject.FindGameObjectsWithTag("SceneUITarget");
        if (GoTargetUI != null)
        {
            if (SceneManager.GetActiveScene().name == "LevelChoosing")
            {
                GoLevelsButton = new GameObject[GoTargetUI.Length -6];
                GoLevelStars = new GameObject[4];
                _levels = new Level[GoTargetUI.Length -6];
                for (int i = 0; i < GoTargetUI.Length ; i++)
                {
                    for (int y = 0; y < GoTargetUI.Length; y++)
                    {
                        if (GoTargetUI[i].name == "SceneLvl" + y)
                        {
                            GoLevelsButton[y] = GoTargetUI[i];
                            _levels[y] = new Level(y, GoLevelsButton);
                        }
                        else if(GoTargetUI[i].name == "BackButton")
                        {
                            GoLevelBackButton = GoTargetUI[i];
                        }
                        else if (GoTargetUI[i].name == "StarsLvl" + y)
                        {
                            GoLevelStars[y] = GoTargetUI[i];
                        }
                        else if(GoTargetUI[i].name == "LevelChoosing")
                        {
                            _scLevels = GoTargetUI[i].GetComponent<sc_levelChoosing_>();
                            _scLevels.iPreviousLvlDone = iPreviousLevelPlayed;
                        }
                    }
                }
                GoGameChoose[0] = null;
                sSceneToLoad = "SceneLvl";
            }
            else if (SceneManager.GetActiveScene().name == "SceneSplash")
            {
                GoGameChoose = new GameObject[5];
                for (int i = 0; i < GoTargetUI.Length; i++)
                {
                    for (int y = 0; y < 3; y++)
                    {
                        if (GoTargetUI[i].name == "GameChoose" + y)
                        {
                            GoGameChoose[y] = GoTargetUI[i];
                        }
                    }
                    if (GoTargetUI[i].name == "Buttons")
                    {
                        GoGameChoose[3] = GoTargetUI[i];
                    }
                    else if (GoTargetUI[i].name == "PressAnyButtonImage")
                    {
                        GoGameChoose[4] = GoTargetUI[i];
                    }
                    else if (GoTargetUI[i].name == "Spline")
                    {
                        trainMenu = GoTargetUI[i].transform.GetComponent< SplineTrainMover_WithSpacing>();
                    }
                }
                GoGameChoose[4].transform.GetComponent<UnityEngine.UI.Image>().color = new Color32(255,255,255,255);
                GoGameChoose[3].transform.GetComponent<CanvasGroup>().alpha = 0f;
                GoLevelsButton = null;
                _levels = null;
                sSceneToLoad = "Loft"; 
                UnityEngine.UI.Button btnNewLoad = GoGameChoose[0].GetComponent<UnityEngine.UI.Button>();
                btnNewLoad.onClick.AddListener(delegate { LoadScene(sSceneToLoad); });
                UnityEngine.UI.Button btnExit = GoGameChoose[2].GetComponent<UnityEngine.UI.Button>();
                btnExit.onClick.AddListener(QuitGame);
                UnityEngine.UI.Button btnOptions = GoGameChoose[1].GetComponent<UnityEngine.UI.Button>();
                btnOptions.onClick.AddListener(OptionsGame);
            }
        }
        else
        {
            GoGameChoose[0] = null;
            GoLevelsButton = null;
        }
        if(SceneManager.GetActiveScene().name == "SceneSplash")
        {
            bMenuOnTriggered = false;
            sSceneToLoad = "Loft";
            UnityEngine.UI.Button btnNewLoad = GoGameChoose[0].GetComponent<UnityEngine.UI.Button>();
            btnNewLoad.onClick.AddListener(delegate { LoadScene(sSceneToLoad); });
            if (_playerData.iLevelPlayer > 0)
            {
                TextMeshProUGUI txt = GoGameChoose[0].transform.GetChild(0).gameObject.GetComponent<TextMeshProUGUI>();
                if(_playerData.iLanguageNbPlayer==1)
                {
                    txt.text = "Continuer";
                }
                else
                {
                    txt.text = "Continue";
                }
            }
            else
            {
                TextMeshProUGUI txt = GoGameChoose[0].transform.GetChild(0).gameObject.GetComponent<TextMeshProUGUI>();
                if (_playerData.iLanguageNbPlayer == 1)
                {
                    txt.text = "Nouvelle Partie";
                }
                else
                {
                    txt.text = "New Game";
                }
            }
        }
        else if(SceneManager.GetActiveScene().name == "Loft")
        {
            sSceneToLoad = "LevelChoosing";
        }
        else if(SceneManager.GetActiveScene().name == "LevelChoosing")
        {
            for (int i = 0; i < GoLevelsButton.Length; i++)
            {
                if ( _playerData.iLevelPlayer >= i) //Pour tous les niveaux faits
                {
                    int captured = i;
                    _levels[i].button_level.onClick.AddListener(() => LoadScene(_levels[captured].sScene_Level));
                    if(_playerData.iLevelPlayer>i)
                    {
                        _levels[i].img_lvl.sprite = spriteLevel_done;
                        _levels[i].img_lvl.material = null;
                    }
                    else
                    {
                        _levels[i].img_lvl.sprite = null; 
                        _levels[i].img_lvl.material = m_buttonLevel;
                    }
                    TextMeshProUGUI textChild = _levels[i].Go_LevelButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(0, 255, 255, 255);
                    for(int y = 0; y< 5; y++)
                    {
                        GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().color = new Color32(255, 255, 255, 255);
                        if (_playerData.iStarsPlayer[5*i+y] ==1) //Si une étoile est faite ou non
                        {
                            GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().sprite = sprite_star_completed; ;
                        }
                        else
                        {
                            GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().sprite = sprite_star_empty;
                        }
                    }
                    if (i>0)
                    {
                        GoLevelStars[i].transform.GetChild(5).GetComponent<UnityEngine.UI.Image>().color = new Color32(0, 0, 0, 0);
                    }
                }
               else if(GoLevelsButton.Length- _playerData.iLevelPlayer > i) //Pour tous les niveaux non faits
               {
                    _levels[i].img_lvl.sprite = spriteLevel_notDone;
                    _levels[i].img_lvl.material = null;
                    TextMeshProUGUI textChild = _levels[i].Go_LevelButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(255, 255, 0, 255);
                    for (int y = 0; y < 5; y++)
                    {
                         GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().color = new Color32(0, 0, 0, 0);
                    }
                    GoLevelStars[i].transform.GetChild(5).GetComponent<UnityEngine.UI.Image>().color = new Color32(255, 255, 255, 255);
                }
                GoLevelBackButton.GetComponent<UnityEngine.UI.Button>().onClick.AddListener(() => LoadScene("Loft"));
            }
            EventSystem.SetSelectedGameObject(GoLevelsButton[0]);
        }
    }
    public IEnumerator ImuneToPause(BPM_Manager bpmmanager)
    {
        if(scPlayer.tutoGen ==null || (scPlayer.tutoGen != null && !scPlayer.tutoGen.bIsOnBD))
        {
            scPlayer.bIsImune = true;
            bpmmanager.iTimer = 3;
            yield return new WaitForSecondsRealtime(bpmmanager.FSPB * 3);
            if (scPlayer.bIsReplaying)
            {
                scPlayer.bIsReplaying = false;
            }
            scPlayer.bIsImune = false;
        }
    }
    //SCENE LOADING
    public void LoadScene(string sceneToLoad)
    {
        if (SceneManager.GetActiveScene().name != "Loft")
        {
            ButtonSound();
        }
        if (sceneToLoad == "SceneLvl0" || sceneToLoad == "SceneLvl1" || sceneToLoad == "SceneLvl2" || sceneToLoad == "SceneLvl3")
        {
            if (basicLoopInstance.isValid())
            {
                basicLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
                basicLoopInstance.release();
            }
            if (detectedLoopInstance.isValid())
            {
                detectedLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
                detectedLoopInstance.release();
            }
            if (beatLoopInstance.isValid())
            {
                beatLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
                beatLoopInstance.release();
            }
            isPlaying = false;
            StartCoroutine(StartLoad(sceneToLoad));
            for(int i =0; i<4; i++)
            {
                if(sceneToLoad == "SceneLvl" + i.ToString())
                {
                    iPreviousLevelPlayed = i;
                }
            }
        }
        else if (sceneToLoad == "LevelChoosing" || sceneToLoad == "Scenes/World/LevelChoosing")
        {
            if(!isPlaying)
            {
                if (basicLoopInstance.isValid())
                {
                    basicLoopInstance.getPlaybackState(out PLAYBACK_STATE state);
                    if (state != PLAYBACK_STATE.STOPPED) return;
                }
                basicLoopInstance = RuntimeManager.CreateInstance(menuLoop);
                basicLoopInstance.start();

                detectedLoopInstance = RuntimeManager.CreateInstance(menuLoopDetected);
                detectedLoopInstance.start();

                beatLoopInstance = RuntimeManager.CreateInstance(menuLoopBeat);
                beatLoopInstance.start();
                isPlaying = true;
                SetMusicVolume();
            }

            if (CgPauseMenu.alpha == 1f)
            {
                CgPauseMenu.alpha = 0f;
                CgPauseMenu.blocksRaycasts = false;
                CgPauseMenu.interactable = false;
                RtPauseMenu.anchorMin = new Vector2(0, 1);
                RtPauseMenu.anchorMax = new Vector2(1, 2);
                RtPauseMenu.offsetMax = new Vector2(0f, 0f);
                RtPauseMenu.offsetMin = new Vector2(0f, 0f);
            }
            StartCoroutine(StartLoad(sceneToLoad));
        }
        else if (sceneToLoad == "retry")
        {
            sceneToLoad = SceneManager.GetActiveScene().name;
            StartCoroutine(StartLoad(sceneToLoad));
        }
        else if (sceneToLoad == "next")
        {
            for (int i = 0; i < 3; i++)
            {
                if ("SceneLvl" + i.ToString() == SceneManager.GetActiveScene().name)
                {
                    sceneToLoad = "SceneLvl" + (i + 1).ToString();
                }
            }
            StartCoroutine(StartLoad(sceneToLoad));
        }
        else
        {
            StartCoroutine(StartLoad(sceneToLoad));
        }
        if (CgScoring.alpha == 1f)
        {
            CgScoring.alpha = 0f;
            CgScoring.blocksRaycasts = false;
            CgScoring.interactable = false;
            RtScoring.anchorMin = new Vector2(0, 1);
            RtScoring.anchorMax = new Vector2(1, 2);
            RtScoring.offsetMax = new Vector2(0f, 0f);
            RtScoring.offsetMin = new Vector2(0f, 0f);
        }
    }
    private IEnumerator StartLoad(string sceneToLoad)
    {
        CgLoadingScreen.alpha = 1f;
        CgLoadingScreen.blocksRaycasts = true;
        RtLoadingScreen.anchorMin = new Vector2(0, 0);
        RtLoadingScreen.anchorMax = new Vector2(1, 1);
        RtScoring.anchorMin = new Vector2(0, 1);
        RtScoring.anchorMax = new Vector2(0, 1);
        yield return StartCoroutine(FadeLoadingScreen(1, 0.5f));
        LoaderScene(sceneToLoad);
        while (!loadingOperation.isDone)
        {
            yield return null;
        }
        LoadTargetUIMenus();
        yield return StartCoroutine(FadeLoadingScreen(0, 0.001f));
        isLoadingScene = false;
        CgLoadingScreen.alpha = 0f;
        CgLoadingScreen.blocksRaycasts = false;
        RtLoadingScreen.anchorMin = new Vector2(0, 1);
        RtLoadingScreen.anchorMax = new Vector2(1, 2);
        RtScoring.anchorMin = new Vector2(0, 1);
        RtScoring.anchorMax = new Vector2(1, 2);
        if(sceneToLoad == "LevelChoosing")
        {
            EventSystem.SetSelectedGameObject(GoLevelsButton[0]);
        }
    }
    private void LoaderScene(string sceneToLoad)
    {
        Debug.LogWarning("Scene loading attempt");
        if (isLoadingScene) return;
        if (!Application.CanStreamedLevelBeLoaded(sceneToLoad)) return;
        isLoadingScene = true;
        loadingOperation = SceneManager.LoadSceneAsync(sceneToLoad);
    }
    private IEnumerator FadeLoadingScreen(float targetValue, float duration)
    {
        float startValue = CgLoadingScreen.alpha;
        float time = 0;

        while (time < duration)
        {
            CgLoadingScreen.alpha = Mathf.Lerp(startValue, targetValue, time / duration);
            time += Time.unscaledDeltaTime;
            yield return null;
        }
        CgLoadingScreen.alpha = targetValue;
    }
    //PAUSE AND SETTINGS
    private void UXNavigation()
    {
        if (controllerConnected && control !=null && control.GamePlay.Pausing.triggered)
        {
            PauseMenu();
        }
        if(!controllerConnected)
        {
            if(!bIsOnTestScene)
            {
                bWaitController = true;
                bGameIsPaused = true;
                PauseGame();
                CgControllerWarning.alpha = 1;
                CgControllerWarning.blocksRaycasts = true;
                RtControllerWarning.anchorMin = new Vector2(0, 0);
                RtControllerWarning.anchorMax = new Vector2(1, 1);
                RtControllerWarning.offsetMax = new Vector2(0f, 0f);
                RtControllerWarning.offsetMin = new Vector2(0f, 0f);
            }
        }
        if(bWaitController && controllerConnected)
        {
            bWaitController = false;
            bGameIsPaused = false;
            PauseGame();
            CgControllerWarning.alpha = 0;
            CgControllerWarning.blocksRaycasts = false;
            RtControllerWarning.anchorMin = new Vector2(0, 1);
            RtControllerWarning.anchorMax = new Vector2(1, 2);
            RtControllerWarning.offsetMax = new Vector2(0f, 0f);
            RtControllerWarning.offsetMin = new Vector2(0f, 0f);
        }
        if(controllerConnected && CgOptionPannel.alpha == 1f)
        {
            CheckCurrentSelectable();
            if (CgOptionAudio.alpha ==1f && !bOnceOptions[0])
            {
                var navigation = ButtonOptionAudio.navigation;
                navigation.selectOnUp = SliderOptionAudio[0];
                navigation.selectOnDown = SliderOptionAudio[1];
                navigation.selectOnLeft = ButtonsOptionAudio_fromAudio[0];
                navigation.selectOnRight = ButtonsOptionAudio_fromAudio[1];
                ButtonOptionAudio.navigation = navigation;

                var navigation1 = ButtonOptionGeneral.navigation;
                navigation1.selectOnUp = SliderOptionAudio[0];
                navigation1.selectOnDown = SliderOptionAudio[1];
                navigation1.selectOnLeft = ButtonsOptionGeneral_fromAudio[0];
                navigation1.selectOnRight = ButtonsOptionGeneral_fromAudio[1];
                ButtonOptionGeneral.navigation = navigation1;
                bOnceOptions[0] = true;
            }
            else if(CgOptionGeneral.alpha == 1f && !bOnceOptions[1])
            {
                var navigation = ButtonOptionAudio.navigation;
                navigation.selectOnUp = ButtonsOptionAudio_fromGeneral[0];
                navigation.selectOnDown = ButtonsOptionAudio_fromGeneral[1];
                navigation.selectOnLeft = ButtonsOptionAudio_fromGeneral[2];
                navigation.selectOnRight = ButtonsOptionAudio_fromGeneral[3];
                ButtonOptionAudio.navigation = navigation;

                var navigation1 = ButtonOptionGeneral.navigation;
                navigation1.selectOnUp = ButtonsOptionGeneral_fromGeneral[0];
                navigation1.selectOnDown = ButtonsOptionGeneral_fromGeneral[1];
                navigation1.selectOnLeft = ButtonsOptionGeneral_fromGeneral[2];
                navigation1.selectOnRight = ButtonsOptionGeneral_fromGeneral[3];
                ButtonOptionGeneral.navigation = navigation1;
                bOnceOptions[1] = true;
            }
            else if(CgOptionGeneral.alpha == 1f && !bOnceOptions[2])
            {
                if(_playerData.iLanguageNbPlayer==0) //english
                {
                    ImageButtonGeneral[0].material = M_materialButtonGeneral[0];
                }
                else
                {
                    ImageButtonGeneral[0].material = M_materialButtonGeneral[1];
                }
                if(iDifficulty==0) //hard
                {
                    ImageButtonGeneral[1].material = M_materialButtonGeneral[2];
                }
                else if(iDifficulty == 1) //normal
                {
                    ImageButtonGeneral[1].material = M_materialButtonGeneral[3];
                }
                else if (iDifficulty == 2)//easy
                {
                    ImageButtonGeneral[1].material = M_materialButtonGeneral[4];
                }
                bOnceOptions[2] = true;
            }
        }
        else if(controllerConnected && CgPauseMenu.alpha == 1f)
        {
            CheckCurrentSelectable();
        }

        if (controllerConnected && EventSystem!=null)
        {
            SelectionEnsurance();
        }
    }
    public void PauseMenu()
    {
        ButtonSound();
        if (CgPauseMenu.alpha == 0f && !bActif) // On ouvre la fenetre, le jeu est en pause
        {
            CgPauseMenu.alpha = 1f;
            CgPauseMenu.blocksRaycasts = true;
            CgPauseMenu.interactable = true;
            RtPauseMenu.anchorMin = new Vector2(0, 0);
            RtPauseMenu.anchorMax = new Vector2(1, 1);
            RtPauseMenu.offsetMax = new Vector2(0f, 0f);
            RtPauseMenu.offsetMin = new Vector2(0f, 0f);
            EventSystem.SetSelectedGameObject(GoPausedFirstButtonSelected); 
            CheckCurrentSelectable();
            GoPausedFirstButtonSelected.GetComponent<UnityEngine.UI.Button>().Select();
            bGameIsPaused = true;
            PauseGame();
            if (scPlayer != null && scPlayer.bpmManager != null)
            {
                StopCoroutine(scPlayer.bpmManager.VibrationVfx(0f, 0f, 0.1f));
            }
            StartCoroutine(wait());
        }
        else if (CgPauseMenu.alpha == 1f && bActif) // On ferme la fenetre, le jeu reprend
        {
            CgPauseMenu.alpha = 0f;
            CgPauseMenu.blocksRaycasts = false;
            CgPauseMenu.interactable = false;
            RtPauseMenu.anchorMin = new Vector2(0, 1);
            RtPauseMenu.anchorMax = new Vector2(1, 2);
            RtPauseMenu.offsetMax = new Vector2(0f, 0f);
            RtPauseMenu.offsetMin = new Vector2(0f, 0f);
            CloseOptions(false);
            if ((scPlayer != null && scPlayer.bisTuto == true && SceneManager.GetActiveScene().name != "Loft") || (scPlayer != null && CgScoring.alpha == 1f) || (scPlayer != null && CgEndDialogue.alpha == 1f))
            {
                bGameIsPaused = true;
            }
            else
            {
                bGameIsPaused = false;
            }
            if (CgScoring.alpha == 1f)
            {
                EventSystem.SetSelectedGameObject(GoScoringFirstButtonSelected);
            }
            else if(SceneManager.GetActiveScene().name == "SplashScreen" && bMenuOnTriggered)
            {
                EventSystem.SetSelectedGameObject(GoGameChoose[0]);
            }
            else if (SceneManager.GetActiveScene().name == "LevelChoosing")
            {
                EventSystem.SetSelectedGameObject(GoLevelsButton[0]);
            }
            else if(CgEndDialogue.alpha == 1f)
            {
                EventSystem.SetSelectedGameObject(rectBoxTextImage.gameObject);
            }
            else
            {
                EventSystem.SetSelectedGameObject(null);
                SelectionEnsurance();
            }
            StartCoroutine(wait());
            if(scPlayer!=null)
            {
                StartCoroutine(ImuneToPause(scPlayer.bpmManager));
            }
            PauseGame();
        }
    }
    private void ButtonSound()
    {
        if (sfx_ui_button.Length > 1)
        {
            SoundManager.Instance.PlayOneShot(sfx_ui_button[Hasard(0, sfx_ui_button.Length - 1)]);
        }
        else
        {
            SoundManager.Instance.PlayOneShot(sfx_ui_button[0]);
        }
    }
    public void OptionsGame()
    {
        CgPauseMenu.alpha = 0f;
        ButtonSound();
        EventSystem.SetSelectedGameObject(GoOptionGeneralFirstButtonSelected);
        CgPauseMenu.interactable = false;
        CgOptionPannel.alpha = 1f;
        CgOptionPannel.interactable = true;
        CgOptionPannel.blocksRaycasts = true;
        RtOptionPannel.anchorMin = new Vector2(0, 0);
        RtOptionPannel.anchorMax = new Vector2(1, 1);
        RtOptionPannel.offsetMax = new Vector2(0f, 0f);
        RtOptionPannel.offsetMin = new Vector2(0f, 0f);
    }
    public void Options(bool bGeneral)
    {
        ButtonSound();
        if (bGeneral)
        {
            bOnceOptions[0] = false;
            CgOptionAudio.alpha = 0f;
            CgOptionAudio.interactable = false;
            CgOptionAudio.blocksRaycasts = false;
            CgOptionGeneral.alpha = 1f;
            CgOptionGeneral.interactable = true;
            CgOptionGeneral.blocksRaycasts = true;
        }
        else
        {
            bOnceOptions[1] = false;
            CgOptionGeneral.alpha = 0f;
            CgOptionGeneral.interactable = false;
            CgOptionGeneral.blocksRaycasts = false;
            CgOptionAudio.alpha = 1f;
            CgOptionAudio.interactable = true;
            CgOptionAudio.blocksRaycasts = true;
        }
    }
    public void CloseOptions(bool bFromPause)
    {
        if (bFromPause)
        {
            CgPauseMenu.alpha = 1f;
            bActif = true;
            CgPauseMenu.blocksRaycasts = true;
            CgPauseMenu.interactable = true;
            RtPauseMenu.anchorMin = new Vector2(0, 0);
            RtPauseMenu.anchorMax = new Vector2(1, 1);
            RtPauseMenu.offsetMax = new Vector2(0f, 0f);
            RtPauseMenu.offsetMin = new Vector2(0f, 0f);
        }
        ButtonSound();
        CgPauseMenu.interactable = true;
        CgOptionPannel.alpha = 0f;
        CgOptionPannel.interactable = false;
        CgOptionPannel.blocksRaycasts = false;
        EventSystem.SetSelectedGameObject(GoPausedFirstButtonSelected);
        RtOptionPannel.anchorMin = new Vector2(0, 1);
        RtOptionPannel.anchorMax = new Vector2(1, 2);
        RtOptionPannel.offsetMax = new Vector2(0f, 0f);
        RtOptionPannel.offsetMin = new Vector2(0f, 0f);
    }
    public void Difficulty()
    {
        bOnceOptions[2] = false;
        ButtonSound();
        if (iDifficulty == 0)
        {
            iDifficulty = 1; 
        }
        else if(iDifficulty == 1)
        {
            iDifficulty = 2;
        }
        else
        {
            iDifficulty = 0;
        }
        if (scPlayer!=null && scPlayer.bpmManager!=null)
        {
            scPlayer.bpmManager.StartBPM();
        }
    }
    public void LanguageButton()
    {
        bOnceOptions[2] = false;
        ButtonSound();
        if (_playerData.iLanguageNbPlayer == 1)
        {
            _playerData.iLanguageNbPlayer = 0;
        }
        else
        {
            _playerData.iLanguageNbPlayer = 1;
        }
        if(SceneManager.GetActiveScene().name == "SceneSplash")
        {
            TrainSplashLanguage();
        }
    }
    public void GridButton()
    {
        if(_playerData.iGrid == 1)
        {
            _playerData.iGrid = 0; //false
        }
        else
        {
            _playerData.iGrid = 1; //true
        }
        bOnceGrid = false;
    }
    public void QuitGame()
    {
        ButtonSound();
#if UNITY_EDITOR
        if (UnityEditor.EditorApplication.isPlaying)
        {
            UnityEditor.EditorApplication.isPlaying = false;
        }
#endif
        Application.Quit();
    }
    public void SetMusicVolume()
    {
        playerMusicVolume = MusicSlider.value;
        if (!music_basic_VCA.isValid() || !music_beat_VCA.isValid() || !music_detected_VCA.isValid())
        {
            Debug.LogWarning("VCA is not valid! Check FMOD path.");
            music_basic_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_basic");
            music_beat_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_beat");
            music_detected_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_detected");
            sfxVCA = FMODUnity.RuntimeManager.GetVCA("vca:/SFX");
            ambianceVCA = FMODUnity.RuntimeManager.GetVCA("vca:/Ambiance"); 
            if (!music_basic_VCA.isValid() || !music_beat_VCA.isValid() || !music_detected_VCA.isValid())
            {
                Debug.LogError("VCA is STILL!!!! not valid!");
                return;
            }
        }
        if (SceneManager.GetActiveScene().name == "SceneLvl0" || SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl2" || SceneManager.GetActiveScene().name == "SceneLvl3")
        {
            fDetectedVolume = (scPlayer.FDetectionLevel / 100f)*0.7f;
            music_basic_VCA.setVolume((playerMusicVolume - fDetectedVolume)*0.7f);
            music_detected_VCA.setVolume(fDetectedVolume*0.7f);
            music_beat_VCA.setVolume(fBeatMusicVolume * playerMusicVolume);
            music_beat_VCA.getVolume(out float checkVolume);
            //Debug.Log("beat volume is " + checkVolume + " and we set it at " + fBeatMusicVolume);
        }
        else
        {
            music_basic_VCA.setVolume(playerMusicVolume);
            music_detected_VCA.setVolume(0f);
            music_beat_VCA.setVolume(0f);
        }
    }
    public void SetAmbianceVolume()
    {
        float volume = AmbianceSlider.value;
        ambianceVCA.setVolume(volume);
    }
    public void SetSFXVolume()
    {
        float volume = SfxSlider.value;
        sfxVCA.setVolume(volume);
    }
    public void PauseGame()
    {
        if (bGameIsPaused)
        {
            Time.timeScale = 0f;
            if (scPlayer != null && scPlayer.bisTuto == false)
            {
                music_basic_VCA.getVolume(out float currentVolume); // Get current volume
                music_basic_VCA.setVolume(currentVolume * 0.8f);
                music_detected_VCA.getVolume(out float currentVolume_); // Get current volume
                music_detected_VCA.setVolume(currentVolume_ * 0.8f);
                //bpmManager.playerLoopInstance.setParameterByName("fPausedVolume", 0.8f);
            }
        }
        else
        {
            Time.timeScale = 1f;
            music_basic_VCA.setVolume(playerMusicVolume - fDetectedVolume);
            music_detected_VCA.setVolume(fDetectedVolume);
            music_beat_VCA.setVolume(0f);
            if (CgScoring.alpha == 1f)
            {
                EventSystem.SetSelectedGameObject(GoScoringFirstButtonSelected);
            }
        }
    }
    //DIALOGUE
    public void CheckDialogue()
    {
        bWaitNextDialogue = false;
        BeginDialogue(false, true);
    }
    public void BeginDialogue(bool first, bool bHasWon)
    {
        if (first == true)
        {
            iLevelDialogue = iPreviousLevelPlayed;
            CgEndDialogue.interactable = true;
            EventSystem.SetSelectedGameObject(rectBoxTextImage.gameObject);
            ImgEndDialogueBackground.sprite = spritesEndDialogueBackground[iLevelDialogue];
            if (bHasWon)
            {
                bIsOnEndDialogue = true;
                if (iLevelDialogue != 0)
                {
                    if (iLevelDialogue == 3)
                    {
                        int iAllStars = _playerData.iStarsPlayer[1] + _playerData.iStarsPlayer[6] + _playerData.iStarsPlayer[11];
                        if (iAllStars == 3)
                        {
                            iLevelDialogue = 5;
                        }
                        else
                        {
                            iLevelDialogue = 4;
                        }
                    }
                    iNbTextNow = iNbDialoguePerLevelAdd[iLevelDialogue - 1];
                    Debug.Log(iNbTextNow);
                }
                else
                {
                    iNbTextNow = 0; 
                }
            }
            else
            {
                if (iLevelDialogue != 3)
                {
                    CgEndDialogue.alpha = 0f;
                    CgEndDialogue.blocksRaycasts = false;
                    RtEndDialogue.anchorMin = new Vector2(0, 1);
                    RtEndDialogue.anchorMax = new Vector2(1, 2);
                    RtEndDialogue.offsetMax = new Vector2(0f, 0f);
                    RtEndDialogue.offsetMin = new Vector2(0f, 0f);
                    StartCoroutine(scPlayer.EndGame(false, _playerData));
                }
                else
                {
                    iLevelDialogue = 3;
                }
            }
        }
        if (iNbTextNow == iNbDialoguePerLevelAdd[iLevelDialogue] -1)
        {
            EndDialogue();
            bIsOnEndDialogue = false;
        }
        else
        {
            NextBox(_playerData.iLanguageNbPlayer, first, iLevelDialogue);
        }
    }
    private void NextBox(int iLanguage, bool bIsFirst, int iLevel)
    {
        if (!bIsFirst)
        {
            iNbTextNow += 1;
        }
        else
        {
            if (iLevel - 1 == -1)
            {
                iNbTextNow = 0;
            }
            else
            {
                iNbTextNow = iNbDialoguePerLevelAdd[iLevel - 1];
            }
        }
        SetSpeaker(iCharaToSpeakPerTextes[iNbTextNow], iCharaToNotSpeakPerTextes[iNbTextNow], iLevel);
        if (iLanguage == 0)
        {
            _sc_textChange.StartWriting(sDialogueEnglish[iNbTextNow]);
        }
        else
        {
            _sc_textChange.StartWriting(sDialogueFrench[iNbTextNow]);
        }
    }
    private void SetSpeaker(int speakingCharacterIndex, int notSpeakingCharacterIndex, int iLevel) //on connait le numero du character mais est-il à gauche ou à droite?
    {
        // Change the text box to the one of the character speaking
        int a = RightIntSpeakerAndNot(speakingCharacterIndex);
        //int b = RightIntSpeakerAndNot(speakingCharacterIndex, notSpeakingCharacterIndex)[1];
        if(a==-1)
        {
            imgBoxText.color = new Color32(0, 0, 0, 255);
        }
        //Is right or left character speaking ? 
        if (iWhichCharaToRightToLeft[iNbTextNow*2]== a) //Le sprite de droite est-il celui du chara qui parle ?
        {
            imgBoxText.sprite = spritesCharactersBoxesRight[a];
            imgBoxText.color = new Color32(255, 255, 255, 255);
            if (speakingCharacterIndex != -1)
            {
                imgCharactersSpace[0].sprite = spritesEndDialogueCharacters[speakingCharacterIndex]; // Le sprite de droite est rempli par le sprite du chara qui est à droite en fonction du lvl
                imgCharactersSpace[1].sprite = spritesEndDialogueCharactersNotSpeak[notSpeakingCharacterIndex];// Le sprite de gauche est rempli par le sprite du chara qui est à gauche en fonction du lvl
                imgCharactersSpace[0].color = new Color32(255, 255, 255, 255);
                imgCharactersSpace[1].color = new Color32(255, 255, 255, 255);
            }
            else
            {
                imgCharactersSpace[0].color = new Color32(255,255,255,0);
                imgCharactersSpace[1].color = new Color32(255, 255, 255, 0);
            }
            // Non-speaking character goes below
            charactersImages[1].SetSiblingIndex(0);
            // Ensure the dialogue box is at index 1 (middle layer)
            rectBoxTextImage.SetSiblingIndex(1);
            // Speaking character goes above
            charactersImages[0].SetSiblingIndex(2); //Alors le character de droite est devant

            rectBoxTextImage.anchorMin = new Vector2(0.1f, 0);
            rectBoxTextImage.anchorMax = new Vector2(0.85f, 0.4f);
            rectBoxTextImage.offsetMax = new Vector2(0f, 0f);
            rectBoxTextImage.offsetMin = new Vector2(0f, 0f);
        }
        else
        {
            imgBoxText.sprite = spritesCharactersBoxesLeft[a];
            imgBoxText.color = new Color32(255, 255, 255, 255);
            if (notSpeakingCharacterIndex != -1)
            {
                imgCharactersSpace[0].sprite = spritesEndDialogueCharactersNotSpeak[notSpeakingCharacterIndex]; // Le sprite de droite est rempli par le sprite du chara qui est à droite en fonction du lvl
                imgCharactersSpace[1].sprite = spritesEndDialogueCharacters[speakingCharacterIndex];// Le sprite de gauche est rempli par le sprite du chara qui est à gauche en fonction du lvl
                imgCharactersSpace[0].color = new Color32(255, 255, 255, 255);
                imgCharactersSpace[1].color = new Color32(255, 255, 255, 255);
            }
            else
            {
                imgCharactersSpace[0].color = new Color32(255, 255, 255, 0);
                imgCharactersSpace[1].color = new Color32(255, 255, 255, 0);
            }
            // Non-speaking character goes below
            charactersImages[0].SetSiblingIndex(0);
            // Ensure the dialogue box is at index 1 (middle layer)
            rectBoxTextImage.SetSiblingIndex(1);
            // Speaking character goes above
            charactersImages[1].SetSiblingIndex(2);//Sinon le character de gauche est devant

            rectBoxTextImage.anchorMin = new Vector2(0.15f, 0);
            rectBoxTextImage.anchorMax = new Vector2(0.9f, 0.4f);
            rectBoxTextImage.offsetMax = new Vector2(0f, 0f);
            rectBoxTextImage.offsetMin = new Vector2(0f, 0f);
        }
    }
    private int RightIntSpeakerAndNot(int speakingCharacterIndex)
    {
        int a;
        //int[] a = new int[2];
        if(speakingCharacterIndex == -1) //Nobody
        {
            a = -1;
        }
        else if (speakingCharacterIndex <= 2 || (speakingCharacterIndex>=10&& speakingCharacterIndex <=12)) //Jett
        {
            a = 0;
        }
        else if ((speakingCharacterIndex > 2 && speakingCharacterIndex <= 5) || speakingCharacterIndex >= 13) //Scraffi
        {
            a = 1;
        }
        else if (speakingCharacterIndex > 5 && speakingCharacterIndex <= 7) //Scravinsky
        {
            a = 2;
        }
        else //Screonardo
        {
            a = 3;
        }

        /*if(notSpeakingCharacterIndex == -1)
        {
            a[1] = -1;
        }
        else if (notSpeakingCharacterIndex <= 2 || notSpeakingCharacterIndex>=10) //Jett
        {
            a[1] = 0;
        }
        else if (notSpeakingCharacterIndex > 2 && notSpeakingCharacterIndex <= 5)
        {
            a[1] = 1;
        }
        else if (notSpeakingCharacterIndex > 5 && notSpeakingCharacterIndex <= 7)
        {
            a[1] = 2;
        }
        else if (notSpeakingCharacterIndex > 7 && notSpeakingCharacterIndex <= 9)
        {
            a[1] = 3;
        }*/
        return a;
    }
    public void EndDialogue()
    {
        iNbTextNow = iNbDialoguePerLevelAdd[iPreviousLevelPlayed] - 1;
        bIsOnEndDialogue = false;
        CgEndDialogue.alpha = 0f;
        CgEndDialogue.interactable = false;
        CgEndDialogue.blocksRaycasts = false;
        RtEndDialogue.anchorMin = new Vector2(0, 1);
        RtEndDialogue.anchorMax = new Vector2(1, 2);
        RtEndDialogue.offsetMax = new Vector2(0f, 0f);
        RtEndDialogue.offsetMin = new Vector2(0f, 0f);

        if (_playerData.iLevelPlayer >= 4)
        {
            //
        }
        else
        {
            LoadScene("Scenes/World/LevelChoosing");
        }
    }
}
