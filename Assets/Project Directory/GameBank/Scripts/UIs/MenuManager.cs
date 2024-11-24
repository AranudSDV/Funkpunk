using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class MenuManager : MonoBehaviour
{
    [SerializeField] private bool bIsMainMenu = false;
    [SerializeField] private string sceneToLoad;
    private string currentScene;
    public static bool isLoadingScene = false;
    [SerializeField] private Slider progressBar;
    private AsyncOperation loadingOperation;

    private void Awake()
    {
        if (FindObjectsOfType<MenuManager>().Length > 1)
        {
            Destroy(this);
        }

        isLoadingScene = false;
    }


    // Update is called once per frame
    void Update()
    {
        if (bIsMainMenu && Input.anyKey)
        {
            LoadScene(sceneToLoad);
        }
        if(isLoadingScene)
        {
            progressBar.value = Mathf.Clamp01(loadingOperation.progress / 0.9f);
        }
    }

    public void LoadScene(string sceneToLoad)
    {
        Debug.LogWarning("Scene loading attempt");
        if (isLoadingScene) return;

        if (!Application.CanStreamedLevelBeLoaded(sceneToLoad)) return;

        isLoadingScene = true;

        loadingOperation = SceneManager.LoadSceneAsync(sceneToLoad);
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
