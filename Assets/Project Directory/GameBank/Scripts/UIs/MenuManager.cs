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
    }

    public void LoadScene(string sceneToLoad)
    {
        Debug.LogWarning("Scene loading attempt");
        if (isLoadingScene) return;

        if (!Application.CanStreamedLevelBeLoaded(sceneToLoad)) return;

        isLoadingScene = true;

        SceneManager.LoadSceneAsync(sceneToLoad);
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
