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
using UnityEngine.UIElements;

public class MenuManager : MonoBehaviour
{
    public EventSystem EventSystem;
    public SC_Player scPlayer;
    public bool bGameIsPaused = false;
    private sc_levelChoosing_ _scLevels;
    public int iPreviousLevelPlayed = 0;

    //NAVIGATION UX
    [Header("Controller")]
    public PlayerControl control;
    public bool controllerConnected = false;
    private bool bWaitController = false;
    public CanvasGroup CgControllerWarning;
    public RectTransform RtControllerWarning;

    //NAVIGATION UX
    [Header("Options General")]
    private bool[] bOnce = new bool[2] { false, false };
    [SerializeField] private GameObject GoOptionGeneralFirstButtonSelected;
    [SerializeField] private UnityEngine.UI.Selectable ButtonOptionGeneral;
    [SerializeField] private UnityEngine.UI.Button[] ButtonsOptionGeneral_fromGeneral;
    [SerializeField] private UnityEngine.UI.Button[] ButtonsOptionAudio_fromGeneral;
    [SerializeField] private GameObject GoOptionAudioButton;
    [SerializeField] private UnityEngine.UI.Selectable ButtonOptionAudio;
    [SerializeField] private UnityEngine.UI.Button[] ButtonsOptionGeneral_fromAudio;
    [SerializeField] private UnityEngine.UI.Button[] ButtonsOptionAudio_fromAudio;
    [SerializeField] private UnityEngine.UI.Slider[] SliderOptionAudio;
    public CanvasGroup CgOptionPannel;
    public RectTransform RtOptionPannel;
    public CanvasGroup CgOptionGeneral;
    public int iDifficulty = 0;
    [SerializeField] private EventReference[] sfx_ui_button;

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

    //NAVIGATION UX
    [Header("Navigation UX")]
    private GameObject GoMainMenu;
    private GameObject[] GoGameChoose; //0 is GoNewLoadButton, 1 is GoNewLoadText, 2 is GoOptionsButton, 3 is GoExitButton
    public GameObject[] GoLevelsButton;
    private GameObject GoLevelBackButton;
    public GameObject[] GoLevelStars;
    public Sprite sprite_star_completed;
    public Sprite sprite_star_empty;
    [SerializeField] private GameObject GoPauseMenu;
    public CanvasGroup CgPauseMenu;
    [SerializeField] private RectTransform RtPauseMenu;
    private bool bActif = false;
    [SerializeField] private Sprite spriteLevel_done;
    [SerializeField] private Sprite spriteLevel_notDone;
    [SerializeField] private Color32 colorFoes;
    [SerializeField] private Color32 colorPlayer;
    public GameObject GoScoringFirstButtonSelected;
    [SerializeField] private GameObject GoPausedFirstButtonSelected;

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

    [Header("EndDialogue")]
    public CanvasGroup CgEndDialogue;
    public RectTransform RtEndDialogue;
    public UnityEngine.UI.Image ImgEndDialogueBackground;
    [Tooltip("int from the chara to be on the right, then on the left, for each levels")][SerializeField] private int[] iWhichCharaToRightToLeft;
    public Sprite[] spritesEndDialogueBackground;
    public Sprite[] spritesEndDialogueCharacters;
    [Tooltip("0 is right, 1 is left.")][SerializeField] private UnityEngine.UI.Image[] imgCharactersSpace;
    public bool bIsOnEndDialogue = false;

