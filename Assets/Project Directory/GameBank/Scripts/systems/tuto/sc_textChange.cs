using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine.SceneManagement;
using UnityEngine;
using FMODUnity;

public class sc_textChange : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    [SerializeField] private PlayerData _playerData;
    [SerializeField] private string sEnglish;
    [SerializeField] private string sFrench;
    [SerializeField] private string sJoystickEnglish;
    [SerializeField] private string sJoystickFrench;
    [SerializeField] private bool bHasInput;
    [SerializeField] private bool bIsOnManager;
    private bool bnotfound;
    private bool bInitialized;
    private void Start()
    {
       
    }

    public void Init()
    {
        if (!bIsOnManager)
        {
            if (SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0" || SceneManager.GetActiveScene().name == "Loft")
            {
                if (scPlayer != null)
                {
                    _playerData = scPlayer.menuManager.gameObject.transform.GetComponent<PlayerData>();
                }
                else
                {
                    bnotfound = true;
                }
            }
        }

        if (SceneManager.GetActiveScene().name == "GameChoose" || bnotfound)
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
        if(!bInitialized)
        {
            Init();
            bInitialized = true;
        }
        if (_playerData != null && scPlayer != null)
        {
            bInitialized = false;
        }
        if(bHasInput)
        {
            if(scPlayer != null)
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
                if ((SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0"))
                {
                    scPlayer = GameObject.FindWithTag("Player").transform.GetComponent<SC_Player>();
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
        else
        {
            if ((SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0") && !bIsOnManager)
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
