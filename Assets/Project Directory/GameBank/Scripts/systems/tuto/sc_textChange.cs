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
    [SerializeField] private string sJoystickEnglish;
    [SerializeField] private string sJoystickFrench;
    [SerializeField] private bool bHasInput;
    [SerializeField] private bool bIsOnManager;
    [SerializeField] private bool bIsToTip = false;
    private TMP_Text tmpProText;
    private Coroutine coroutine;
    [SerializeField] float delayBeforeStart = 0f;
    [SerializeField] float timeBtwChars = 0.06f;
    private float timeBtwCharsNow = 0.06f;
    [SerializeField] float FastTimeBtwChars = 0.02f;
    [SerializeField] bool leadingCharBeforeDelay = false;
    [SerializeField] string leadingChar = "";
    private string writer;
    private float f_pressed = 0f;
    private bool bnotfound;
    private bool bInitialized;
    [SerializeField] private MenuManager menuManager;
    private bool bTextWritten = false;
    private float bTimer = 0f;

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
            CheckKeyHold();
            LongTouch();
            if (bTextWritten)
            {
                bTimer += Time.unscaledDeltaTime;
                if (bTimer >= 1f)
                {
                    bTimer = 0f;
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
            if (bHasInput)
            {
                if (scPlayer != null)
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
    private void CheckKeyHold()
    {
        bool isKeyDown = Input.GetKey(KeyCode.Space);
        bool isControllerTriggered = menuManager.controllerConnected && menuManager.control.GamePlay.Move.ReadValue<float>() > 0.1f;

        if (isKeyDown || isControllerTriggered)
        {
            // Key or controller is being held
            f_pressed += Time.unscaledDeltaTime;
        }
        else
        {
            // Key or controller is not being held
            if (f_pressed > 0f)
            {
                f_pressed -= Time.unscaledDeltaTime;
                if (f_pressed < 0f) f_pressed = 0f;
            }
        }
    }
    private void LongTouch()
    {
        if (f_pressed > 0)
        {
            timeBtwCharsNow = FastTimeBtwChars;
        }
        else
        {
            timeBtwCharsNow = timeBtwChars;
        }
    }

    public void StartWriting(string sDialogue)
    {
        writer = sDialogue;
        tmpProText.text = "";
        StartCoroutine("TypeWriterTMP");
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
