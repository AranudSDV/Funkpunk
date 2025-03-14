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
    private EventSystem EventSystem;
    public bool controllerConnected = false;
    public SC_Player scPlayer;

    //NAVIGATION UX
    [Header("Navigation UX")]
    private GameObject GoMainMenu;
    private GameObject[] GoGameChoose; //0 is GoNewLoadButton, 1 is GoNewLoadText, 2 is GoOptionsButton, 3 is GoExitButton
    public GameObject[] GoLevelsButton;
    [SerializeField] private GameObject GoPauseMenu;
    public CanvasGroup CgPauseMenu;
    [SerializeField] private RectTransform RtPauseMenu;
    private bool bActif = false;
    [SerializeField] private Color32 colorFoes;
    [SerializeField] private Color32 colorPlayer;

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
                UnityEngine.Cursor.lockState = CursorLockMode.Locked;
            }
            else
            {
                Debug.Log("No controllers connected!");
                UnityEngine.Cursor.lockState = CursorLockMode.None;
            }
        }
    }
    private void UXNavigation()
    {
        if ((Input.GetKey(KeyCode.Escape)|| (controllerConnected && control.GamePlay.Pausing.triggered)) && CgPauseMenu.alpha == 0f)
        {
            if (SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "LevelChoosing" && SceneManager.GetActiveScene().name != "Loft")
            {
                EventSystem.firstSelectedGameObject = GoPauseMenu.transform.GetChild(0).gameObject.transform.GetChild(1).gameObject;
            }
            PauseMenu();
        }
        else if ((Input.GetKey(KeyCode.Escape) || (controllerConnected && control.GamePlay.Pausing.triggered)) && CgPauseMenu.alpha == 1f && CgScoring.alpha == 0f)
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
        if (CgPauseMenu.alpha == 0f && !bActif)
        {
            CgPauseMenu.alpha = 1f;
            RtPauseMenu.anchorMin = new Vector2(-0.5f, 0);
            RtPauseMenu.anchorMax = new Vector2(1.5f, 1);
            RtPauseMenu.offsetMax = new Vector2(0f, 0f);
            RtPauseMenu.offsetMin = new Vector2(0f, 0f);
            if (!controllerConnected)
            {
               UnityEngine.Cursor.lockState = CursorLockMode.None;
            }
            if (scPlayer == null && SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "MainMenu" && SceneManager.GetActiveScene().name != "Level Choosing")
            {
                SC_Player scPlayer = GameObject.FindGameObjectWithTag("Player").GetComponent<SC_Player>();
            }
            else if (scPlayer != null && SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "MainMenu" && SceneManager.GetActiveScene().name != "Level Choosing")
            {
                scPlayer.bGameIsPaused = true;
                Debug.Log("actif");
                scPlayer.PauseGame();
            }
            StartCoroutine(wait());
        }
        else if (CgPauseMenu.alpha == 1f && bActif)
        {
            CgPauseMenu.alpha = 0f;
            RtPauseMenu.anchorMin = new Vector2(0, 1);
            RtPauseMenu.anchorMax = new Vector2(1, 2);
            RtPauseMenu.offsetMax = new Vector2(0f, 0f);
            RtPauseMenu.offsetMin = new Vector2(0f, 0f);
            if (scPlayer == null && SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "MainMenu" && SceneManager.GetActiveScene().name != "Level Choosing")
            {
                SC_Player scPlayer = GameObject.FindGameObjectWithTag("Player").GetComponent<SC_Player>();
            }
            else if(scPlayer != null && SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "MainMenu" && SceneManager.GetActiveScene().name != "Level Choosing")
            {
                scPlayer.bGameIsPaused = false;
                Debug.Log("inactif");
                scPlayer.PauseGame();
            }
            if (controllerConnected && SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "LevelChoosing")
            {
                EventSystem.firstSelectedGameObject = GoScoring.transform.GetChild(0).gameObject.transform.GetChild(2).gameObject.transform.GetChild(1).gameObject;
            }
            if (!controllerConnected && SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "LevelChoosing")
            {
                UnityEngine.Cursor.lockState = CursorLockMode.Locked;
            }
            StartCoroutine(wait());
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
                GoLevelsButton = new GameObject[GoTargetUI.Length];
                _levels = new Level[GoTargetUI.Length];
                for (int i = 0; i < GoTargetUI.Length; i++)
                {
                    for (int y = 0; y < GoTargetUI.Length; y++)
                    {
                        if (GoTargetUI[i].name == "SceneLvl" + y)
                        {
                            GoLevelsButton[y] = GoTargetUI[i];
                            _levels[y] = new Level(y, GoLevelsButton);
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
                }
               else if(GoLevelsButton.Length- _playerData.iLevelPlayer > i)
                {
                    _levels[i].img_lvl.color = colorFoes;
                    TextMeshProUGUI textChild = _levels[i].Go_LevelButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(255, 255, 0, 255);
                }
            }
        }
    }
    public void OptionsGame()
    {
        Debug.Log("OptionsOpen");
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

        Application.Quit();
    }
}
