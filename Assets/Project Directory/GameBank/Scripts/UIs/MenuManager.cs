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

public class MenuManager : MonoBehaviour
{
    public PlayerControl control;
    private EventSystem EventSystem;
    public bool controllerConnected = false;

    //NAVIGATION UX
    private GameObject GoMainMenu;
    private GameObject[] GoGameChoose; //0 is GoNewLoadButton, 1 is GoNewLoadText, 2 is GoOptionsButton, 3 is GoExitButton
    [SerializeField] private Sprite[] buttonSpriteGameChoose = new Sprite[2];
    public GameObject[] GoLevelsButton;
    [SerializeField] private GameObject GoScoring;
    [SerializeField] private GameObject GoPauseMenu;
    private bool bActif = false;

    //SCENE LOADING
    public string sSceneToLoad;
    public static bool isLoadingScene = false;
    [SerializeField] private Slider progressBar;
    [SerializeField] private GameObject loadingScreen;
    private AsyncOperation loadingOperation;
    [SerializeField] private CanvasGroup canvasGroup;

    //DATA PLAYER
    private PlayerData _playerData;
    public Level[] _levels;
    [SerializeField] private EventReference menuLoop;
    private FMOD.Studio.EventInstance menuLoopInstance;
    //DATA LEVEL
    public int[] iNbTaggs = new int[4];

    [System.Serializable]
    public class Level 
    {
        public int i_level;
        public Button button_level;
        public GameObject Go_LevelButton;
        public string sScene_Level;
        public Image img_lvl;

        public Level(int i_nb, GameObject[]Go_buttons)
        {
            i_level = i_nb;
            Go_LevelButton = Go_buttons[i_nb];
            button_level = Go_buttons[i_nb].GetComponent<Button>();
            sScene_Level = "SceneLvl" + i_level;
            img_lvl = Go_buttons[i_nb].GetComponent<Image>();
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
        menuLoopInstance = RuntimeManager.CreateInstance(menuLoop);
        menuLoopInstance.start();
    }
    // Update is called once per frame
    void Update()
    {
        CheckControllerStatus();
        if (GoMainMenu != null && ((Input.anyKeyDown && !(Input.GetMouseButtonDown(0)|| Input.GetMouseButtonDown(1) || Input.GetMouseButtonDown(2) || Input.GetKeyDown(KeyCode.J)) && !controllerConnected) || (controllerConnected && control.GamePlay.Move.triggered)))
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
                Cursor.lockState = CursorLockMode.Locked;
            }
            else
            {
                Debug.Log("No controllers connected!");
                Cursor.lockState = CursorLockMode.None;
            }
        }
    }
    private void UXNavigation()
    {
        if ((Input.GetKey(KeyCode.Escape)|| (controllerConnected && control.GamePlay.Pausing.triggered)) && GoPauseMenu.activeInHierarchy == false)
        {
            if (SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "LevelChoosing" && SceneManager.GetActiveScene().name != "Loft")
            {
                EventSystem.firstSelectedGameObject = GoPauseMenu.transform.GetChild(0).gameObject.transform.GetChild(1).gameObject;
            }
            PauseMenu();
        }
        else if ((Input.GetKey(KeyCode.Escape) || (controllerConnected && control.GamePlay.Pausing.triggered)) && GoPauseMenu.activeInHierarchy == true && GoScoring.activeInHierarchy == false)
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
        if (GoPauseMenu.activeInHierarchy == false && !bActif)
        {
            GoPauseMenu.SetActive(true);
            if (!controllerConnected)
            {
                Cursor.lockState = CursorLockMode.None;
            }
            GameObject goPlayer = GameObject.FindGameObjectWithTag("Player");
            if (goPlayer != null)
            {
                SC_Player scPlayer = goPlayer.GetComponent<SC_Player>();
                scPlayer.bGameIsPaused = true;
                scPlayer.PauseGame();
            }
            StartCoroutine(wait());
        }
        else if (GoPauseMenu.activeInHierarchy == true && bActif)
        {
            GoPauseMenu.SetActive(false);
            GameObject goPlayer = GameObject.FindGameObjectWithTag("Player");
            if (goPlayer != null)
            {
                SC_Player scPlayer = goPlayer.GetComponent<SC_Player>();
                scPlayer.bGameIsPaused = false;
                scPlayer.PauseGame();
            }
            if (controllerConnected && SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "LevelChoosing")
            {
                EventSystem.firstSelectedGameObject = GoScoring.transform.GetChild(0).gameObject.transform.GetChild(2).gameObject.transform.GetChild(1).gameObject;
            }
            if (!controllerConnected && SceneManager.GetActiveScene().name != "GameChoose" && SceneManager.GetActiveScene().name != "LevelChoosing")
            {
                Cursor.lockState = CursorLockMode.Locked;
            }
            StartCoroutine(wait());
        }
    }
    private IEnumerator wait()
    {
        yield return new WaitForSecondsRealtime(0.5f);
        if (GoPauseMenu.activeInHierarchy && !bActif)
        {
            bActif = true;
        }
        else if (GoPauseMenu.activeInHierarchy == false && bActif)
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
            Button btnNewLoad = GoGameChoose[0].GetComponent<Button>();
            btnNewLoad.onClick.AddListener(delegate { LoadScene(sSceneToLoad); });
            if (_playerData.iLevelPlayer > 0)
            {
                Image img = GoGameChoose[0].GetComponent<Image>();
                img.sprite = buttonSpriteGameChoose[1];
            }
            else
            {
                Image img = GoGameChoose[0].GetComponent<Image>();
                img.sprite = buttonSpriteGameChoose[0];
            }
            Button btnExit = GoGameChoose[2].GetComponent<Button>();
            btnExit.onClick.AddListener(QuitGame);
            Button btnOptions = GoGameChoose[1].GetComponent<Button>();
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
                    _levels[i].img_lvl.color = new Color32(0, 135, 0, 255);
                    TextMeshProUGUI textChild = _levels[i].Go_LevelButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(0, 255, 0, 255);
                }
               else if(GoLevelsButton.Length- _playerData.iLevelPlayer > i)
                {
                    _levels[i].img_lvl.color = new Color32(54, 64, 134, 255);
                    TextMeshProUGUI textChild = _levels[i].Go_LevelButton.transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(64, 97, 255, 255);
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
        if (sceneToLoad == "SceneLvl0")
        {
            menuLoopInstance.stop(FMOD.Studio.STOP_MODE.ALLOWFADEOUT);
            menuLoopInstance.release();
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
    }
    private IEnumerator StartLoad(string sceneToLoad)
    {
        loadingScreen.SetActive(true);
        yield return StartCoroutine(FadeLoadingScreen(1, 0.5f));
        LoaderScene(sceneToLoad);
        while (!loadingOperation.isDone)
        {
            yield return null;
        }
        LoadTargetUIMenus();
        yield return StartCoroutine(FadeLoadingScreen(0, 0.001f));
        isLoadingScene = false;
        loadingScreen.SetActive(false);
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
        float startValue = canvasGroup.alpha;
        float time = 0;

        while (time < duration)
        {
            canvasGroup.alpha = Mathf.Lerp(startValue, targetValue, time / duration);
            time += Time.unscaledDeltaTime;
            yield return null;
        }
        canvasGroup.alpha = targetValue;
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
