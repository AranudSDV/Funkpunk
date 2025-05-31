using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine.SceneManagement;
using UnityEngine;
using UnityEngine.UI;
using FMODUnity;
using Febucci.UI;
using static System.Net.Mime.MediaTypeNames;

public class sc_textChange : MonoBehaviour
{
    public TextAnimatorPlayer typeAnimator;
    [SerializeField] private SC_Player scPlayer;
    [SerializeField] private PlayerData _playerData;
    [SerializeField] private string sEnglish;
    [SerializeField] private string sFrench;
    [SerializeField] private bool bIsOnManager = false;
    [SerializeField] private bool bIsDifficulty = false;
    [SerializeField] private bool bIsToTip = false;
    public bool bIsBubble = false;
    private bool bnotfound;
    private string writer;
    public bool bTextWritten = false;
    [SerializeField] private MenuManager menuManager;
    private bool bOnce = false;
    private bool bInitialized;
    private float fTimerWritten = 0f;

    //
    //private TMP_Text tmpProText;
    /*private Coroutine coroutine;
    [SerializeField] float delayBeforeStart = 0f;
    [SerializeField] float timeBtwChars = 0.06f;
    private float timeBtwCharsNow = 0.06f;
    private float FastTimeBtwChars = 0f;
    [SerializeField] bool leadingCharBeforeDelay = false;
    [SerializeField] string leadingChar = "";
    private bool bTextBegon = false;
    private float bTimerBegon = 0f;
    private bool isControllerTriggered;
    private Coroutine coroutine_ = null;*/

    public void Init()
    {
        if (!bIsOnManager)
        {
            if (SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0" || SceneManager.GetActiveScene().name == "SceneLvl2" || SceneManager.GetActiveScene().name == "SceneLvl3" || SceneManager.GetActiveScene().name == "Loft")
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

        if(!bIsToTip)
        {
            if (SceneManager.GetActiveScene().name == "GameChoose" || SceneManager.GetActiveScene().name == "SceneSplash" || bnotfound)
            {
                _playerData = GameObject.FindWithTag("Manager").transform.GetComponent<PlayerData>();
            }
            if (_playerData != null && _playerData.iLanguageNbPlayer == 1)
            {
                this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sFrench;
                //this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sFrench;
            }
            else
            {
                this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sEnglish;
                //this.gameObject.transform.GetComponent<TextMeshProUGUI>().text = sEnglish;
            }
            if (bIsBubble)
            {
                typeAnimator.onTextShowed.AddListener(OnTextFullyShown);
            }
        }
        else
        {
            typeAnimator.onTextShowed.AddListener(OnTextFullyShown);
        }
    }

    private void Update()
    {
        if (!bInitialized && ((scPlayer!=null && scPlayer.menuManager!=null) || scPlayer==null))
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
                if (scPlayer != null && _playerData == null && (SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0" || SceneManager.GetActiveScene().name == "SceneLvl2" || SceneManager.GetActiveScene().name == "SceneLvl3") && !bIsOnManager)
                {
                    _playerData = scPlayer.menuManager.gameObject.transform.GetComponent<PlayerData>();
                }
                else if(_playerData == null && SceneManager.GetActiveScene().name == "SceneSplash"&& !bIsOnManager)
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
                if (scPlayer!=null&&_playerData == null && (SceneManager.GetActiveScene().name == "SceneLvl1" || SceneManager.GetActiveScene().name == "SceneLvl0" || SceneManager.GetActiveScene().name == "SceneLvl2" || SceneManager.GetActiveScene().name == "SceneLvl3") && !bIsOnManager)
                {
                    _playerData = scPlayer.menuManager.gameObject.transform.GetComponent<PlayerData>();
                }
                else if (menuManager != null && _playerData == null && SceneManager.GetActiveScene().name == "SceneSplash" && !bIsOnManager)
                {
                    _playerData = menuManager.gameObject.transform.GetComponent<PlayerData>();
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

    public void BubbleShowText()
    {
        bTextWritten = false;
        if (_playerData != null && _playerData.iLanguageNbPlayer == 1)
        {
            ShowDialogue(sFrench);
        }
        else
        {
            ShowDialogue(sEnglish);
        }
    }
    public void BubbleSkipText()
    {
        typeAnimator.SkipTypewriter();
        bTextWritten = true;
    }
    private void ShowDialogue(string text)
    {
        typeAnimator.ShowText(text);
    }
    private void OnTextFullyShown()
    {
        bTextWritten = true;
    }
    public void SkipOrNext()
    {
        if (!bTextWritten && !bOnce)
        {
            typeAnimator.SkipTypewriter();
            bTextWritten = true;
            bOnce = true;
        }
        else if(menuManager.bWaitNextDialogue)
        {
            menuManager.CheckDialogue();
            bTextWritten = false;
            bOnce = false;
        }
    }

    public void StartWriting(string sDialogue)
    {
        writer = sDialogue;
        ShowDialogue(writer);
    }
    /*private IEnumerator TypeWriterTMP()
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
    }*/
}
