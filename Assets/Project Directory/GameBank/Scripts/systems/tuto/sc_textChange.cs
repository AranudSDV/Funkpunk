using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine.SceneManagement;
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

    private void Awake()
    {
        if ((SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0") && (this.transform.parent.transform.parent.transform.parent.transform.parent.gameObject.name != "Manager"))
        {
            _playerData = scPlayer.menuManager.gameObject.transform.GetComponent<PlayerData>();
        }
        if(SceneManager.GetActiveScene().name == "GameChoose")
        {
            _playerData = GameObject.FindWithTag("Manager").transform.GetComponent<PlayerData>();
        }
        if (_playerData != null && _playerData.iLanguageNbPlayer == 1)
        {
            this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sFrench;
        }
        else
        {
            this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sEnglish;
        }
    }


    private void Update()
    {
        if(bHasInput)
        {
            if (scPlayer.bIsOnComputer)
            {
                if (_playerData != null && _playerData.iLanguageNbPlayer == 1)
                {
                    this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sFrench;
                }
                else
                {
                    this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sEnglish;
                }
            }
            else
            {
                if (_playerData != null && _playerData.iLanguageNbPlayer == 1)
                {
                    this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sJoystickFrench;
                }
                else
                {
                    this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sJoystickEnglish;
                }
            }
        }
        else
        {
            if ((SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0") && (this.transform.parent.transform.parent.transform.parent.transform.parent.gameObject.name != "Manager"))
            {
                _playerData = scPlayer.menuManager.gameObject.transform.GetComponent<PlayerData>();
            }
            if (_playerData != null && _playerData.iLanguageNbPlayer == 1)
            {
                this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sFrench;
            }
            else
            {
                this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sEnglish;
            }
        }
    }
}
