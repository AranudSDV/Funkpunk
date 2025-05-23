using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine.SceneManagement;
using UnityEngine;
using UnityEngine.UI;
using FMODUnity;

public class sc_textChange : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    [SerializeField] private PlayerData _playerData;
    [SerializeField] private string sEnglish;
    [SerializeField] private string sFrench;
    [SerializeField] private bool bIsOnManager = false;
    [SerializeField] private bool bIsDifficulty = false;
    [SerializeField] private bool bIsToTip = false;
    private TMP_Text tmpProText;
    private Coroutine coroutine;
    [SerializeField] float delayBeforeStart = 0f;
    [SerializeField] float timeBtwChars = 0.06f;
    private float timeBtwCharsNow = 0.06f;
    private float FastTimeBtwChars = 0f;
    [SerializeField] bool leadingCharBeforeDelay = false;
    [SerializeField] string leadingChar = "";
    private string writer;
    private bool bnotfound;
    private bool bInitialized;
    [SerializeField] private MenuManager menuManager;
    private bool bTextWritten = false;
    private bool bTextBegon = false;
    private float fTimerWritten = 0f;
    private float bTimerBegon = 0f;
    private bool isControllerTriggered;
    private Coroutine coroutine_ = null;
    private bool bOnce = false;

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

        if(bIsToTip)
        {
            tmpProText = this.GetComponent<TextMeshProUGUI>();
        }
    }

    private void Update()
    {
        if (!bInitialized)
        {
            Init();
            bInitialized = true;
        }
        if (bIsToTip)
        {
            if (bTextWritten)
            {
                fTimerWritten += Time.unscaledDeltaTime;
                if (fTimerWritten >= 0.1f)
                {
                    fTimerWritten = 0f;
                    bTextWritten = false;
                    menuManager.bWaitNextDialogue = true;
                }
            }
        }
        else
        {
            if (_playerData != null && scPlayer != null)
            {
                bInitialized = false;
            }
            if(!bIsDifficulty)
            {
                if (_playerData == null && (SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0") && !bIsOnManager)
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
            else
            {
                if (_playerData == null && (SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0") && !bIsOnManager)
                {
                    _playerData = scPlayer.menuManager.gameObject.transform.GetComponent<PlayerData>();
                }
                if (_playerData != null && menuManager != null && _playerData.iLanguageNbPlayer == 1)
                {
                    if(menuManager.iDifficulty == 0)
                    {
                        this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = "Difficile";
                    }
                    else if (menuManager.iDifficulty == 1)
                    {
                        this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = "Normal";
                    }
                    else
                    {
                        this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = "Facile";
                    }
                }
                else
                {
                    if (menuManager.iDifficulty == 0)
                    {
                        this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = "Hard";
                    }
                    else if (menuManager.iDifficulty == 1)
                    {
                        this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = "Normal";
                    }
                    else
                    {
                        this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = "Easy";
                    }
                }
            }
        }
    }
    public void SkipOrNext()
    {
        if (!bTextWritten && !bOnce)
        {
            StopCoroutine(coroutine_);
            tmpProText.text = "";
            tmpProText.text = writer;
            bTextWritten = true;
            bOnce = true;
        }
        else if(menuManager.bWaitNextDialogue)
        {
            menuManager.CheckDialogue();
            bOnce = false;
        }
    }

    public void StartWriting(string sDialogue)
    {
        writer = sDialogue;
        tmpProText.text = "";
        coroutine_ = StartCoroutine("TypeWriterTMP");
    }
    private IEnumerator TypeWriterTMP()
    {
        yield return new WaitForSecondsRealtime(delayBeforeStart);

        foreach (char c in writer)
        {
            if (tmpProText.text.Length > 0)
            {
                tmpProText.text = tmpProText.text.Substring(0, tmpProText.text.Length - leadingChar.Length);
            }
            tmpProText.text += c;
            tmpProText.text += leadingChar;
            yield return new WaitForSecondsRealtime(timeBtwCharsNow);
        }

        if (leadingChar != "")
        {
            tmpProText.text = tmpProText.text.Substring(0, tmpProText.text.Length - leadingChar.Length);
        }
        if(tmpProText.text == writer)
        {
            bTextWritten = true;
        }
    }
}
