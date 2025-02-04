using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class MainMenuNameChanging : MonoBehaviour
{
    [SerializeField]private MenuManager menuManager;
    [SerializeField] private Image imgAnyKey;
    [SerializeField] private Sprite[] spriteKey = new Sprite[2];
    [SerializeField] private PlayerData playerData;
    [SerializeField] private GameObject GoLanguage;
    public bool isOk = false;
    // Update is called once per frame
    void Update()
    {
        if(menuManager.controllerConnected)
        {
            imgAnyKey.sprite = spriteKey[1];
        }
        else
        {
            imgAnyKey.sprite = spriteKey[0];
        }
    }

    public void LanguageButton(int i)
    {
        if(i==0)
        {
            playerData.iLanguageNbPlayer = 0;
        }
        else if(i==1)
        {
            playerData.iLanguageNbPlayer = 1;
        }
        GoLanguage.SetActive(false);
        isOk = true;
    }
}
