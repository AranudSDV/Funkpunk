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
//using UnityEngine.LowLevel;
using FMOD.Studio;
//using Unity.Collections.LowLevel.Unsafe;
//using UnityEditor.SearchService;
//using UnityEngine.Rendering;

public class MenuManager : SingletonManager<MenuManager>
{
    public BPM_Manager bpmManager;
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
    [SerializeField] private UnityEngine.UI.Button[] ButtonsOption;
    [SerializeField] private UnityEngine.UI.Image[] ImageOption;
    [SerializeField] private UnityEngine.UI.Slider[] SliderOptionAudio = new UnityEngine.UI.Slider[3];
    [SerializeField] private UnityEngine.UI.Button[] ButtonOptionGeneral_ = new UnityEngine.UI.Button[2];
    [SerializeField] private UnityEngine.UI.Image[] ImageSliderHandlerAudio = new UnityEngine.UI.Image[3];
    [SerializeField] private UnityEngine.UI.Image[] ImageButtonGeneral = new UnityEngine.UI.Image[2];
    [Tooltip("first language english, french, then difficulty hard to easy")][SerializeField] private Material[] M_materialButtonGeneral;
    public CanvasGroup CgOptionPannel;
    public RectTransform RtOptionPannel;
    public CanvasGroup CgOptionGeneral;
    [Tooltip("hard, normal, easy")] public int iDifficulty = 0;
    [SerializeField] private EventReference[] sfx_ui_button;
    private bool[] bNowSelectedGeneral = new bool[3] { false, false, false };
    private bool[] bNowSelectedAudio = new bool[3] { false, false, false };
    //private int iSelectedGeneral = -1;
    //private int iSelectedAudio = -1;
    public bool bOnceGrid = false;
    private bool[] bOnceOptions = new bool[3] { false, false, false };

    [Header("Sound")]
    public FMOD.Studio.VCA music_VCA;
    public FMOD.Studio.VCA sfxVCA;
    public FMOD.Studio.VCA ambianceVCA;
    public float playerMusicVolume = 1f;
    public CanvasGroup CgOptionAudio;
    [SerializeField] private UnityEngine.UI.Slider SfxSlider;
    [SerializeField] private UnityEngine.UI.Slider MusicSlider;
    [SerializeField] private UnityEngine.UI.Slider AmbianceSlider;
    public bool bWithNotes = true;

    //NAVIGATION UX
    [Header("Navigation UX")]
    [SerializeField] private GameObject[] GoGameChoose = new GameObject[6];
    public GameObject[] GoLevelsButton;
    public GameObject GoLevelBackButton;
    public GameObject[] GoLevelStars;
    public Material material_star_completed;
    public Material material_star_empty;
    [SerializeField] private Material materialLevel_done;
    [SerializeField] private Material materialLevel_notDone;
    [SerializeField] private Color32 colorFoes;
    [SerializeField] private Color32 colorPlayer;
    public GameObject GoScoringFirstButtonSelected;

    //TRAIN SPLASH SCREEN
    [Header("Train Splash Screen")]
    public SplineTrainMover_WithSpacing trainMenu = null;
    private bool bMenuOnTriggered = false;
    private bool bWaitTrain = false;
    private bool bTrainIsHere = false;
    private float fTrainHasAppearedProgress = 0f;
    private float fTrainHasDisappearedProgress = 0f;
    private bool bHasAppeared = false;
    private bool bHasDisappeared = false;

    //END DIALOGUE
    [Header("EndGame")]
    public TMP_Text textBravo;
    public bool bisOnCredits = false;

    //SCORING
    [Header("Scoring")]
    public TMP_Text txt_Title;
    public CanvasGroup CgScoring;
    public RectTransform RtScoring;
    public TMP_Text txtScoringJudgment;
    public TMP_Text txtScoringScore;
    [Tooltip("Missed, Bad, Good, Perfect")]public TMP_Text[] txtScoringScoreDetails = new TMP_Text[4];
    public CanvasGroup cgScoreDetails;
    public GameObject GoScoringSuccess;
    public CanvasGroup CgScoringSuccess;
    public RectTransform RtScoringSuccess;
    public UnityEngine.UI.Button[] ButtonsScoring;
    public UnityEngine.UI.Image[] ImageButtonsScoring;
    public UnityEngine.UI.Image[] ImageStars;

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
    [SerializeField] private Material[] M_ImageEndings;
    [SerializeField] private UnityEngine.UI.Image imageEnding;

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
        music_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_basic");
        sfxVCA = FMODUnity.RuntimeManager.GetVCA("vca:/SFX");
        ambianceVCA = FMODUnity.RuntimeManager.GetVCA("vca:/Ambiance"); 
        if(SceneManager.GetActiveScene().name == "Gym_GPP")
        {
            bpmManager.bIsOnLvl = true;
        }
        else
        {
            bpmManager.bIsOnLvl = false;
        }
        bpmManager.bInitialized[0] = false;
        bpmManager.bInitialized[1] = false;

