using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Unity.VisualScripting;
using Cinemachine;
using static Cinemachine.CinemachinePathBase;
using TMPro;
using UnityEngine.UIElements;
using Unity.Burst.CompilerServices;
using UnityEngine.Rendering;
using System.Text.RegularExpressions;
using System;
using UnityEngine.SceneManagement;

public class sc_tuto_generic : MonoBehaviour
{
    [Header("General")]
    [SerializeField] private bool bIsOnLoft = false;
    [SerializeField] private SC_Player scPlayer;
    [SerializeField] private bool isMeshable;
    private bool bTutoMeshableDone = false;
    [SerializeField] private bool isOnLvlTuto = false;
    public bool bIsOnBD = true;
    [SerializeField] private sc_tuto_generic scTuto = null;
    //BD
    [Header("BD")]
    [SerializeField] private int[] iBubbleNb;
    private int[] iBubbleNbAdd;
    [SerializeField] private RectTransform RtTutoAll;
    [SerializeField] private RectTransform[] RtTuto;
    [SerializeField] private Sprite[]spriteBdTuto;
    [SerializeField] private RectTransform[] RtParentTuto;
    private int _y = 0;
    [SerializeField] private bool[] bTuto;
    [SerializeField] private float[] fTimer;
    private float _ftimer = 0f;
    private bool[] b_;
    [SerializeField] private RectTransform RtBg;
    [SerializeField] private UnityEngine.UI.Image ImBg;

    [Header("Camera")]
    [SerializeField] private GameObject GoFollowed;
    [SerializeField] private CinemachineBrain cam_Brain;
    private CinemachineVirtualCamera camBoss;
    [SerializeField] private CinemachineVirtualCamera cam_Back;
    [SerializeField] private CinemachineVirtualCamera cam_Game;
    [SerializeField] private CinemachinePathBase m_Path;
    [SerializeField] private RectTransform RtGameUI;
    [SerializeField] private CanvasGroup CgGameUI;
    [SerializeField] private RectTransform RtDetectionUI;
    [SerializeField] private CinemachinePathBase.PositionUnits m_PositionUnits = CinemachinePathBase.PositionUnits.Distance;
    private float m_Position;
    private bool cameraIsTracking = false;
    private bool cameraDone = false;
    private bool bRightBlendCamera = false;

    [Header("BD limits")]
    [SerializeField][Tooltip("The parent Rectransform number where the Camera has to begin the Backtrack.")] private int intBdYCam = 1;
    [SerializeField][Tooltip("The parent Rectransform number where the player now begins the game and is ready.")] private int intYGameCam = 3;
    [SerializeField][Tooltip("The parent Rectransform number of the tutorial to learn the detection.")] private int intYDetectionTuto = 9;
    [SerializeField][Tooltip("The parent Rectransform number of the tutorial to learn the bait.")] private int intYBaitTuto = 9;
    [SerializeField][Tooltip("The parent Rectransform number of the tutorial to introduce the boss.")] private int intYBoss = 9;
    [SerializeField][Tooltip("Where the backtrack's Camera will switch to be the player's one")] private float tresholdZ;
    private float fSpeed = 5f;

    public bool bWaitNext = false;
    private bool bOnceSkip = false;
    private bool bOnceNext = false;
    private bool bOnceBubble = false;
    private bool bHasClickedSkip = false;
    private bool bInit = false;
    private float iInput = 0;

