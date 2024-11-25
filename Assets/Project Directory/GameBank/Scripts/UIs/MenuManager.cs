using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using Unity.VisualScripting;
using TMPro;

public class MenuManager : MonoBehaviour
{
    private GameObject GoMainMenu;
    private GameObject[] GoGameChoose; //0 is GoNewLoadButton, 1 is GoNewLoadText, 2 is GoOptionsButton, 3 is GoExitButton
    private GameObject[] GoLevelsButton;
    public string sSceneToLoad;
    public static bool isLoadingScene = false;
    [SerializeField] private Slider progressBar;
    [SerializeField] private GameObject loadingScreen;
    private AsyncOperation loadingOperation;
    [SerializeField] private CanvasGroup canvasGroup;
    [SerializeField] private GameObject GoPauseMenu;
    private PlayerData _playerData;
    private Button[] btnLevel = null;
    private Image[] img_button = null;

    private void Awake()
    {
        LoadTargetUIMenus();
        DontDestroyOnLoad(this.gameObject);
        if (FindObjectsOfType<MenuManager>().Length > 1)
        {
            Destroy(this);
        }

        isLoadingScene = false;
    }


    // Update is called once per frame
    void Update()
    {
        if (GoMainMenu != null && Input.anyKey)
        {
            LoadScene(sSceneToLoad);
        }
        UXNavigation();
        if (isLoadingScene)
        {
            progressBar.value = Mathf.Clamp01(loadingOperation.progress / 0.9f);
        }
    }

    private void UXNavigation()
    {
        if (Input.GetKey(KeyCode.Escape) && GoPauseMenu.activeInHierarchy == false)
        {
            GoPauseMenu.SetActive(true);
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
                sSceneToLoad = "LevelChoosing";
            }
            else if (SceneManager.GetActiveScene().name == "LevelChoosing")
            {
                GoLevelsButton = new GameObject[GoTargetUI.Length];
                for (int i = 0; i < GoTargetUI.Length; i++)
                {
                    for (int y = 0; y < GoTargetUI.Length; y++)
                    {
                        if (GoTargetUI[i].name == "LevelButton" + y)
                        {
                            GoLevelsButton[y] = GoTargetUI[i];
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
                TextMeshProUGUI text = GoGameChoose[1].GetComponent<TextMeshProUGUI>();
                text.text = "Load Game";
            }
            else
            {
                TextMeshProUGUI text = GoGameChoose[1].GetComponent<TextMeshProUGUI>();
                text.text = "New Game";
            }
            Button btnExit = GoGameChoose[3].GetComponent<Button>();
            btnExit.onClick.AddListener(QuitGame);
            Button btnOptions = GoGameChoose[2].GetComponent<Button>();
            btnOptions.onClick.AddListener(OptionsGame);
        }
        else if(SceneManager.GetActiveScene().name == "LevelChoosing")
        {
            btnLevel = new Button[GoLevelsButton.Length];
            img_button = new Image[GoLevelsButton.Length];
            for (int i = 0; i < GoLevelsButton.Length; i++)
            {
                btnLevel[i] = GoLevelsButton[i].GetComponent<Button>();
                img_button[i] = GoLevelsButton[i].GetComponent<Image>();
                if ( _playerData.iLevelPlayer >= i)
                {
                    btnLevel[i].onClick.AddListener(delegate { LoadScene(sSceneToLoad + i); });
                    img_button[i].color = new Color32(0, 135, 0, 255);
                    TextMeshProUGUI textChild = GoLevelsButton[i].transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(0, 255, 0, 255);
                }
               else if(GoLevelsButton.Length- _playerData.iLevelPlayer > i)
                {
                    img_button[i].color = new Color32(54, 64, 134, 255);
                    TextMeshProUGUI textChild = GoLevelsButton[i].transform.GetChild(0).GetComponent<TextMeshProUGUI>();
                    textChild.color = new Color32(64, 97, 255, 255);
                }
            }
        }
    }

    public void ClosePauseMenu()
    {
        GoPauseMenu.SetActive(false);
    }

    public void OptionsGame()
    {
        Debug.Log("OptionsOpen");
    }

    public void LoadScene(string sceneToLoad)
    {
        StartCoroutine(StartLoad(sceneToLoad));
        Debug.Log(sceneToLoad);
    }

    IEnumerator StartLoad(string sceneToLoad)
    {
        loadingScreen.SetActive(true);
        yield return StartCoroutine(FadeLoadingScreen(1, 1));
        LoaderScene(sceneToLoad);
        while (!loadingOperation.isDone)
        {
            yield return null;
        }
        LoadTargetUIMenus();
        yield return StartCoroutine(FadeLoadingScreen(0, 1));
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

    IEnumerator FadeLoadingScreen(float targetValue, float duration)
    {
        float startValue = canvasGroup.alpha;
        float time = 0;

        while (time < duration)
        {
            canvasGroup.alpha = Mathf.Lerp(startValue, targetValue, time / duration);
            time += Time.deltaTime;
            yield return null;
        }
        canvasGroup.alpha = targetValue;
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
