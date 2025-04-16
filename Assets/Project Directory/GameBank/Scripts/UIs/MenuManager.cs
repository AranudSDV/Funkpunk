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
    public PlayerControl control;
    public EventSystem EventSystem;
    public bool controllerConnected = false;
    public SC_Player scPlayer;
    public bool bGameIsPaused = false;

    [Header("Sound")]
    public FMOD.Studio.VCA musicVCA;
    public FMOD.Studio.VCA sfxVCA;
    public float playerMusicVolume = 1f;
    public CanvasGroup CgSoundManager;
    public RectTransform RtSoundManager;
    [SerializeField] private UnityEngine.UI.Slider SfxSlider;
    [SerializeField] private UnityEngine.UI.Slider MusicSlider;

    //NAVIGATION UX
    [Header("Navigation UX")]
    private GameObject GoMainMenu;
    private GameObject[] GoGameChoose; //0 is GoNewLoadButton, 1 is GoNewLoadText, 2 is GoOptionsButton, 3 is GoExitButton
    public GameObject[] GoLevelsButton;
    private GameObject GoLevelBackButton;
    public GameObject[] GoLevelStars;
    [SerializeField] private GameObject GoPauseMenu;
    public CanvasGroup CgPauseMenu;
    [SerializeField] private RectTransform RtPauseMenu;
    private bool bActif = false;
    [SerializeField] private Color32 colorFoes;
    [SerializeField] private Color32 colorPlayer;
    public GameObject GoScoringFirstButtonSelected;
    [SerializeField] private GameObject GoPausedFirstButtonSelected;

    //SCORING
    [Header("Scoring")]
    [SerializeField] private GameObject GoScoring;
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

    //SCENE LOADING
    [Header("Loading Scene")]
    public string sSceneToLoad;
    public static bool isLoadingScene = false;
    [SerializeField] private UnityEngine.UI.Slider progressBar;
    [SerializeField] private GameObject loadingScreen;
    [SerializeField] private CanvasGroup CgLoadingScreen;
    [SerializeField] private RectTransform RtLoadingScreen;
    private AsyncOperation loadingOperation;

    //DATA PLAYER
    [Header("Datas")]
    private PlayerData _playerData;
    public Level[] _levels;
    [SerializeField] private EventReference menuLoop;
    private FMOD.Studio.EventInstance menuLoopInstance;
    private bool isPlaying = false; // Prevent multiple starts
    //DATA LEVEL
    public int[] iNbTaggs = new int[4];

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
    void OnEnable()
    {
        if (controllerConnected)
        {
            control = new PlayerControl();
            control.GamePlay.Enable();
        }
    }
    void OnDisable()
    {
        if (controllerConnected)
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
        if (SceneManager.GetActiveScene().name == "MainMenu")
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
        musicVCA = FMODUnity.RuntimeManager.GetVCA("vca:/Music");
        sfxVCA = FMODUnity.RuntimeManager.GetVCA("vca:/SFX");
        Debug.Log(musicVCA.isValid() ? "VCA Loaded!" : "VCA Failed to Load!");
        SetMusicVolume();
        SetSFXVolume();
    }
    // Update is called once per frame
    void Update()
    {
        CheckControllerStatus();
        if (GoMainMenu != null && GoMainMenu.transform.GetComponent<MainMenuNameChanging>().isOk && ((Input.anyKeyDown && !(Input.GetMouseButtonDown(0)|| Input.GetMouseButtonDown(1) || Input.GetMouseButtonDown(2) || Input.GetKeyDown(KeyCode.J)) && !controllerConnected) || (controllerConnected && control.GamePlay.Move.triggered)))
        {
            LoadScene(sSceneToLoad);
        }
        UXNavigation();
        if (isLoadingScene)
        {
            progressBar.value = Mathf.Clamp01(loadingOperation.progress / 0.9f);
        }
        //Racourcis
        if(Input.GetKeyDown(KeyCode.J))
        {
            Debug.Log("passer le niveau 1");
            _playerData.iLevelPlayer = 1;
            _playerData.iScorePerLvlPlayer[0] = 70;
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
            }
            else
            {
                Debug.Log("No controllers connected!");
            }
        }
    }
    private void UXNavigation()
    {
        if ((Input.GetKey(KeyCode.Escape)|| (controllerConnected && control.GamePlay.Pausing.triggered)))
        {
            PauseMenu();
        }
        /*else if((GoPauseMenu.activeInHierarchy == false && GoScoring == null) || (GoPauseMenu.activeInHierarchy==false && GoScoring.activeInHierarchy == false))
        {
            if(SceneManager.GetActiveScene().name == "GameChoose")
            {
                EventSystem.firstSelectedGameObject = GoGameChoose[0];
            }
            else if (SceneManager.GetActiveScene().name == "LevelChoosing")
            {
                EventSystem.firstSelectedGameObject = GoLevelsButton[0];
            }
        }*/
    }
    public void PauseMenu()
    {
        if (CgPauseMenu.alpha == 0f && !bActif) // On ouvre la fenetre, le jeu est en pause
        {
            CgPauseMenu.alpha = 1f;
            CgPauseMenu.interactable = true;
            RtPauseMenu.anchorMin = new Vector2(-0.5f, 0);
            RtPauseMenu.anchorMax = new Vector2(1.5f, 1);
            RtPauseMenu.offsetMax = new Vector2(0f, 0f);
            RtPauseMenu.offsetMin = new Vector2(0f, 0f);
            EventSystem.firstSelectedGameObject = GoPausedFirstButtonSelected; 
            GoPausedFirstButtonSelected.GetComponent<UnityEngine.UI.Button>().Select();
            if (controllerConnected)
            {
                UnityEngine.Cursor.lockState = CursorLockMode.Locked;
            }
            else
            {
                UnityEngine.Cursor.lockState = CursorLockMode.None;
            }
            bGameIsPaused = true;
            PauseGame();
            StartCoroutine(wait());
        }
        else if (CgPauseMenu.alpha == 1f && bActif) // On ferme la fenetre, le jeu reprend
        {
            CgPauseMenu.alpha = 0f;
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
            if (!controllerConnected && SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "LevelChoosing" && SceneManager.GetActiveScene().name != "MainMenu") //SI keyboard et mouse et que la scene n'est pas un menu avec souris
            {
                UnityEngine.Cursor.lockState = CursorLockMode.Locked;
            }
            else if(!controllerConnected && (SceneManager.GetActiveScene().name == "GameChoose" || SceneManager.GetActiveScene().name == "LevelChoosing" || SceneManager.GetActiveScene().name == "MainMenu")) //si keyboard er que la scene est un menu avec souris
            {
                UnityEngine.Cursor.lockState = CursorLockMode.None;
            }
            else if (controllerConnected) //si controlleur gamepad
            {
                UnityEngine.Cursor.lockState = CursorLockMode.Locked;
            }
            if (CgScoring.alpha == 1f)
            {
                EventSystem.firstSelectedGameObject = GoScoringFirstButtonSelected;
                if (controllerConnected) //Si controller
                {
                    UnityEngine.Cursor.lockState = CursorLockMode.Locked;
                }
                else //sinon keyboard
                {
                    UnityEngine.Cursor.lockState = CursorLockMode.None;
                }
            }
            else
            {
                EventSystem.firstSelectedGameObject = null;
            }
            StartCoroutine(wait());
            StartCoroutine(ImuneToPause(scPlayer.bpmManager));
            PauseGame();
        }
    }
    private IEnumerator wait()
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
                GoLevelsButton = new GameObject[GoTargetUI.Length -5];
                GoLevelStars = new GameObject[4];
                _levels = new Level[GoTargetUI.Length -5];
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
                if ( _playerData.iLevelPlayer >= i)
                {
                    int captured = i;
                    _levels[i].button_level.onClick.AddListener(() => LoadScene(_levels[captured].sScene_Level));
                    _levels[i].img_lvl.color = colorPlayer;
                    TextMeshProUGUI textChild = _levels[i].Go_LevelButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(0, 255, 255, 255);
                    for(int y = 0; y< 5; y++)
                    {
                        if (_playerData.iStarsPlayer[5*i+y] ==1)
                        {
                            Debug.Log("true " +y);
                            GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().color = new Color32(255,255, 255, 255);
                        }
                        else
                        {
                            Debug.Log(y);
                            GoLevelStars[i].transform.GetChild(y).GetComponent<UnityEngine.UI.Image>().color = new Color32(0, 0, 0, 255);
                        }
                    }
                }
               else if(GoLevelsButton.Length- _playerData.iLevelPlayer > i)
               {
                    _levels[i].img_lvl.color = colorFoes;
                    TextMeshProUGUI textChild = _levels[i].Go_LevelButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(255, 255, 0, 255);
                }
                GoLevelBackButton.GetComponent<UnityEngine.UI.Button>().onClick.AddListener(() => LoadScene("Loft"));
            }
        }
    }
    public void OptionsGame()
    {
        Debug.Log("OptionsOpen");
        CgSoundManager.alpha = 1f;
        CgSoundManager.interactable = true;
        RtSoundManager.anchorMin = new Vector2(0, 0);
        RtSoundManager.anchorMax = new Vector2(1, 1);
        RtSoundManager.offsetMax = new Vector2(0f, 0f);
        RtSoundManager.offsetMin = new Vector2(0f, 0f);
    }
    public void CloseOptions()
    {
        CgSoundManager.alpha = 0f;
        CgSoundManager.interactable = false;
        RtSoundManager.anchorMin = new Vector2(0, 1);
        RtSoundManager.anchorMax = new Vector2(1, 2);
        RtSoundManager.offsetMax = new Vector2(0f, 0f);
        RtSoundManager.offsetMin = new Vector2(0f, 0f);
    }
    public void LoadScene(string sceneToLoad)
    {
        if (sceneToLoad == "SceneLvl0" || sceneToLoad == "SceneLvl1" || sceneToLoad == "Loft" || sceneToLoad == "SceneLvl2" || sceneToLoad == "SceneLvl3")
        {
            menuLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
            menuLoopInstance.release();
            StartCoroutine(StartLoad(sceneToLoad));
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
            Debug.Log("retry has been clicked");
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
        RtLoadingScreen.anchorMin = new Vector2(0, 1);
        RtLoadingScreen.anchorMax = new Vector2(0, 1);
        CgScoring.alpha = 1f;
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
        RtLoadingScreen.anchorMin = new Vector2(0, 1);
        RtLoadingScreen.anchorMax = new Vector2(1, 2);
        CgScoring.alpha = 0f;
        RtScoring.anchorMin = new Vector2(0, 1);
        RtScoring.anchorMax = new Vector2(1, 2);
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
    public void QuitGame()
    {
#if UNITY_EDITOR
        if (UnityEditor.EditorApplication.isPlaying)
        {
            UnityEditor.EditorApplication.isPlaying = false;
        }
#endif
        Debug.Log("quit game been clicked");
        Application.Quit();
    }
    public void SetMusicVolume()
    {
        float volume = MusicSlider.value;
        Debug.Log("Slider Value: " + volume);
        if (!musicVCA.isValid())
        {
            Debug.LogError("VCA is not valid! Check FMOD path.");
            return;
        }
        playerMusicVolume = volume;
        musicVCA.setVolume(volume);
        float checkVolume;
        musicVCA.getVolume(out checkVolume); // Check if FMOD applied it

        Debug.Log($"Slider Value: {volume}, FMOD Applied Volume: {checkVolume}");
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
                musicVCA.getVolume(out float currentVolume); // Get current volume
                musicVCA.setVolume(currentVolume * 0.8f);
                //bpmManager.playerLoopInstance.setParameterByName("fPausedVolume", 0.8f);
            }
        }
        else
        {
            Time.timeScale = 1f;
            musicVCA.setVolume(playerMusicVolume);
            if (CgScoring.alpha == 1f)
            {
                EventSystem.firstSelectedGameObject = GoScoringFirstButtonSelected;
            }
        }
    }

    private IEnumerator ImuneToPause(BPM_Manager bpmmanager)
    {
        scPlayer.bIsImune = true;
        bpmmanager.iTimer = 3;
        yield return new WaitForSecondsRealtime(bpmmanager.FSPB * 3);
        scPlayer.bIsImune = false;
    }
}
