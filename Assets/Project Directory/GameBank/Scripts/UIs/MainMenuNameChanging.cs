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
}