    private void Initialized()
    {
        if(!bIsOnLoft)
        {
            cam_Brain.m_DefaultBlend.m_Time = 2f;
            if (Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value) == 0)
            {
                fSpeed = 5f;
            }
            else if (Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value) == 1 || Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value) == 3)
            {
                fSpeed = 10f;
            }
            else if (Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value) == 2)
            {
                fSpeed = 7f;
            }
        }
        else if(bIsOnLoft && scPlayer.menuManager.gameObject.GetComponent<PlayerData>().iLevelPlayer > 0)
        {
            RtTutoAll.anchorMin = new Vector2(0, 1);
            RtTutoAll.anchorMax = new Vector2(1, 2);
            RtTutoAll.offsetMax = new Vector2(0f, 0f);
            RtTutoAll.offsetMin = new Vector2(0f, 0f);

            RtBg.anchorMin = new Vector2(0f, 1f);
            RtBg.anchorMax = new Vector2(1f, 2f);
            RtBg.offsetMax = new Vector2(0f, 0f);
            RtBg.offsetMin = new Vector2(0f, 0f);

            scPlayer.bisTuto = false;
            scPlayer.bIsImune = true;
            bIsOnBD = false;
            scPlayer.bisTuto = false;
            Time.timeScale = 1f;
            cam_Back.Priority = 0;
            scPlayer.menuManager.bGameIsPaused = false;
        }
        else if(bIsOnLoft && scPlayer.menuManager.gameObject.GetComponent<PlayerData>().iLevelPlayer == 0)
        {
            scPlayer.menuManager.bGameIsPaused = true;
            CgGameUI.alpha = 0f;
        }
        iBubbleNbAdd = new int[iBubbleNb.Length +1];
        iBubbleNbAdd[0] = 0;
        for (int i =1; i< iBubbleNbAdd.Length; i++)
        {
            iBubbleNbAdd[i] = iBubbleNbAdd[i-1] + iBubbleNb[i-1];
        }
        bTuto[0] = true;
    }

    private void Update()
    {
        if(!isMeshable)
        {
            if(!bInit) //INITIALISATION
            {
                Initialized();
                bInit = true;
            }

            if (bIsOnBD)
            {
                scPlayer.bIsImune = true;
                //APPARITION DES BULLES AUTO
                if(!bIsOnLoft || (bIsOnLoft && bTuto[0] && iInput != 5) || (bIsOnLoft && bTuto[1]))
                {
                    if(iInput==0 || (bIsOnLoft && bTuto[1]))
                    {
                        if (!bWaitNext && !bHasClickedSkip && !bOnceSkip) //TO SHOW THE BUBBLES WITH TIME
                        {
                            bOnceNext = false;
                            for (int z = 0; z < bTuto.Length; z++)
                            {
                                if (bTuto[z] == true)
                                {
                                    BubbleTimer(Time.unscaledDeltaTime);
                                }
                            }
                        }
                        else if (!bWaitNext && bHasClickedSkip && !bOnceSkip) //SKIP THE BUBBLES SHOWING
                        {
                            BubbleSkip();
                            bHasClickedSkip = false;
                            bOnceSkip = true;
                            if (_y == intBdYCam)
                            {
                                fSpeed = fSpeed * 2;
                            }
                        }
                    }
                    else
                    {
                        if(!bWaitNext && !bHasClickedSkip && !bOnceSkip)
                        {
                            bOnceNext = false;
                            bHasClickedSkip = false;
                            _ftimer += Time.unscaledDeltaTime;
                            if(_ftimer>0.2f)
                            {
                                bWaitNext = true;
                                _ftimer = 0f;
                            }
                        }
                    }
                }
                else if(!cameraDone && bIsOnLoft && bTuto[0] && iInput == 5)
                {
                    _ftimer+= Time.unscaledDeltaTime;
                    if(_ftimer>=2f)
                    {
                        bTuto[0] = false;
                        bTuto[1] = true;
                        cameraDone = true;
                        _ftimer = 0f;
                    }
                }

                //INPUT
                if (!bIsOnLoft)
                {
                    if (bWaitNext && !bOnceNext && scPlayer.bHasController && scPlayer.control.GamePlay.Move.triggered) //INPUT TO SHOW NEXT WHOLE BUBBLES
                    {
                        bOnceSkip = false;
                        bOnceNext = true;
                        bOnceBubble = false;
                        if (_y == intYGameCam || _y == intYDetectionTuto || _y == intYBaitTuto)
                        {
                            bIsOnBD = false;
                            scPlayer.bisTuto = false;
                            ImuneToTuto(scPlayer.bpmManager);
                        }
                        else if(_y == intYBoss)
                        {
                            StartCoroutine(EndBossExplication());
                        }
                        if (!cameraIsTracking)
                        {
                            NextWholeBubble();
                        }
                        bWaitNext = false;
                    }
                    else if (!bHasClickedSkip && !bWaitNext && scPlayer.bHasController && scPlayer.control.GamePlay.Move.triggered) // INPUT TO SKIP 
                    {
                        bHasClickedSkip = true;
                    }
                }
                else if (bIsOnLoft)
                {
                    if(bTuto[0] && iInput==0 && !bHasClickedSkip && !bWaitNext && scPlayer.bHasController && scPlayer.control.GamePlay.Move.triggered) //TO SKIP
                    {
                        bHasClickedSkip = true;
                    }
                    else if(bTuto[0] && bWaitNext && !bOnceNext && scPlayer.bHasController && scPlayer.control.GamePlay.Move.triggered && (scPlayer.bpmManager.BGood || scPlayer.bpmManager.BPerfect) && (scPlayer.bHasController && scPlayer.control.GamePlay.Move.triggered))
                    {
                        iInput += 1;
                        float opacity = 1 - iInput / 5;
                        var tempColor = ImBg.color;
                        tempColor.a = opacity;
                        ImBg.color = tempColor;
                        bOnceSkip = false;
                        bOnceNext = true;
                        bOnceBubble = false;
                        if(iInput==5)
                        {
                            Time.timeScale = 1f;
                            RtBg.anchorMin = new Vector2(0f, 1f);
                            RtBg.anchorMax = new Vector2(1f, 2f);
                            RtBg.offsetMax = new Vector2(0f, 0f);
                            RtBg.offsetMin = new Vector2(0f, 0f);
                            NextWholeBubble();
                            cam_Back.Priority = 0;
                            scPlayer.menuManager.bGameIsPaused = true;
                        }
                        bWaitNext = false;
                    }
                    else if (bTuto[1] && !bHasClickedSkip && !bWaitNext && scPlayer.bHasController && scPlayer.control.GamePlay.Move.triggered)
                    {
                        bHasClickedSkip = true;
                    }
                    else if(bTuto[1] && bWaitNext && !bOnceNext && scPlayer.bHasController && scPlayer.control.GamePlay.Move.triggered)
                    {
                        bOnceSkip = false;
                        bOnceNext = true;
                        bOnceBubble = false;
                        RtTutoAll.anchorMin = new Vector2(0, 1);
                        RtTutoAll.anchorMax = new Vector2(1, 2);
                        RtTutoAll.offsetMax = new Vector2(0f, 0f);
                        RtTutoAll.offsetMin = new Vector2(0f, 0f);
                        bIsOnBD = false;
                        scPlayer.bisTuto = false;
                        bWaitNext = false;
                    }
                }

                if(!bIsOnLoft)
                {
                    if (GoFollowed.transform.position.z > tresholdZ && cameraIsTracking && scPlayer.menuManager.CgPauseMenu.alpha == 0f) //CAMERA IS NOT AT THE PLAYER'S POSITION
                    {
                        SetCartPosition(m_Position + fSpeed * Time.unscaledDeltaTime);
                        scPlayer.menuManager.bGameIsPaused = false;
                        scPlayer.menuManager.PauseGame();
                    }
                    else if (GoFollowed.transform.position.z <= tresholdZ && cameraIsTracking && scPlayer.menuManager.CgPauseMenu.alpha == 0f) //THE CAMERA IS AT THE PLAYER'S POSITION
                    {
                        cameraIsTracking = false;
                        cameraDone = true;
                        IntoTheGameCam();
                        NextWholeBubble();
                        bOnceSkip = false;
                        bOnceNext = true;
                        bOnceBubble = false;
                        bHasClickedSkip = false;
                        bWaitNext = false;
                        scPlayer.bIsImune = true;
                    }
                }
            }
            else if (!bRightBlendCamera && !bIsOnLoft)
            {
                _ftimer += Time.unscaledDeltaTime;
                if (_ftimer >= 3)
                {
                    cam_Brain.m_DefaultBlend.m_Time = 0.2f;
                    bRightBlendCamera = true;
                    _ftimer = 0f;
                }
            }
        }
    }
    //BUBBLE
    private void BubbleTimer(float time) //BUBBLES ARE SHOWING ONE AFTER ANOTHER
    {
        _ftimer += time;
        int max;
        if (_y + 1 >= iBubbleNbAdd.Length)
        {
            max = iBubbleNbAdd.Length;
        }
        else
        {
            max = iBubbleNbAdd[_y + 1];
        }
        if(!bOnceBubble)
        {
            b_ = new bool[max];
            b_[0] = true;
            bOnceBubble = true;
        }
        for (int i = iBubbleNbAdd[_y], z = 0; i < max && z < iBubbleNb[_y] ; i++,  z++)
        {
            if(_ftimer >= fTimer[i] && b_[z])
            {
                ShowBubble(i);
                UnreadBubble(i, max);
                b_[z] = false;
                if(z!= iBubbleNb[_y] -2)
                {
                    b_[z + 1] = true;
                    _ftimer = 0f;
                }
                else
                {
                    bHasClickedSkip = false;
                    if(!bIsOnLoft)
                    {
                        bTuto[_y] = false;
                        if (_y + 1 < bTuto.Length)
                        {
                            bTuto[_y + 1] = true;
                        }
                        if (_y == intYGameCam)
                        {
                            UIGameOn();
                        }
                        else if (_y == intBdYCam && !cameraDone)
                        {
                            Time.timeScale = 1f;
                            cameraIsTracking = true;
                            BubbleCameraOff();
                        }
                    }
                    else if(bIsOnLoft && bTuto[0])
                    {
                        CgGameUI.alpha = 1f;
                        scPlayer.menuManager.bGameIsPaused = false;
                    }
                    else if (bIsOnLoft && bTuto[1])
                    {
                        scPlayer.menuManager.bGameIsPaused = false;
                    }
                    bWaitNext = true;
                    ShowNextText(i);
                    return;
                }
            }
        }
    }
    private void BubbleSkip() //SKIP BUBBLES
    {
        _ftimer = 0f;
        int max;
        if (_y + 1 >= iBubbleNbAdd.Length)
        {
            max = iBubbleNbAdd.Length;
        }
        else
        {
            max = iBubbleNbAdd[_y + 1];
        }
        for (int i = iBubbleNbAdd[_y], z = 0; i < max && z < iBubbleNb[_y]; i++, z++)
        {
             ShowBubble(i);
            UnreadBubble(i, max);
             if (bIsOnLoft && bTuto[0])
            {
                CgGameUI.alpha = 1f;
                scPlayer.menuManager.bGameIsPaused = false;
            }
            if (z == iBubbleNb[_y] - 2)
            {
                b_[z] = false;
                if(!bIsOnLoft)
                {
                    bTuto[_y] = false;
                    if (_y + 1 < bTuto.Length)
                    {
                        bTuto[_y + 1] = true;
                    }
                    if (_y == intYGameCam)
                    {
                        UIGameOn();
                    }
                    else if (_y == intBdYCam && !cameraDone)
                    {
                        Time.timeScale = 1f;
                        cameraIsTracking = true;
                        BubbleCameraOff();
                    }
                }
                ShowNextText(i);
                bWaitNext = true;
            }
        }
    }
    private void NextWholeBubble() //HIDE WHOLE PREVIOUS PARENT BUBBLE AND Y++
    {
        int max;
        int min;
        if (_y > iBubbleNbAdd.Length)
        {
            max = iBubbleNbAdd.Length;
            min = _y - 1;
        }
        else if(_y -1 <= 0)
        {
            min = 0;
            max = iBubbleNbAdd[_y];
        }
        else
        {
            min = _y -1;
            max = iBubbleNbAdd[_y];
        }
        for (int i = min; i < max; i++)
        {
            RtTuto[i].anchorMin = new Vector2(0, 1);
            RtTuto[i].anchorMax = new Vector2(1, 2);
            RtTuto[i].offsetMax = new Vector2(0f, 0f);
            RtTuto[i].offsetMin = new Vector2(0f, 0f);
        }
        if(_y != iBubbleNbAdd.Length)
        {
            RtTuto[iBubbleNbAdd[_y]].offsetMin = Vector2.zero;
        }
        RtParentTuto[_y].anchorMin = new Vector2(0, 1);
        RtParentTuto[_y].anchorMax = new Vector2(1, 2);
        RtParentTuto[_y].offsetMax = new Vector2(0f, 0f);
        RtParentTuto[_y].offsetMin = new Vector2(0f, 0f);
        _y++;
    }
    private void BubbleCameraOff() //HIDE ONE BUBBLE
    {
        RtTuto[iBubbleNbAdd[_y]].anchorMin = new Vector2(0, 1);
        RtTuto[iBubbleNbAdd[_y]].anchorMax = new Vector2(1, 2);
        RtTuto[iBubbleNbAdd[_y]].offsetMax = new Vector2(0f, 0f);
        RtTuto[iBubbleNbAdd[_y]].offsetMin = new Vector2(0f, 0f);
    }
    private void ShowBubble(int i) //SHOW ONE BUBBLE
    {
        RtTuto[i].offsetMin = Vector2.zero;
        RtTuto[i].offsetMax = Vector2.zero;
    }
    private void UnreadBubble(int i, int max)
    {
        if(spriteBdTuto !=null && spriteBdTuto.Length >0&& i != 0 && _y ==0 && i< max-1)
        {
            RtTuto[i-1].GetComponent<UnityEngine.UI.Image>().sprite = spriteBdTuto[i-1];
        }
    }
    private void ShowNextText(int i) //SHOW NEXT TEXT AND HIDE CONTINUE TEXT
    {
        RtTuto[i].anchorMin = new Vector2(0, 1);
        RtTuto[i].anchorMax = new Vector2(1, 2);
        RtTuto[i].offsetMax = new Vector2(0f, 0f);
        RtTuto[i].offsetMin = new Vector2(0f, 0f);
        RtTuto[i+1].offsetMin = Vector2.zero;
    }
    //BACK TO REALITY
    private void ImuneToTuto(BPM_Manager bpmmanager)
    {
        scPlayer.bIsImune = true;
        bpmmanager.iTimer = 3;
    }
    private void IntoTheGameCam() //ENABLE THE REAL CAMERA
    {
        cam_Back.enabled = false;
        cam_Game.enabled = true;
    }
    private void UIGameOn() //SHOW GAME UIS
    {
        RtGameUI.offsetMin = Vector2.zero;
        RtGameUI.offsetMax = Vector2.zero;
        if (!isOnLvlTuto)
        {
            RtDetectionUI.offsetMin = Vector2.zero;
        }
    }
    private void SetCartPosition(float distanceAlongPath) //MOVE BACKWARD CAMERA
    {
        if (m_Path != null)
        {
            m_Position = m_Path.StandardizeUnit(distanceAlongPath, m_PositionUnits); //goCameraBackTrack[0].
            GoFollowed.transform.position = m_Path.EvaluatePositionAtUnit(m_Position, m_PositionUnits);
            GoFollowed.transform.rotation = m_Path.EvaluateOrientationAtUnit(m_Position, m_PositionUnits);
        }
    }
    //TUTO FROM THE GAME
    public void StartTutoDetection()
    {
        //scPlayer.menuManager.bGameIsPaused = true;
        //scPlayer.menuManager.PauseGame();
        if(scPlayer.menuManager._playerData.iLevelPlayer ==0)
        {
            scPlayer.bIsImune = true;
            scPlayer.bisTuto = true;
            isOnLvlTuto = false;
            UIGameOn();
            _y = intYDetectionTuto;
            bIsOnBD = true;
            bWaitNext = false;
        }
        else
        {
            scPlayer.bisTuto = true;
            isOnLvlTuto = false;
            UIGameOn();
        }
    }
    public void StartTutoBait()
    {
        //scPlayer.menuManager.bGameIsPaused = true;
        //scPlayer.menuManager.PauseGame();
        if (scPlayer.menuManager._playerData.iLevelPlayer == 2)
        {
            scPlayer.bIsImune = true;
            scPlayer.bisTuto = true;
            _y = intYBaitTuto;
            bIsOnBD = true;
            bWaitNext = false;
        }
    }
    public void StartBossExplication(CinemachineVirtualCamera cam)
    {
        Debug.Log("debut boss explication");
        bHasClickedSkip = false;
        bOnceSkip = false;
        camBoss = cam;
        scPlayer.bIsImune = true;
        scPlayer.bisTuto = true;
        bOnceNext = false;
        _y = intYBoss;
        bIsOnBD = true;
        bWaitNext = false;
    }
    private IEnumerator EndBossExplication()
    {
        camBoss.Priority = 2;
        yield return new WaitForSeconds(2f);
        bIsOnBD = false;
        scPlayer.bisTuto = false;
        scPlayer.menuManager.bGameIsPaused = false;
        ImuneToTuto(scPlayer.bpmManager);
    }
    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player") && isMeshable && !bTutoMeshableDone)
        {
            bTutoMeshableDone = true;
            scPlayer = collision.transform.GetComponent<SC_Player>();
            scTuto.StartTutoDetection();
        }
    }
}