    [Header("EndDialogueDetails")]
    private int iNbTextNow = 0;
    [Tooltip("0 is right, 1 is left.")][SerializeField] private RectTransform[] charactersImages;
    [SerializeField] private RectTransform rectBoxTextImage;
    [SerializeField] private UnityEngine.UI.Image imgBoxText;
    [Tooltip("0 is the 1st character's boxe,  1 is the other, 2 is the last.")][SerializeField] private Sprite[] spritesCharactersBoxes;
    [SerializeField] private sc_textChange _sc_textChange;
    [SerializeField] private int[] iNbDialoguePerLevel;
    [SerializeField] private int[] iNbDialoguePerLevelAdd;
    [Tooltip("0 is the 1st,  1 is the other, 2 is the last.")] public int[] iCharaToSpeakPerTextes;
    [Tooltip("0 is the 1st,  1 is the other, 2 is the last.")] private int[] iCharaToNotSpeakPerTextes;
    [SerializeField] private string[] sDialogueEnglish;
    [SerializeField] private string[] sDialogueFrench;
    public bool bWaitNextDialogue = false;

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
    [SerializeField] private EventReference menuLoop;
    private FMOD.Studio.EventInstance menuLoopInstance;
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
        DontDestroyOnLoad(this.gameObject);
        if (FindObjectsOfType<MenuManager>().Length > 1)
        {
            Destroy(this);
        }
        //control = new PlayerControl();
        EventSystem = GameObject.FindObjectOfType<EventSystem>();
        isLoadingScene = false;
    }
    private void Start()
    {
        UnityEngine.Cursor.lockState = CursorLockMode.Locked;
        if (SceneManager.GetActiveScene().name == "MainMenu"|| SceneManager.GetActiveScene().name == "LevelChoosing")
        {
            if (menuLoopInstance.isValid())
            {
                menuLoopInstance.getPlaybackState(out PLAYBACK_STATE state);
                if (state != PLAYBACK_STATE.STOPPED) return; // Only create a new instance if it's actually stopped
            }

            // Create and start the instance
            menuLoopInstance = RuntimeManager.CreateInstance(menuLoop);
            menuLoopInstance.start();
            menuLoopInstance.setParameterByName("fPausedVolume", 0.8f);

            isPlaying = true;
        }
        music_basic_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_basic");
        music_beat_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_beat");
        music_detected_VCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music_detected");
        sfxVCA = FMODUnity.RuntimeManager.GetVCA("vca:/SFX");
        ambianceVCA = FMODUnity.RuntimeManager.GetVCA("vca:/Ambiance");
        SetMusicVolume();
        SetSFXVolume();
    }
    // Update is called once per frame
    void Update()
    {
        CheckControllerStatus();
        if (GoMainMenu != null && controllerConnected && control !=null && control.GamePlay.Move.triggered)
        {
            LoadScene(sSceneToLoad);
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
        CheckDialogue();
    }
    //CHECKS AND UI CHANGES
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
            if (SceneManager.GetActiveScene().name == "MainMenu")
            {
                GoMainMenu = GoTargetUI[0];
                GoGameChoose = null;
                GoLevelsButton = null;
                sSceneToLoad = "GameChoose";
                _levels = null;
            }
            else if (SceneManager.GetActiveScene().name == "GameChoose")
            {
                GoGameChoose = new GameObject[GoTargetUI.Length];
                for (int i = 0; i < GoTargetUI.Length; i++)
                {

                    for (int y = 0; y < GoTargetUI.Length; y++)
                    {
                        if (GoTargetUI[i].name == "GameChoose" + y)
                        {
                            GoGameChoose[y] = GoTargetUI[i];
                        }
                    }
                }
                GoMainMenu = null;
                GoLevelsButton = null;
                _levels = null;
                sSceneToLoad = "Loft";
            }
            else if (SceneManager.GetActiveScene().name == "LevelChoosing")
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
                GoMainMenu = null;
                GoGameChoose = null;
                sSceneToLoad = "SceneLvl";
            }
        }
        else
        {
            GoMainMenu = null;
            GoGameChoose = null;
            GoLevelsButton = null;
        }
        if(SceneManager.GetActiveScene().name == "GameChoose")
        {
            UnityEngine.UI.Button btnNewLoad = GoGameChoose[0].GetComponent<UnityEngine.UI.Button>();
            btnNewLoad.onClick.AddListener(delegate { LoadScene(sSceneToLoad); });
            if (_playerData.iLevelPlayer > 0)
            {
                TextMeshProUGUI txt = GoGameChoose[0].gameObject.transform.GetChild(0).gameObject.GetComponent<TextMeshProUGUI>();
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
                TextMeshProUGUI txt = GoGameChoose[0].gameObject.transform.GetChild(0).gameObject.GetComponent<TextMeshProUGUI>();
                if (_playerData.iLanguageNbPlayer == 1)
                {
                    txt.text = "Nouvelle Partie";
                }
                else
                {
                    txt.text = "New Game";
                }
            }
            UnityEngine.UI.Button btnExit = GoGameChoose[2].GetComponent<UnityEngine.UI.Button>();
            btnExit.onClick.AddListener(QuitGame);
            UnityEngine.UI.Button btnOptions = GoGameChoose[1].GetComponent<UnityEngine.UI.Button>();
            btnOptions.onClick.AddListener(OptionsGame);
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
                    }
                    else
                    {
                        _levels[i].img_lvl.sprite = spriteLevel_notDone;
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
        if (SceneManager.GetActiveScene().name != "Loft" && SceneManager.GetActiveScene().name != "MainMenu")
        {
            ButtonSound();
        }

        if (sceneToLoad == "SceneLvl0" || sceneToLoad == "SceneLvl1" || sceneToLoad == "Loft" || sceneToLoad == "SceneLvl2" || sceneToLoad == "SceneLvl3")
        {
            menuLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
            menuLoopInstance.release();
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
        else if (sceneToLoad == "LevelChoosing")
        {
            if (menuLoopInstance.isValid()) return; // Prevent multiple instances

            menuLoopInstance = RuntimeManager.CreateInstance(menuLoop);

            if (!isPlaying)
            {
                menuLoopInstance.start();
                isPlaying = true;
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
        EventSystem = GameObject.FindObjectOfType<EventSystem>();
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
            if(CgOptionAudio.alpha ==1f && !bOnce[0])
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
                bOnce[0] = true;
            }
            else if(CgOptionGeneral.alpha == 1f && !bOnce[1])
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
                bOnce[1] = true;
            }
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
            GoPausedFirstButtonSelected.GetComponent<UnityEngine.UI.Button>().Select();
            bGameIsPaused = true;
            PauseGame();
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
            CloseOptions();
            if ((scPlayer != null && scPlayer.bisTuto == true && SceneManager.GetActiveScene().name != "Loft") || (scPlayer != null && CgScoring.alpha == 1f))
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
            else if(SceneManager.GetActiveScene().name == "GameChoose")
            {
                EventSystem.SetSelectedGameObject(GoGameChoose[0]);
            }
            else if (SceneManager.GetActiveScene().name == "LevelChoosing")
            {
                EventSystem.SetSelectedGameObject(GoLevelsButton[0]);
            }
            else
            {
                EventSystem.SetSelectedGameObject(null);
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
            bOnce[0] = false;
            CgOptionAudio.alpha = 0f;
            CgOptionAudio.interactable = false;
            CgOptionAudio.blocksRaycasts = false;
            CgOptionGeneral.alpha = 1f;
            CgOptionGeneral.interactable = true;
            CgOptionGeneral.blocksRaycasts = true;
        }
        else
        {
            bOnce[1] = false;
            CgOptionGeneral.alpha = 0f;
            CgOptionGeneral.interactable = false;
            CgOptionGeneral.blocksRaycasts = false;
            CgOptionAudio.alpha = 1f;
            CgOptionAudio.interactable = true;
            CgOptionAudio.blocksRaycasts = true;
        }
    }
    public void CloseOptions()
    {
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
        ButtonSound();
        if (iDifficulty < 2)
        {
            iDifficulty += 1; 
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
        ButtonSound();
        if (_playerData.iLanguageNbPlayer == 1)
        {
            _playerData.iLanguageNbPlayer = 0;
        }
        else
        {
            _playerData.iLanguageNbPlayer = 1;
        }
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
        if (!music_basic_VCA.isValid() && !music_beat_VCA.isValid() && !music_detected_VCA.isValid())
        {
            Debug.LogError("VCA is not valid! Check FMOD path.");
            return;
        }
        if (SceneManager.GetActiveScene().name == "SceneLvl0" || SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl2" || SceneManager.GetActiveScene().name == "SceneLvl3" || SceneManager.GetActiveScene().name == "Loft")
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
    private void CheckDialogue()
    {
        if (bIsOnEndDialogue && bWaitNextDialogue && controllerConnected && control.GamePlay.Move.triggered)
        {
            bWaitNextDialogue = false;
            BeginDialogue(false);
        }
    }
    public void BeginDialogue(bool first)
    {
        if (first ==true)
        {
            bIsOnEndDialogue = true;
        }
        if (iNbTextNow == iNbDialoguePerLevel[iPreviousLevelPlayed] -1)
        {
            EndDialogue();
            bIsOnEndDialogue = false;
        }
        else
        {
            NextBox(_playerData.iLanguageNbPlayer, first, iPreviousLevelPlayed);
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
                iCharaToNotSpeakPerTextes = new int[iCharaToSpeakPerTextes.Length];
            }
            else
            {
                iNbTextNow = iNbDialoguePerLevel[iLevel - 1];
            }
            SetCharacters(iLevel);
        }
        SetSpeaker(iCharaToSpeakPerTextes[iNbTextNow], iLevel);
        if (iLanguage == 0)
        {
            _sc_textChange.StartWriting(sDialogueEnglish[iNbTextNow]);
        }
        else
        {
            _sc_textChange.StartWriting(sDialogueFrench[iNbTextNow]);
        }
    }
    private void SetCharacters(int iLevel)
    {
        imgCharactersSpace[0].sprite = spritesEndDialogueCharacters[iWhichCharaToRightToLeft[iLevel * 2]]; // Le sprite de droite est rempli par par le sprite du chara qui est à droite en fonction du lvl
        imgCharactersSpace[1].sprite = spritesEndDialogueCharacters[iWhichCharaToRightToLeft[iLevel*2+1]];// Le sprite de gauche est rempli par par le sprite du chara qui est à gauche en fonction du lvl
        if(iLevel - 1 == -1)
        {
            for (int i = 0; i < iNbDialoguePerLevel[0]; i++)
            {
                if(iCharaToSpeakPerTextes[i] == iWhichCharaToRightToLeft[iLevel * 2 + 1])
                {
                    iCharaToNotSpeakPerTextes[i] = iWhichCharaToRightToLeft[iLevel * 2];
                }
                else
                {
                    iCharaToNotSpeakPerTextes[i] = iWhichCharaToRightToLeft[iLevel * 2+1];
                }
            }
        }
        else
        {
            for (int i = iNbDialoguePerLevelAdd[iLevel-1]; i < iNbDialoguePerLevelAdd[iLevel]; i++)
            {
                if (iCharaToSpeakPerTextes[i] == iWhichCharaToRightToLeft[iLevel * 2 + 1])
                {
                    iCharaToNotSpeakPerTextes[i] = iWhichCharaToRightToLeft[iLevel * 2];
                }
                else
                {
                    iCharaToNotSpeakPerTextes[i] = iWhichCharaToRightToLeft[iLevel * 2 + 1];
                }
            }
        }
    }
    private void SetSpeaker(int speakingCharacterIndex, int iLevel) //on connait le numero du character mais est-il à gauche ou à droite?
    {
        // Change the text box to the one of the character speaking
        imgBoxText.sprite = spritesCharactersBoxes[speakingCharacterIndex];
        //Is right or left character speaking ? 
        if (iWhichCharaToRightToLeft[iLevel * 2] == speakingCharacterIndex) //Le sprite de droite est-il celui du chara qui parle ?
        {
            // Non-speaking character goes below
            charactersImages[1].SetSiblingIndex(0);
            // Ensure the dialogue box is at index 1 (middle layer)
            rectBoxTextImage.SetSiblingIndex(1);
            // Speaking character goes above
            charactersImages[0].SetSiblingIndex(2); //Alors le character de droite est devant

            rectBoxTextImage.anchorMin = new Vector2(0f, 0);
            rectBoxTextImage.anchorMax = new Vector2(0.8f, 0.4f);
            rectBoxTextImage.offsetMax = new Vector2(0f, 0f);
            rectBoxTextImage.offsetMin = new Vector2(0f, 0f);
        }
        else
        {
            // Non-speaking character goes below
            charactersImages[0].SetSiblingIndex(0);
            // Ensure the dialogue box is at index 1 (middle layer)
            rectBoxTextImage.SetSiblingIndex(1);
            // Speaking character goes above
            charactersImages[1].SetSiblingIndex(2);//Sinon le character de gauche est devant

            rectBoxTextImage.anchorMin = new Vector2(0.2f, 0);
            rectBoxTextImage.anchorMax = new Vector2(1f, 0.4f);
            rectBoxTextImage.offsetMax = new Vector2(0f, 0f);
            rectBoxTextImage.offsetMin = new Vector2(0f, 0f);
        }
    }
    private void EndDialogue()
    {
        CgEndDialogue.alpha = 0f;
        CgEndDialogue.blocksRaycasts = false;
        RtEndDialogue.anchorMin = new Vector2(0, 1);
        RtEndDialogue.anchorMax = new Vector2(1, 2);
        RtEndDialogue.offsetMax = new Vector2(0f, 0f);
        RtEndDialogue.offsetMin = new Vector2(0f, 0f);
        scPlayer.EndGame(true, _playerData);
    }
}