        SetMusicVolume(0f);
        SetSFXVolume();
    }
    // Update is called once per frame
    void Update()
    {
        CheckControllerStatus();
        Shader.SetGlobalFloat("UnscaledDT", Time.unscaledDeltaTime);
        if (!bMenuOnTriggered && controllerConnected && control !=null && control.GamePlay.Move.triggered && (SceneManager.GetActiveScene().name == "SceneSplash"|| SceneManager.GetActiveScene().name == "Scenes/World/SceneSplash") && !bisOnCredits)
        {
            bMenuOnTriggered = true;
            if (GoGameChoose[5] == null)
            {
                Debug.Log("null");
            }
            GoGameChoose[5].transform.GetComponent<UnityEngine.UI.Image>().color = new Color32(255, 255, 255, 0);
            TrainAndUION();
            if(trainMenu!=null)
            {
                trainMenu.bMenuTriggered = true;
            }
        }
        if(SceneManager.GetActiveScene().name == "SceneSplash" || SceneManager.GetActiveScene().name == "Scenes/World/SceneSplash")
        {
            if (bWaitTrain && bMenuOnTriggered)
            {
                TrainAndUION();
            }
            if(bisOnCredits)
            {
                TrainAndUION();
            }
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
        if(trainMenu !=null)
        {
            if (!trainMenu.renderCars[0].isVisible && !trainMenu.renderCars[1].isVisible) //le train n'est pas visible
            {
                bWaitTrain = true;
                bTrainIsHere = false;
                bHasAppeared = false; //fTrainHasDisappearedProgress
                if (trainMenu.progress[0] > trainMenu.progress[1])
                {
                    fTrainHasDisappearedProgress = trainMenu.progress[0];
                }
                else
                {
                    fTrainHasDisappearedProgress = trainMenu.progress[1];
                }

                if(fTrainHasDisappearedProgress>fTrainHasAppearedProgress && !bHasDisappeared)
                {
                    bHasDisappeared = true;
                    for (int i = 0; i < trainMenu.progress.Length; i++)
                    {
                        trainMenu.progress[i] = 1f;
                        trainMenu.pauseTimer[i] = trainMenu.pauseDuration;
                    }
                }
                else if(fTrainHasAppearedProgress > fTrainHasDisappearedProgress)
                {
                    bHasDisappeared = false;
                }
            }
            else if ((trainMenu.renderCars[0].isVisible || trainMenu.renderCars[1].isVisible) && !bHasAppeared)//le train passe
            {
                if (trainMenu.progress[0] > trainMenu.progress[1])
                {
                    fTrainHasAppearedProgress = trainMenu.progress[0];
                }
                else
                {
                    fTrainHasAppearedProgress = trainMenu.progress[1];
                }
                bHasAppeared = true;
                bWaitTrain = false;
                bTrainIsHere = true;
            }
            if (bTrainIsHere)
            {
                if (bisOnCredits && !trainMenu.bOnce)
                {
                    trainMenu.bOnce = true;
                    bTrainIsHere = false;
                    StartCoroutine(CreditsNext());
                }
                else if(!bisOnCredits)
                {
                    UnityEngine.UI.Button btnNewLoad = GoGameChoose[0].GetComponent<UnityEngine.UI.Button>();
                    TrainSplashLanguage();
                    GoGameChoose[4].transform.GetComponent<CanvasGroup>().alpha = 1f;
                    bWaitTrain = false;
                    bTrainIsHere = false;
                    SelectionEnsurance();
                }
            }
        }
    }
    private IEnumerator CreditsNext()
    {
        yield return new WaitForSecondsRealtime(0.3f);
        if (trainMenu.iCredits!=0)
        {
            trainMenu.cgChildrenCredits[trainMenu.iCredits-1].alpha = 0f;
        }
        if(trainMenu.iCredits == trainMenu.cgChildrenCredits.Length)
        {
            bisOnCredits = false;
            trainMenu.cgCredits.alpha = 0f;
            GoGameChoose[5].GetComponent<CanvasGroup>().alpha = 1f;
        }
        else
        {
            trainMenu.cgChildrenCredits[trainMenu.iCredits].alpha = 1f;
            trainMenu.txtChildrenCredits[trainMenu.iCredits].BubbleShowText();
            trainMenu.iCredits += 1;
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
        sSceneToLoad = "Scenes/World/Loft";
        UnityEngine.UI.Button btnNewLoad = GoGameChoose[0].GetComponent<UnityEngine.UI.Button>();
        btnNewLoad.onClick.AddListener(delegate { LoadScene(sSceneToLoad); });
    }
    private void CheckCurrentSelectable()
    {
        if (CgPauseMenu.alpha == 1f)
        {
            for (int i = 0; i < buttonsPausePannel.Length; i++)
            {
                //Debug.Log(EventSystem.currentSelectedGameObject);
                //Debug.Log(buttonsPausePannel[i]);
                if (EventSystem.currentSelectedGameObject == buttonsPausePannel[i].gameObject)
                {
                    imagesButtonPausePannel[i].material.SetFloat("_NoColorsWhiteValue", 1f);
                }
                if (EventSystem.currentSelectedGameObject != buttonsPausePannel[i].gameObject)
                {
                    imagesButtonPausePannel[i].material.SetFloat("_NoColorsWhiteValue", 0.3f);
                }
            }
        }
        else if (SceneManager.GetActiveScene().name == "LevelChoosing" || SceneManager.GetActiveScene().name == "Scenes/World/LevelChoosing")
        {
            if (GoLevelsButton != null && _levels != null)
            {
                for (int i = 0; i < GoLevelsButton.Length + 1; i++)
                {
                    if (EventSystem.currentSelectedGameObject == GoLevelsButton[i])//&& !bNowSelectedGeneral[i]
                    {
                        _levels[i].img_lvl.material.SetFloat("_NoColorsWhiteValue", 1f);
                    }
                    else if (EventSystem.currentSelectedGameObject == GoLevelBackButton)
                    {
                        GoLevelBackButton.GetComponent<UnityEngine.UI.Image>().material.SetFloat("_NoColorsWhiteValue", 1f);
                    }
                    else
                    {
                        _levels[i].img_lvl.material.SetFloat("_NoColorsWhiteValue", 0.3f);
                        GoLevelBackButton.GetComponent<UnityEngine.UI.Image>().material.SetFloat("_NoColorsWhiteValue", 0.3f);
                    }
                }
            }
        }
        else if (CgScoring.alpha == 1f)
        {
            for (int i = 0; i < 2; i++)
            {
                if (EventSystem.currentSelectedGameObject == ButtonsScoring[i].gameObject)//&& !bNowSelectedGeneral[i]
                {
                    ImageButtonsScoring[i].material.SetFloat("_NoColorsWhiteValue", 1f);
                }
                else
                {
                    ImageButtonsScoring[i].material.SetFloat("_NoColorsWhiteValue", 0.3f);
                }
            }
        }
        else if (CgOptionAudio.alpha == 1f)
        {
            for (int i = 0; i < 3; i++)
            {
                if (EventSystem.currentSelectedGameObject == SliderOptionAudio[i].gameObject)//&& !bNowSelectedAudio[i]
                {
                    /*bNowSelectedGeneral[i] = true;
                    if (iSelectedAudio > -1)
                    {
                        bNowSelectedAudio[iSelectedAudio] = false;
                        iSelectedAudio = i;
                    }
                    else
                    {
                        iSelectedAudio = i;
                    }*/
                    ImageSliderHandlerAudio[i].material.SetFloat("_NoColorsWhiteValue", 1f);
                }
                else if(EventSystem.currentSelectedGameObject == ButtonsOption[i].gameObject)
                {
                    ImageOption[i].material.SetFloat("_NoColorsWhiteValue", 1f);
                }
                else
                {
                    ImageOption[i].material.SetFloat("_NoColorsWhiteValue", 0.3f);
                    ImageSliderHandlerAudio[i].material.SetFloat("_NoColorsWhiteValue", 0.3f);
                }
                /*if (i < bNowSelectedGeneral.Length)
                {
                    bNowSelectedGeneral[i] = false;
                }
                iSelectedGeneral = -1;*/
            }
        }
        else if (CgOptionGeneral.alpha == 1f)
        {
            for (int i = 0; i < ImageButtonGeneral.Length; i++)
            {
                if (EventSystem.currentSelectedGameObject == ButtonOptionGeneral_[i].gameObject)//&& !bNowSelectedGeneral[i]
                {
                    /*bNowSelectedAudio[i] = true;
                    if (iSelectedGeneral > -1)
                    {
                        bNowSelectedAudio[iSelectedGeneral] = false;
                        iSelectedGeneral = i;
                    }
                    else
                    {
                        iSelectedGeneral = i;
                    }*/
                    ImageButtonGeneral[i].material.SetFloat("_NoColorsWhiteValue", 1f);
                }
                else if (i < ImageOption.Length && EventSystem.currentSelectedGameObject == ButtonsOption[i].gameObject)
                {
                    ImageOption[i].material.SetFloat("_NoColorsWhiteValue", 1f);
                }
                else
                {
                    if(i< ImageOption.Length)
                    {
                        ImageOption[i].material.SetFloat("_NoColorsWhiteValue", 0.3f);
                    }
                    ImageButtonGeneral[i].material.SetFloat("_NoColorsWhiteValue", 0.3f);
                }
                /*if (i < bNowSelectedAudio.Length)
                {
                    bNowSelectedAudio[i] = false;
                }
                iSelectedAudio = -1;*/
            }
        }
    }
    private void SelectionEnsurance()
    {
        if (EventSystem!=null && EventSystem.currentSelectedGameObject == null)
        {
            if(CgPauseMenu.alpha == 0f)
            {
                if (SceneManager.GetActiveScene().name == "LevelChoosing" || SceneManager.GetActiveScene().name == "Scenes/World/LevelChoosing")
                {
                    if(GoLevelsButton != null && GoLevelsButton[0]!=null)
                    {
                        EventSystem.SetSelectedGameObject(GoLevelsButton[0]);
                    }
                }
                else if ((SceneManager.GetActiveScene().name == "SceneSplash" || SceneManager.GetActiveScene().name == "Scenes/World/SceneSplash") && bMenuOnTriggered)
                {
                    if (GoGameChoose[0] != null)
                    {
                        EventSystem.SetSelectedGameObject(GoGameChoose[0]);
                    }
                }
            }
            else if (CgEndDialogue.alpha == 1f)
            {
                if (rectBoxTextImage.gameObject != null)
                {
                    EventSystem.SetSelectedGameObject(rectBoxTextImage.gameObject);
                    Debug.Log("ensurance for " + EventSystem.currentSelectedGameObject);
                }
            }
            else if(CgScoring.alpha == 1f)
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
            if (SceneManager.GetActiveScene().name == "LevelChoosing" || SceneManager.GetActiveScene().name == "Scenes/World/LevelChoosing")
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
            else if (SceneManager.GetActiveScene().name == "SceneSplash" || SceneManager.GetActiveScene().name == "Scenes/World/SceneSplash")
            {
                GoGameChoose = new GameObject[6];
                for (int i = 0; i < GoTargetUI.Length; i++)
                {
                    for (int y = 0; y < 4; y++)
                    {
                        if (GoTargetUI[i].name == "GameChoose" + y)
                        {
                            GoGameChoose[y] = GoTargetUI[i];
                        }
                    }
                    if (GoTargetUI[i].name == "Buttons")
                    {
                        GoGameChoose[4] = GoTargetUI[i];
                    }
                    else if (GoTargetUI[i].name == "PressAnyButtonImage")
                    {
                        GoGameChoose[5] = GoTargetUI[i];
                        if(bisOnCredits)
                        {
                            GoGameChoose[5].GetComponent<CanvasGroup>().alpha = 0f;
                        }
                        else
                        {
                            GoGameChoose[5].GetComponent<CanvasGroup>().alpha = 1f;
                        }
                    }
                    else if (GoTargetUI[i].name == "Spline")
                    {
                        trainMenu = GoTargetUI[i].transform.GetComponent< SplineTrainMover_WithSpacing>();
                        EventSystem = trainMenu._eventSystem;
                        this.GetComponent<Canvas>().worldCamera = trainMenu.camUI;
                        if (bisOnCredits)
                        {
                            trainMenu.cgCredits.alpha = 1f;
                            trainMenu.bStop = false;
                        }
                    }
                }
                GoGameChoose[5].transform.GetComponent<UnityEngine.UI.Image>().color = new Color32(255,255,255,255);
                GoGameChoose[4].transform.GetComponent<CanvasGroup>().alpha = 0f;
                //Init Train
                GoLevelsButton = null;
                _levels = null;
                sSceneToLoad = "Scenes/World/Loft"; 
                UnityEngine.UI.Button btnNewLoad = GoGameChoose[0].GetComponent<UnityEngine.UI.Button>();
                btnNewLoad.onClick.AddListener(delegate { LoadScene(sSceneToLoad); });
                UnityEngine.UI.Button btnCredits = GoGameChoose[2].GetComponent<UnityEngine.UI.Button>();
                btnCredits.onClick.AddListener(delegate { LoadScene("CreditsScene"); });
                UnityEngine.UI.Button btnExit = GoGameChoose[3].GetComponent<UnityEngine.UI.Button>();
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
        if(SceneManager.GetActiveScene().name == "Scenes/World/SceneSplash" || SceneManager.GetActiveScene().name == "SceneSplash")
        {
            bMenuOnTriggered = false;
            sSceneToLoad = "Scenes/World/Loft";
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
            if(bisOnCredits)
            {
                TextMeshProUGUI txt = trainMenu.txtChildrenCredits[0].gameObject.GetComponent<TextMeshProUGUI>();
                if (_playerData.iLanguageNbPlayer == 1)
                {
                    txt.text = "Merci d'avoir jou� !";
                }
                else
                {
                    txt.text = "Thanks for playing !";
                }
            }
        }
        else if(SceneManager.GetActiveScene().name == "Scenes/World/Loft" || SceneManager.GetActiveScene().name == "Loft")
        {
            sSceneToLoad = "Scenes/World/LevelChoosing";
        }
        else if(SceneManager.GetActiveScene().name == "Scenes/World/LevelChoosing" || SceneManager.GetActiveScene().name == "LevelChoosing")
        {
            for (int i = 0; i < GoLevelsButton.Length; i++)
            {
                GoLevelBackButton.GetComponent<UnityEngine.UI.Button>().onClick.AddListener(() => LoadScene("Scenes/World/Loft"));
                if ( _playerData.iLevelPlayer >= i) //Pour tous les niveaux faits
                {
                    int captured = i;
                    _levels[i].button_level.onClick.AddListener(() => LoadScene(_levels[captured].sScene_Level));
                    _levels[i].img_lvl.material = materialLevel_done;
                    TextMeshProUGUI textChild = _levels[i].Go_LevelButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(0, 255, 255, 255);
                    for(int y = 0; y< 5; y++)
                    {
                        GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().color = new Color32(255, 255, 255, 255);
                        if (_playerData.iStarsPlayer[5*i+y] ==1) //Si une �toile est faite ou non
                        {
                            GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().material = material_star_completed; ;
                        }
                        else
                        {
                            GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().material = material_star_empty;
                        }
                    }
                    if (i>0)
                    {
                        GoLevelStars[i].transform.GetChild(5).GetComponent<UnityEngine.UI.Image>().color = new Color32(0, 0, 0, 0);
                    }
                }
               else if(GoLevelsButton.Length- _playerData.iLevelPlayer > i) //Pour tous les niveaux non faits
               {
                    _levels[i].img_lvl.material = materialLevel_notDone;
                    TextMeshProUGUI textChild = _levels[i].Go_LevelButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(29, 217, 0, 255);
                    for (int y = 0; y < 5; y++)
                    {
                         GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().color = new Color32(0, 0, 0, 0);
                    }
                    GoLevelStars[i].transform.GetChild(5).GetComponent<UnityEngine.UI.Image>().color = new Color32(255, 255, 255, 255);
                }
            }
            EventSystem.SetSelectedGameObject(GoLevelsButton[0]);
        }
    }
    public IEnumerator ImuneToPause(BPM_Manager bpmmanager)
    {
        if(scPlayer.tutoGen ==null || (scPlayer.tutoGen != null && !scPlayer.tutoGen.bIsOnBD && !scPlayer.bisOnScoring))
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
        if (bpmManager.LoopInstance.isValid())
        {
            bpmManager.LoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
            bpmManager.LoopInstance.release();
        }
        bpmManager.isPlaying = false;
        if (SceneManager.GetActiveScene().name != "Loft"&& SceneManager.GetActiveScene().name != "Scenes/World/Loft")
        {
            ButtonSound();
        }
        if (sceneToLoad == "SceneLvl0" || sceneToLoad == "Scenes/World/SceneLvl0" || sceneToLoad == "SceneLvl1" || sceneToLoad == "Scenes/World/SceneLvl1" || sceneToLoad == "SceneLvl2" || sceneToLoad == "Scenes/World/SceneLvl2" || sceneToLoad == "SceneLvl3" || sceneToLoad == "Scenes/World/SceneLvl3")
        {
            StartCoroutine(StartLoad(sceneToLoad));
            for(int i =0; i<4; i++)
            {
                if(sceneToLoad == "SceneLvl" + i.ToString())
                {
                    iPreviousLevelPlayed = i;
                }
            }
            bpmManager.bIsOnLvl = true;
            bpmManager.bIsOnLoft = false;
        }
        else if(sceneToLoad == "Loft" || sceneToLoad == "Scenes/World/Loft")
        {
            bpmManager.bIsOnLoft = true;
            bpmManager.bIsOnLvl = false;
            StartCoroutine(StartLoad(sceneToLoad));
        }
        else if (sceneToLoad == "LevelChoosing" || sceneToLoad == "Scenes/World/LevelChoosing")
        {
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
            bpmManager.bIsOnLvl = false;
            Shader.SetGlobalFloat("BPM", 60f);
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
            EventSystem.SetSelectedGameObject(GoLevelsButton[0]);
            Shader.SetGlobalFloat("BPM", 60f);
            bpmManager.bIsOnLoft = false;
            bpmManager.bIsOnLvl = false;
            bpmManager.bInitialized[0] = false;
            bpmManager.bInitialized[1] = false;
            StartCoroutine(StartLoad(sceneToLoad));
        }
        else if(sceneToLoad == "CreditsScene" || sceneToLoad == "Scenes/World/CreditsScene")
        {
            bisOnCredits = true;
            bpmManager.bIsOnLvl = false;
            Shader.SetGlobalFloat("BPM", 60f);
            LoadScene("Scenes/World/SceneSplash");
        }
        else
        {
            Shader.SetGlobalFloat("BPM", 60f);
            StartCoroutine(StartLoad(sceneToLoad));
            bpmManager.bIsOnLoft = false;
            bpmManager.bIsOnLvl = false;
            bpmManager.bInitialized[0] = false;
            bpmManager.bInitialized[1] = false;
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
        if (sceneToLoad == "LevelChoosing" || sceneToLoad == "next")
        {
            EventSystem.SetSelectedGameObject(GoLevelsButton[0]);
            Shader.SetGlobalFloat("BPM", 60f);
        }
        else if (sceneToLoad == "SceneSplash" || sceneToLoad == "CreditsScene")
        {
            Shader.SetGlobalFloat("BPM", 60f);
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
        if (controllerConnected && control !=null && control.GamePlay.Pausing.triggered && (SceneManager.GetActiveScene().name != "SceneSplash"&& SceneManager.GetActiveScene().name != "Scenes/World/SceneSplash"))
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
        if (controllerConnected && CgOptionPannel.alpha == 1f)
        {
            CheckCurrentSelectable();
            if (CgOptionAudio.alpha == 1f && !bOnceOptions[0])
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
            else if (CgOptionGeneral.alpha == 1f && !bOnceOptions[1])
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
            else if (CgOptionGeneral.alpha == 1f && !bOnceOptions[2])
            {
                if (_playerData.iLanguageNbPlayer == 0) //english
                {
                    ImageButtonGeneral[0].material = M_materialButtonGeneral[0];
                }
                else
                {
                    ImageButtonGeneral[0].material = M_materialButtonGeneral[1];
                }
                if (iDifficulty == 0) //hard
                {
                    ImageButtonGeneral[1].material = M_materialButtonGeneral[2];
                }
                else if (iDifficulty == 2)//easy
                {
                    ImageButtonGeneral[1].material = M_materialButtonGeneral[4];
                }
                if(_playerData.iGrid==1) //true
                {
                    ImageButtonGeneral[2].material = M_materialButtonGeneral[5];
                }
                else
                {
                    ImageButtonGeneral[2].material = M_materialButtonGeneral[6];
                }
                if(bWithNotes)
                {
                    ImageButtonGeneral[3].material = M_materialButtonGeneral[7];
                }
                else
                {
                    ImageButtonGeneral[3].material = M_materialButtonGeneral[8];
                }
                bOnceOptions[2] = true;
            }
            if(scPlayer!=null && scPlayer.tutoGen!=null && scPlayer.tutoGen.bIsOnBD)
            {
                scPlayer.tutoGen.GetComponent<CanvasGroup>().alpha = 0f;
            }
        }
        else if (controllerConnected && CgPauseMenu.alpha == 1f)
        {
            CheckCurrentSelectable();
            if (scPlayer != null && scPlayer.tutoGen != null && scPlayer.tutoGen.bIsOnBD)
            {
                scPlayer.tutoGen.GetComponent<CanvasGroup>().alpha = 0f;
            }
        }
        else if (controllerConnected && CgEndDialogue.alpha == 1f)
        {
            CheckCurrentSelectable();
        }
        else if (controllerConnected && CgScoring.alpha == 1f)
        {
            CheckCurrentSelectable();
        }
        if(bIsOnEndDialogue)
        {
            CgLoadingScreen.alpha = 0f;
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
            if ((scPlayer != null && scPlayer.bisTuto == true && (SceneManager.GetActiveScene().name != "Loft"&& SceneManager.GetActiveScene().name != "Scenes/World/Loft")) || (scPlayer != null && CgScoring.alpha == 1f) || (scPlayer != null && CgEndDialogue.alpha == 1f))
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
            else if((SceneManager.GetActiveScene().name == "SplashScreen" || SceneManager.GetActiveScene().name == "Scenes/World/SplashScreen")&& bMenuOnTriggered)
            {
                EventSystem.SetSelectedGameObject(GoGameChoose[0]);
            }
            else if (SceneManager.GetActiveScene().name == "LevelChoosing" || SceneManager.GetActiveScene().name == "Scenes/World/LevelChoosing")
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
            if (scPlayer != null && scPlayer.tutoGen != null && scPlayer.tutoGen.bIsOnBD)
            {
                scPlayer.tutoGen.GetComponent<CanvasGroup>().alpha = 1f;
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
    public void CloseOptions(bool bonManager)
    {
        if ((SceneManager.GetActiveScene().name != "SceneSplash" && SceneManager.GetActiveScene().name != "Scenes/World/SceneSplash")&& bonManager)
        {
            CgPauseMenu.alpha = 1f;
            bActif = true;
            CgPauseMenu.blocksRaycasts = true;
            CgPauseMenu.interactable = true;
            RtPauseMenu.anchorMin = new Vector2(0, 0);
            RtPauseMenu.anchorMax = new Vector2(1, 1);
            RtPauseMenu.offsetMax = new Vector2(0f, 0f);
            RtPauseMenu.offsetMin = new Vector2(0f, 0f);
            EventSystem.SetSelectedGameObject(GoPausedFirstButtonSelected);
        }
        else if(SceneManager.GetActiveScene().name == "SceneSplash" || SceneManager.GetActiveScene().name == "Scenes/World/SceneSplash")
        {
            EventSystem.SetSelectedGameObject(GoGameChoose[0]);
        }
        ButtonSound();
        CgOptionPannel.alpha = 0f;
        CgOptionPannel.interactable = false;
        CgOptionPannel.blocksRaycasts = false;
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
            ImageButtonGeneral[1].material = M_materialButtonGeneral[3];
        }
        else if(iDifficulty == 1)
        {
            iDifficulty = 2;
            ImageButtonGeneral[1].material = M_materialButtonGeneral[4];
        }
        else
        {
            iDifficulty = 0;
            ImageButtonGeneral[1].material = M_materialButtonGeneral[2];
        }
        if (scPlayer!=null && scPlayer.bpmManager!=null)
        {
            scPlayer.bpmManager.StartBPMPlayer();
        }
    }
    public void WithNotes()
    {
        ButtonSound();
        if (bWithNotes)
        {
            bWithNotes = false;
            ImageButtonGeneral[3].material = M_materialButtonGeneral[8];
            if(scPlayer!=null && scPlayer.goNotesBg != null && scPlayer.goNoteParent != null)
            {
                scPlayer.goNotesBg.SetActive(true);
                scPlayer.goNoteParent[0].SetActive(true);
                scPlayer.goNoteParent[1].SetActive(true);
            }
        }
        else
        {
            bWithNotes = true;
            ImageButtonGeneral[3].material = M_materialButtonGeneral[7];
            if(scPlayer!=null && scPlayer.goNotesBg!=null && scPlayer.goNoteParent!=null)
            {
                scPlayer.goNotesBg.SetActive(false);
                scPlayer.goNoteParent[0].SetActive(false);
                scPlayer.goNoteParent[1].SetActive(false);
            }
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
        if(SceneManager.GetActiveScene().name == "SceneSplash" || SceneManager.GetActiveScene().name == "Scenes/World/SceneSplash")
        {
            TrainSplashLanguage();
        }
    }
    public void GridButton()
    {
        if(_playerData.iGrid == 1)
        {
            _playerData.iGrid = 0; //false
            ImageButtonGeneral[2].material = M_materialButtonGeneral[6];
            if(scPlayer!=null && scPlayer.go_Grid != null)
            {
                scPlayer.go_Grid.SetActive(false);
            }
        }
        else
        {
            _playerData.iGrid = 1; //true
            ImageButtonGeneral[2].material = M_materialButtonGeneral[5];
            if (scPlayer != null && scPlayer.go_Grid!=null)
            {
                scPlayer.go_Grid.SetActive(true);
            }
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
    public void SetMusicVolume(float fChanger)
    {
        if(fChanger==0f)
        {
            playerMusicVolume = MusicSlider.value;
            if (!music_VCA.isValid())
            {
                Debug.LogWarning("VCA is not valid! Check FMOD path.");
                music_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_basic");
                sfxVCA = FMODUnity.RuntimeManager.GetVCA("vca:/SFX");
                ambianceVCA = FMODUnity.RuntimeManager.GetVCA("vca:/Ambiance");
                if (!music_VCA.isValid())
                {
                    Debug.LogError("VCA is STILL!!!! not valid!");
                    return;
                }
            }
            if (SceneManager.GetActiveScene().name == "SceneLvl0" || SceneManager.GetActiveScene().name == "Scenes/World/SceneLvl0" || SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "Scenes/World/SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl2" || SceneManager.GetActiveScene().name == "Scenes/World/SceneLvl2" || SceneManager.GetActiveScene().name == "SceneLvl3" || SceneManager.GetActiveScene().name == "Scenes/World/SceneLvl3")
            {
                music_VCA.setVolume(playerMusicVolume);
            }
            else
            {
                music_VCA.setVolume(playerMusicVolume);
            }
        }
        else
        {
            playerMusicVolume = MusicSlider.value;
            if (!music_VCA.isValid())
            {
                Debug.LogWarning("VCA is not valid! Check FMOD path.");
                music_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_basic");
                sfxVCA = FMODUnity.RuntimeManager.GetVCA("vca:/SFX");
                ambianceVCA = FMODUnity.RuntimeManager.GetVCA("vca:/Ambiance");
                if (!music_VCA.isValid())
                {
                    Debug.LogError("VCA is STILL!!!! not valid!");
                    return;
                }
            }
            if (SceneManager.GetActiveScene().name == "SceneLvl0" || SceneManager.GetActiveScene().name == "Scenes/World/SceneLvl0" || SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "Scenes/World/SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl2" || SceneManager.GetActiveScene().name == "Scenes/World/SceneLvl2" || SceneManager.GetActiveScene().name == "SceneLvl3" || SceneManager.GetActiveScene().name == "Scenes/World/SceneLvl3")
            {
                music_VCA.setVolume(playerMusicVolume* fChanger);
            }
            else
            {
                music_VCA.setVolume(playerMusicVolume * fChanger);
            }
        }
    }
    public void SetAmbianceVolume()
    {
        ambianceVCA = FMODUnity.RuntimeManager.GetVCA("vca:/Ambiance");
        float volume = AmbianceSlider.value;
        ambianceVCA.setVolume(volume);
    }
    public void SetSFXVolume()
    {
        sfxVCA = FMODUnity.RuntimeManager.GetVCA("vca:/SFX");
        float volume = SfxSlider.value;
        sfxVCA.setVolume(volume);
    }
    public void PauseGame()
    {
        if (bGameIsPaused)
        {
            //Time.timeScale = 0f;
            if (scPlayer != null && scPlayer.bisTuto == false)
            {
                music_VCA.getVolume(out float currentVolume); // Get current volume
                //bpmManager.playerLoopInstance.setParameterByName("fPausedVolume", 0.8f);
            }
        }
        else
        {
            //Time.timeScale = 1f;
            music_VCA.setVolume(playerMusicVolume);
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
            foreach (UnityEngine.UI.Image stars in ImageStars)
            {
                stars.color = new Color32(255, 255, 255, 0);
            }
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
        if(iLevelDialogue == 4)
        {
            imageEnding.material = M_ImageEndings[1];
            if (iNbTextNow == iNbDialoguePerLevelAdd[iLevel]-1)
            {
                imageEnding.color = new Color32(255,255,255,255);
            }
        }
        else
        {
            imageEnding.color = new Color32(255, 255, 255, 0);
        }
    }
    private void SetSpeaker(int speakingCharacterIndex, int notSpeakingCharacterIndex, int iLevel) //on connait le numero du character mais est-il � gauche ou � droite?
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
            if (a != -1)
            {
                imgBoxText.sprite = spritesCharactersBoxesRight[a];
            }
            imgBoxText.color = new Color32(255, 255, 255, 255);
            if (speakingCharacterIndex != -1)
            {
                imgCharactersSpace[0].sprite = spritesEndDialogueCharacters[speakingCharacterIndex]; // Le sprite de droite est rempli par le sprite du chara qui est � droite en fonction du lvl
                imgCharactersSpace[1].sprite = spritesEndDialogueCharactersNotSpeak[notSpeakingCharacterIndex];// Le sprite de gauche est rempli par le sprite du chara qui est � gauche en fonction du lvl
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
            if (a != -1)
            {
                imgBoxText.sprite = spritesCharactersBoxesLeft[a];
            }
            imgBoxText.color = new Color32(255, 255, 255, 255);
            if (notSpeakingCharacterIndex != -1)
            {
                imgCharactersSpace[0].sprite = spritesEndDialogueCharactersNotSpeak[notSpeakingCharacterIndex]; // Le sprite de droite est rempli par le sprite du chara qui est � droite en fonction du lvl
                imgCharactersSpace[1].sprite = spritesEndDialogueCharacters[speakingCharacterIndex];// Le sprite de gauche est rempli par le sprite du chara qui est � gauche en fonction du lvl
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

        Time.timeScale = 1f;
        if (_playerData.iLevelPlayer >= 4 && (SceneManager.GetActiveScene().name == "SceneLvl3" || SceneManager.GetActiveScene().name == "Scenes/World/SceneLvl3"))
        {
            LoadScene("Scenes/World/CreditsScene");
            bisOnCredits = true;
        }
        else
        {
            LoadScene("Scenes/World/LevelChoosing");
        }
    }
}
