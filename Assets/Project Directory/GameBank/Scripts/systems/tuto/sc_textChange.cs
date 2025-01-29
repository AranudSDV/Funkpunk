using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class sc_textChange : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    [SerializeField] private PlayerData _playerData;
    [SerializeField] private string sEnglish;
    [SerializeField] private string sFrench;
    [SerializeField] private string sJoystickEnglish;
    [SerializeField] private string sJoystickFrench;
    [SerializeField] private bool bHasInput;

    private void Start()
    {
        if ((scPlayer != null && scPlayer.bpmManager.gameObject.transform.GetComponent<PlayerData>().iLanguageNbPlayer == 1) || (_playerData != null && _playerData.iLanguageNbPlayer == 1))
        {
            this.gameObject.transform.GetComponent<TextMeshPro>().text = sFrench;
        }
        else
        {
            this.gameObject.transform.GetComponent<TextMeshPro>().text = sEnglish;
        }
    }

    private void Update()
    {
        if(bHasInput)
        {
            if (scPlayer.bIsOnComputer)
            {
                if ((scPlayer != null && scPlayer.bpmManager.gameObject.transform.GetComponent<PlayerData>().iLanguageNbPlayer == 1) || (_playerData != null && _playerData.iLanguageNbPlayer == 1))
                {
                    this.gameObject.transform.GetComponent<TextMeshPro>().text = sFrench;
                }
                else
                {
                    this.gameObject.transform.GetComponent<TextMeshPro>().text = sEnglish;
                }
            }
            else
            {
                if ((scPlayer != null && scPlayer.bpmManager.gameObject.transform.GetComponent<PlayerData>().iLanguageNbPlayer == 1) || (_playerData != null && _playerData.iLanguageNbPlayer == 1))
                {
                    this.gameObject.transform.GetComponent<TextMeshPro>().text = sJoystickFrench;
                }
                else
                {
                    this.gameObject.transform.GetComponent<TextMeshPro>().text = sJoystickEnglish;
                }
            }
        }
    }
}
