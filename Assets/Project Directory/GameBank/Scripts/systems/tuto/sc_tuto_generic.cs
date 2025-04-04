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

public class sc_tuto_generic : MonoBehaviour
{
    [Header("General")]
    [SerializeField] private SC_Player scPlayer;
    [SerializeField] private bool isMeshable;
    [SerializeField] private bool isOnLvlTuto = false;
    private bool bIsOnBD = true;
    [SerializeField] private sc_tuto_generic scTuto = null;
    //BD
    [Header("BD")]
    [SerializeField] private int[] iBubbleNb;
    private int[] iBubbleNbAdd;
    [SerializeField] private RectTransform[] RtTuto;
    [SerializeField] private RectTransform[] RtParentTuto;
    private int _y = 0;
    [SerializeField] private bool[] bTuto;
    [SerializeField] private float[] fTimer;
    private float _ftimer = 0f;
    private bool[] b_;

    [Header("Camera")]
    [SerializeField] private GameObject GoFollowed;
    [SerializeField] private CinemachineVirtualCamera cam_Back;
    [SerializeField] private CinemachineVirtualCamera cam_Game;
    [SerializeField] private CinemachinePathBase m_Path;
    [SerializeField] private RectTransform RtGameUI;
    [SerializeField] private RectTransform RtDetectionUI;
    [SerializeField] private CinemachinePathBase.PositionUnits m_PositionUnits = CinemachinePathBase.PositionUnits.Distance;
    private float m_Position;
    private bool cameraIsTracking = false;
    private bool cameraDone = false;

    [Header("BD limits")]
    [SerializeField] private int intBdYCam = 1;
    [SerializeField] private int intYGameCam = 3;
    [SerializeField] private int intYDetectionTuto = 9;
    [SerializeField] private int intYBaitTuto = 9;
    [SerializeField] private float tresholdZ;
    private float fSpeed = 5f;

    private bool bWaitNext = false;
    private bool bOnceSkip = false;
    private bool bOnceNext = false;
    private bool bOnceBubble = false;
    private bool bHasClickedSkip = false;
    private bool bInit = false;

    private void Initialized()
    {
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
                        fSpeed = 10f;
                    }
                }
                if (bWaitNext && !bOnceNext && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump"))) //INPUT TO SHOW NEXT WHOLE BUBBLES
                {
                    bOnceSkip = false;
                    bOnceNext = true;
                    bOnceBubble = false;
                    if (_y == intYGameCam)
                    {
                        scPlayer.bisTuto = false;
                        bIsOnBD = false;
                    }
                    else if(_y == intYDetectionTuto || _y == intYBaitTuto)
                    {
                        bIsOnBD = false;
                        scPlayer.menuManager.bGameIsPaused = false;
                        scPlayer.menuManager.PauseGame();
                    }
                    if (!cameraIsTracking)
                    {
                        NextWholeBubble();
                    }
                    bWaitNext = false;
                }
                else if (!bHasClickedSkip && !bWaitNext && ((scPlayer.bIsOnComputer == false && scPlayer.control.GamePlay.Move.triggered) || Input.GetButtonDown("Jump"))) // INPUT TO SKIP 
                {
                    bHasClickedSkip = true;
                }

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
                    StartCoroutine(ImuneToTuto(scPlayer.bpmManager));
                }
            }
        }
    }

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
                b_[z] = false;
                if(z!= iBubbleNb[_y] -2)
                {
                    b_[z + 1] = true;
                    _ftimer = 0f;
                }
                else
                {
                    bHasClickedSkip = false;
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
            if (z == iBubbleNb[_y] - 2)
            {
                b_[z] = false;
                bTuto[_y] = false;
                ShowNextText(i);
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
    }
    private void ShowNextText(int i) //SHOW NEXT TEXT AND HIDE CONTINUE TEXT
    {
        RtTuto[i].anchorMin = new Vector2(0, 1);
        RtTuto[i].anchorMax = new Vector2(1, 2);
        RtTuto[i].offsetMax = new Vector2(0f, 0f);
        RtTuto[i].offsetMin = new Vector2(0f, 0f);
        RtTuto[i+1].offsetMin = Vector2.zero;
    }
    private IEnumerator ImuneToTuto(BPM_Manager bpmmanager)
    {
        scPlayer.bIsImune = true;
        yield return new WaitForSecondsRealtime(bpmmanager.FSPB * 2);
        scPlayer.bIsImune = false;
    }
    private void IntoTheGameCam() //ENABLE THE REAL CAMERA
    {
        cam_Back.enabled = false;
        cam_Game.enabled = true;
    }
    private void UIGameOn() //SHOW GAME UIS
    {
        RtGameUI.offsetMin = Vector2.zero;
        if(!isOnLvlTuto)
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
    public void StartTutoDetection()
    {
        scPlayer.menuManager.bGameIsPaused = true;
        scPlayer.menuManager.PauseGame();
        isOnLvlTuto = false;
        UIGameOn();
        _y = intYDetectionTuto;
        bIsOnBD = true;
        bWaitNext = false;
    }

    public void StartTutoBait()
    {
        scPlayer.menuManager.bGameIsPaused = true;
        scPlayer.menuManager.PauseGame();
        _y = intYBaitTuto;
        bIsOnBD = true;
        bWaitNext = false;
    }

    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player") && isMeshable)
        {
                scTuto.StartTutoDetection();
        }
    }
}
