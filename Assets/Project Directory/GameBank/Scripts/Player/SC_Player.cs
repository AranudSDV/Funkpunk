using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using TMPro;
using System.Globalization;
using System;
using Unity.VisualScripting;
#if UNITY_EDITOR 
using UnityEditor.SceneManagement;
#endif
using UnityEngine.UI;
using UnityEngine.UIElements;
using UnityEngine.SceneManagement;
using static UnityEngine.EventSystems.EventTrigger;
using Cinemachine;
using UnityEngine.Rendering.PostProcessing;
using FMODUnity;
using System.Text.RegularExpressions;
using DG.Tweening;
using UnityEditor;
using UnityEngine.EventSystems;
//using UnityEditor.PackageManager;

public class SC_Player : MonoBehaviour
{
    public bool bisTuto = false;
    public MenuManager menuManager;
    public bool bHasController = true;
    public BPM_Manager bpmManager;
    public sc_tuto_generic tutoGen = null;

    //LES CHALLENGES
    private bool bHasBeenDetectedOneTime = false;
    public bool bHasNoMiss = true;
    private int itagDone = 0;

    //LE PLAYER ET SES MOUVEMENTS
    [Header("Player and movement")]
    public Vector3 lastMoveDirection;
    private Vector3 lastLastMoveDirection;
    Vector2 move;
    [SerializeField] public PlayerControl control;
    public GameObject PlayerCapsule;
    private Vector3 posMesh;
    [SerializeField] private Vector3 localPosMesh;
    private float tolerance = 0.5f;
    public bool canMove = false;
    [SerializeField]private GameObject GoVfxSteps;
    [SerializeField] private Vector3 fPosVFX_steps;
    [SerializeField] private ParticleSystem vfx_steps;
    [SerializeField] private GameObject GoVfxRotToRight;
    [SerializeField] private Vector3 fPosVFX_RotToRight;
    [SerializeField] private ParticleSystem vfx_RotToRight;
    [SerializeField] private GameObject GoVfxRotToLeft;
    [SerializeField] private Vector3 fPosVFX_RotToLeft;
    [SerializeField] private ParticleSystem vfx_RotToLeft;
    public bool bcanRotate = false;
    public bool bIsImune = false;
    private bool bIsBeingAnimated = false;

    //LE BAIT
    [Header("Bait")]
    [SerializeField] private GameObject GOBait;
    [SerializeField] private CinemachineVirtualCamera cinemachineVirtualCamera;
    private CinemachineBasicMultiChannelPerlin cinemachineBasicMultiChannelPerlin;
    private GameObject GO_BaitInst;
    public bool hasAlreadyBaited = false;
    private float fThrowMultiplier = 1f;
    private float fShakeFoeBasic = 9f;

    //LE SCORE
    [Header("Score")]
    public float FScore;
    public float fNbBeat;
    private float fPercentScore;
    public TMP_Text TMPScore;
    private bool bIsEndGame = false;

    //LE JOYSTICK
    [Header("Joystick")]
    private float[] angles = { -135f, -90f, -45f, 0f, 45f, 90f, 135f, 180f };
    private int currentAngleIndex = 3;

    //LA DETECTION
    [Header("Detection")]
    public float FDetectionLevel = 0f;
    private float fDetectionLevelMax = 100f;
    [SerializeField] private SC_FieldOfView[] allEnemies;
    [SerializeField] private GameObject GoVfxDetected;
    [SerializeField] private Vector3 fPosVFX_detected;
    public float FTimeWithoutLooseDetection = 5f;
    public bool BisDetectedByAnyEnemy = false;
    [SerializeField] private int iTimeFoeDisabled = 5;
    [SerializeField] private Material[] mEye;
    [SerializeField] private UnityEngine.UI.Image imgEye;

    //LE TAG
    [Header("Tag")]
    public float taggingRange = 1f;
    private RaycastHit[] hitInfo = new RaycastHit[4];
    [SerializeField] private GameObject GoVfxTag;
    [SerializeField] private ParticleSystem vfx_tag;
    [SerializeField] private LayerMask LMask;

    //CHECKPOINTS STATS
    [Header("Checkpoints Stats")]
    [SerializeField] private sc_CheckPoint[] checkpoints;
    [SerializeField] private ing_Tag[] allTagsUntil1stCheckPoint;
    [SerializeField] private Vector3 posLastCheckPoint;
    [SerializeField] private float posYInit;
    private int iTagPreviouslyDone = 0;
    private float FPreviousScore = 0f;
    private float fPreviousNbBeat = 0f;
    public int iCheckPoint = 0;
    public bool bIsReplaying = false;


    static int Hasard(int a, int b) //Choisi un random.
    {
        System.Random rdm = new System.Random();
        int hasard = rdm.Next(a, b + 1); //Aller jusqu'a le b inclu.
        return hasard;
    }

    public void InitializeGamepad()
    {
        if (bHasController)
        {
            control = new PlayerControl();
            control.GamePlay.Enable();
        }
    }
    public void DisableGamepad()
    {
        if (bHasController)
        {
            control.GamePlay.Disable();
        }
    }
    void Start()
    {
        FScore = Mathf.Round(fPercentScore);
        bIsEndGame = false;
        posMesh = PlayerCapsule.transform.position;
        CheckControllerStatus();
        UnityEngine.Cursor.lockState = CursorLockMode.Locked;
        cinemachineBasicMultiChannelPerlin = cinemachineVirtualCamera.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();
        if (menuManager == null)
        {
            GameObject goMenu = GameObject.FindWithTag("Manager");
            if (goMenu == null)
            {
                bHasController = false;
            }
            else
            {
                menuManager = goMenu.GetComponent<MenuManager>();
                control = menuManager.control;
                bHasController = menuManager.controllerConnected;
                menuManager.scPlayer = this;
            }
        }
        else
        {
            control = menuManager.control;
            bHasController = menuManager.controllerConnected;
            menuManager.scPlayer = this;
        }
        EyeDetection();
    }
    
    //L'UPDATE
    public void Update()
    {
        if (bHasController && control == null)
        {
            Debug.Log("no control");
            InitializeGamepad();
        }
        CheckControllerStatus();
        if(fNbBeat>0&& FScore>0)
        {
            fPercentScore = FScore / fNbBeat;
        }
        else
        {
            fPercentScore = 0;
        }
        if(SceneManager.GetActiveScene().name == "Loft" && fNbBeat >=10f)
        {
            FScore = Mathf.Round(fPercentScore);
            fNbBeat = 1;
        }
        TMPScore.SetText(Mathf.Round(fPercentScore).ToString() + "%");
        if(FDetectionLevel>= fDetectionLevelMax && !bIsEndGame)
        {
            EndGame(false, menuManager._playerData);
        }
        if(FDetectionLevel <0)
        {
            FDetectionLevel = 0;
            EyeDetection();
        }
        if (bcanRotate == true)
        {
            UpdateDirAndMovOnJoystickOrPC();
        }
        EnemieDetection();
    }

    //CONCERNANT LES CONTROLS
    private void UpdateDirAndMovOnJoystickOrPC()
    {
        //MOUVEMENT SUR CLAVIER OU MANETTE?
        if (bHasController)
        {
            move = control.GamePlay.Orientation.ReadValue<Vector2>();
        }
        //UDPATE LA DIRECTION
        if (move != Vector2.zero)
        {
            lastLastMoveDirection = lastMoveDirection;
            Vector3 direction = Vector3.zero;
            if (bHasController)
            {
                direction = GetDirectionFromJoystick(move);
                if (!bIsBeingAnimated)
                {
                    RotationVFX(direction, bpmManager.FSPB / 5);
                }
            }
            else if (bHasController)
            {
                direction = GetDirectionFromClavier();
                if (!bIsBeingAnimated)
                {
                    RotationVFX(direction, bpmManager.FSPB / 5);
                }
            }
            if (direction != Vector3.zero)
            {
                lastMoveDirection = direction;
            }
        }
    }
    Vector3 GetDirectionFromClavier()
    {
        if (Input.GetKeyDown(KeyCode.A) && Input.GetKeyDown(KeyCode.S))
        {
            return new Vector3(-1, 0, -1);
        }
        else if (Input.GetKeyDown(KeyCode.A) && Input.GetKeyDown(KeyCode.W))
        {
            return new Vector3(-1, 0, 1);
        }
        else if (Input.GetKeyDown(KeyCode.W) && Input.GetKeyDown(KeyCode.D))
        {
            return new Vector3(1, 0, 1);
        }
        else if (Input.GetKeyDown(KeyCode.D) && Input.GetKeyDown(KeyCode.S))
        {
            return new Vector3(1, 0, -1);
        }
        else if (Input.GetKeyDown(KeyCode.A))
        {
            return Vector3.left;
        }
        else if (Input.GetKeyDown(KeyCode.W))
        {
            return Vector3.forward;
        }
        else if (Input.GetKeyDown(KeyCode.D))
        {
            return Vector3.right;
        }
        else if (Input.GetKeyDown(KeyCode.S))
        {
            return Vector3.back;
        }
        else
        {
            return Vector3.zero;
        }
    }
    private Vector3 GetDirectionFromJoystick(Vector2 moveInput)
    {
        //limite joystick
        if (moveInput.x > 0.5f && Mathf.Abs(moveInput.y) <= 0.2f)  // Droite
            return Vector3.right;  // (1, 0, 0)
        if (moveInput.x < -0.5f && Mathf.Abs(moveInput.y) <= 0.2f)  // Gauche
            return Vector3.left;  // (-1, 0, 0)
        if (moveInput.y > 0.9f && Mathf.Abs(moveInput.x) <= 0.3f)  // Haut
            return Vector3.forward;  // (0, 0, 1)
        if (moveInput.y < -0.9f && Mathf.Abs(moveInput.x) <= 0.3f)  // Bas
            return Vector3.back;  // (0, 0, -1)

        // Diagonales
        if (moveInput.x > 0.5f && moveInput.y > 0.5f)  // Haut-Droite
            return new Vector3(1, 0, 1);
        if (moveInput.x < -0.5f && moveInput.y > 0.5f)  // Haut-Gauche
            return new Vector3(-1, 0, 1);
        if (moveInput.x > 0.5f && moveInput.y < -0.5f)  // Bas-Droite
            return new Vector3(1, 0, -1);
        if (moveInput.x < -0.5f && moveInput.y < -0.5f)  // Bas-Gauche
            return new Vector3(-1, 0, -1);
        return Vector3.zero;
    }

    //CONCERNANT LE BAIT
    public void ShootBait(ing_Bait bait)
    {
        GO_BaitInst = bait.transform.gameObject;
        CheckForward(lastMoveDirection, 0f);
        if (fThrowMultiplier == 0f)
        {
            //nothing
        }
        else
        {
            Vector3 _spawnpos = new Vector3(this.transform.position.x, this.transform.position.y - 0.5f, this.transform.position.z) + (lastMoveDirection * fThrowMultiplier);
            bait.newPos = _spawnpos;
            bait.midPos = new Vector3(this.transform.position.x, this.transform.position.y + 2.5f, this.transform.position.z) + (lastMoveDirection * fThrowMultiplier / 2);
            bait.bIsBeingThrown = true;
            StartCoroutine(CameraShake(fThrowMultiplier*1/3, bpmManager.FSPB*1/4));
        }
    }

    //VERIFIER LE MOUVEMENT
    public void CheckForward(Vector3 vectDir, float fRange)
    {
        if (fRange == taggingRange)
        {
            // 1. Check for diagonal movement first
            if (vectDir.x != 0f && vectDir.z != 0f) // Diagonal movement
            {
                Vector3 diagonalCheckPosition = transform.position + vectDir * fRange;

                // Use OverlapSphere to check for colliders at the diagonal position
                Collider[] intersecting = Physics.OverlapSphere(diagonalCheckPosition, 0.4f, LMask);
                bool canMoveDiagonally = true;

                if (intersecting.Length > 0)
                {
                    // Loop through colliders to check tags
                    foreach (Collider collider in intersecting)
                    {
                        if (!collider.CompareTag("Bait") && !collider.CompareTag("Tagging"))
                        {
                            canMoveDiagonally = false; // Block movement if an unpassable object is found
                            continue;
                        }
                        else if(collider.CompareTag("Tagging"))
                        {
                            bIsBeingAnimated = true;
                            ing_Tag ingTag = collider.transform.gameObject.GetComponent<ing_Tag>();
                            ingTag.textOnWall.color = bpmManager.colorMiss;
                            for (int i = 0; i < 4; i++)
                            {
                                if (bpmManager.bPlayBad)
                                {
                                    if (ingTag.textOnWall.text == i.ToString() + "/3")
                                    {
                                        ingTag.textOnWall.text = (i + 1).ToString() + "/3";
                                        TaggingFeedback(bpmManager.FSPB, vectDir);
                                        StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                        break;
                                    }
                                }
                                else if (bpmManager.bPlayGood)
                                {
                                    if (ingTag.textOnWall.text == i.ToString() + "/3")
                                    {
                                        if (i < 2)
                                        {
                                            ingTag.textOnWall.text = (i + 2).ToString() + "/3";
                                            TaggingFeedback(bpmManager.FSPB, vectDir);
                                            StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                        }
                                        else
                                        {
                                            ingTag.textOnWall.text = "3/3";
                                            TaggingFeedback(bpmManager.FSPB, vectDir);
                                            StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                        }
                                        break;
                                    }
                                }
                                else if (bpmManager.bPlayPerfect)
                                {
                                    ingTag.textOnWall.text = "3/3";
                                    TaggingFeedback(bpmManager.FSPB, vectDir);
                                    StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                    break;
                                }
                                else if (!bpmManager.bPlayPerfect && !bpmManager.bPlayGood && !bpmManager.bPlayBad)
                                {
                                    //Vector3 newDirection = FindNewDirection(vectDir, fRange);
                                    Move(Vector3.zero);
                                    return;
                                }
                            }
                            if (ingTag.textOnWall.text == "1/3")
                            {
                                ingTag.textOnWall.color = bpmManager.colorBad;
                            }
                            else if (ingTag.textOnWall.text == "2/3")
                            {
                                ingTag.textOnWall.color = bpmManager.colorGood;
                            }
                            else if (ingTag.textOnWall.text == "3/3")
                            {
                                ingTag.textOnWall.color = bpmManager.colorPerfect;
                                ingTag._renderer.material = ingTag.taggedMaterial; //le joueur tag
                                ingTag.transform.gameObject.tag = "Wall";
                                ingTag.goArrow.transform.localPosition = new Vector3(ingTag.goArrow.transform.localPosition.x, ingTag.goArrow.transform.localPosition.y + 50f, ingTag.goArrow.transform.localPosition.z);
                                itagDone += 1;
                                if (ingTag.scFoes != null)
                                {
                                    foreach (SC_FieldOfView foe in ingTag.scFoes)
                                    {
                                        foe.bIsDisabled = true;
                                        foe.FoeDisabled(foe.bIsDisabled);
                                        foe.i_EnnemyBeat = -iTimeFoeDisabled * 10;
                                    }
                                    CameraShake(fShakeFoeBasic, bpmManager.FSPB * 1 / 3);
                                }
                                if (ingTag.transform.gameObject.name == "EndingWall")
                                {
                                    EndDialogue();
                                }
                                if (ingTag.bBossTag)
                                {
                                    ingTag.scBoss.iNbTaggsDone += 1;
                                    ingTag.scBoss.BossTagAngle();
                                    //feedback degat boss
                                    CameraShake(fShakeFoeBasic * 2, bpmManager.FSPB * 1 / 3);
                                }
                                return;
                            }
                        }
                        else if (collider.CompareTag("MapObject"))
                        {
                            TextMeshPro textOnWall = collider.transform.GetChild(0).GetComponent<TextMeshPro>();
                            StartCoroutine(EnoughPercentLoft(textOnWall));
                            /*if (fPercentScore>= 50f)
                            {
                                TextMeshPro textOnWall = hitInfo.transform.GetChild(0).GetComponent<TextMeshPro>();
                                StartCoroutine(EnoughPercentLoft(textOnWall));
                            }
                            else
                            {
                                TextMeshPro textOnWall = hitInfo.transform.GetChild(0).GetComponent<TextMeshPro>();
                                StartCoroutine(NotEnoughPercentLoft(textOnWall));
                            }*/
                        }
                    }
                }
                if (canMoveDiagonally)
                {
                    // Move diagonally if no blocking objects or only passable ones
                    Move(vectDir);
                }
                else
                {
                    Vector3 newDirection = FindNewDirection(vectDir, fRange);
                    if (newDirection != Vector3.zero)
                    {
                        Move(newDirection);
                    }
                }
            }
            // Check for walls in the current direction
            else
            {
                if (Physics.Raycast(transform.position, vectDir, out RaycastHit hitInfo, fRange + 0.2f, LMask))
                {
                    if (hitInfo.transform.CompareTag("Tagging")) //c'est un mur � tagger
                    {
                        bIsBeingAnimated = true;
                        ing_Tag ingTag = hitInfo.transform.gameObject.GetComponent< ing_Tag>();
                        ingTag.textOnWall.color = bpmManager.colorMiss;
                        for (int i = 0;i<4; i++)
                        {
                            if(bpmManager.bPlayBad)
                            {
                                if(ingTag.textOnWall.text == i.ToString() + "/3")
                                {
                                    ingTag.textOnWall.text = (i + 1).ToString() + "/3";
                                    TaggingFeedback(bpmManager.FSPB, vectDir);
                                    StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                    break;
                                }
                            }
                            else if (bpmManager.bPlayGood)
                            {
                               if(ingTag.textOnWall.text == i.ToString() + "/3")
                                {
                                    if (i < 2)
                                    {
                                        ingTag.textOnWall.text = (i + 2).ToString() + "/3";
                                        TaggingFeedback(bpmManager.FSPB, vectDir);
                                        StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                    }
                                    else
                                    {
                                        ingTag.textOnWall.text = "3/3";
                                        TaggingFeedback(bpmManager.FSPB, vectDir);
                                        StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                    }
                                    break;
                                }
                            }
                            else if(bpmManager.bPlayPerfect)
                            {
                                ingTag.textOnWall.text = "3/3";
                                TaggingFeedback(bpmManager.FSPB, vectDir);
                                StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                break;
                            }
                            else if(!bpmManager.bPlayPerfect && !bpmManager.bPlayGood && !bpmManager.bPlayBad)
                            {
                                //Vector3 newDirection = FindNewDirection(vectDir, fRange);
                                Move(Vector3.zero);
                                return ;
                            }
                        }
                        if (ingTag.textOnWall.text == "1/3")
                        {
                            ingTag.textOnWall.color = bpmManager.colorBad;
                        }
                        else if(ingTag.textOnWall.text == "2/3")
                        {
                            ingTag.textOnWall.color = bpmManager.colorGood;
                        }
                        else if (ingTag.textOnWall.text == "3/3")
                        {
                            ingTag.textOnWall.color = bpmManager.colorPerfect;
                            ingTag._renderer.material = ingTag.taggedMaterial; //le joueur tag
                            ingTag.transform.gameObject.tag = "Wall";
                            ingTag.goArrow.transform.localPosition = new Vector3(ingTag.goArrow.transform.localPosition.x, ingTag.goArrow.transform.localPosition.y + 50f, ingTag.goArrow.transform.localPosition.z);
                            itagDone += 1;
                            if(ingTag.scFoes!= null)
                            {
                                foreach(SC_FieldOfView foe in ingTag.scFoes)
                                {
                                    foe.bIsDisabled = true;
                                    foe.FoeDisabled(foe.bIsDisabled);
                                    foe.i_EnnemyBeat = -iTimeFoeDisabled*10;
                                }
                                StartCoroutine(CameraShake(fShakeFoeBasic, bpmManager.FSPB * 1 / 3));
                            }
                            if (ingTag.transform.gameObject.name == "EndingWall")
                            {
                                EndDialogue();
                            }
                            if(ingTag.bBossTag)
                            {
                                ingTag.scBoss.iNbTaggsDone += 1;
                                ingTag.scBoss.BossTagAngle();
                                //feedback degat boss
                                StartCoroutine(CameraShake(fShakeFoeBasic * 2, bpmManager.FSPB * 1 / 3));
                            }
                            return;
                        }
                    }
                    else if (hitInfo.transform.CompareTag("Wall") || hitInfo.transform.CompareTag("Enemies 1"))
                    {
                        // Wall detected, find a new direction
                        Vector3 newDirection = FindNewDirection(vectDir, fRange);
                        if (newDirection != Vector3.zero)
                        {
                            Move(newDirection);
                        }
                    }
                    else if (hitInfo.transform.CompareTag("Untagged"))
                    {
                        // No wall, move forward
                        Move(vectDir);
                    }
                    else if(hitInfo.transform.CompareTag("MapObject"))
                    {
                        TextMeshPro textOnWall = hitInfo.transform.GetChild(0).GetComponent<TextMeshPro>();
                        StartCoroutine(EnoughPercentLoft(textOnWall));
                        /*if (fPercentScore>= 50f)
                        {
                            TextMeshPro textOnWall = hitInfo.transform.GetChild(0).GetComponent<TextMeshPro>();
                            StartCoroutine(EnoughPercentLoft(textOnWall));
                        }
                        else
                        {
                            TextMeshPro textOnWall = hitInfo.transform.GetChild(0).GetComponent<TextMeshPro>();
                            StartCoroutine(NotEnoughPercentLoft(textOnWall));
                        }*/
                    }
                    else
                    {
                        // No wall, move forward
                        Move(vectDir);
                    }
                }
                else
                {
                    // Nothing in front, move forward
                    Move(vectDir);
                }
            }
        }
        else
        {
            for (int i = 1; i < 10; i++)
            {
                float floatNumber = Convert.ToSingle(i);
                // 1. Check for diagonal movement first
                if (vectDir.x != 0f && vectDir.z != 0f) // Diagonal movement
                {
                    Vector3 diagonalCheckPosition = transform.position + vectDir.normalized * floatNumber;
                    // Use OverlapSphere to check for colliders at the diagonal position
                    Collider[] intersecting = Physics.OverlapSphere(diagonalCheckPosition, 0.1f, LMask);
                    if (intersecting.Length > 0 && ((!bpmManager.bPlayPerfect && !bpmManager.bPlayGood && !bpmManager.bPlayBad && i <= 5) || (bpmManager.bPlayBad && i <= 7) || (bpmManager.bPlayGood && i <= 8) || (bpmManager.bPlayPerfect && i <= 9)))
                    {
                        foreach(Collider col in intersecting)
                        {
                            if (col.transform.CompareTag("Wall") || col.transform.CompareTag("Tagging") || col.transform.CompareTag("Bait"))
                            {
                                bIsBeingAnimated = true;
                                fThrowMultiplier = floatNumber - 1f;
                                ThrowingFeedback(bpmManager.FSPB);
                                return;
                            }
                            else if (col.transform.CompareTag("Enemies 1")) //il y a un ennemi devant le joueur
                            {
                                bIsBeingAnimated = true;
                                fThrowMultiplier = floatNumber - 1f;
                                SC_FieldOfView scEnemy = col.transform.gameObject.GetComponent<SC_FieldOfView>();
                                scEnemy.bIsDisabled = true;
                                scEnemy.FoeDisabled(scEnemy.bIsDisabled);
                                scEnemy.i_EnnemyBeat = -iTimeFoeDisabled;
                                ThrowingFeedback(bpmManager.FSPB);
                                //Unable l'ennemi
                                return;
                            }
                            else //nothing in front of the player
                            {
                                //nothing
                            }
                        }
                    }
                    else if ((!bpmManager.bPlayPerfect && !bpmManager.bPlayGood && !bpmManager.bPlayBad && i == 6) || (bpmManager.bPlayBad && i == 8) || (bpmManager.bPlayGood && i == 9) || (bpmManager.bPlayPerfect && i == 10))
                    {
                        bIsBeingAnimated = true;
                        fThrowMultiplier = floatNumber - 1f;
                        ThrowingFeedback(bpmManager.FSPB);
                        return;
                    }
                    else
                    {
                        //nothing
                    }
                }
                // Check for walls in the current direction
                else if (Physics.Raycast(transform.position, vectDir, out RaycastHit hitInfo1, floatNumber + 0.1f, LMask) && ((!bpmManager.bPlayPerfect && !bpmManager.bPlayGood && !bpmManager.bPlayBad && i <= 5) || (bpmManager.bPlayBad && i <= 7) || (bpmManager.bPlayGood && i <= 8) || (bpmManager.bPlayPerfect && i <= 9))) //qqc est devant le joueur au plus pr�s
                {
                    if (hitInfo1.transform.CompareTag("Wall") || hitInfo1.transform.CompareTag("Tagging") || hitInfo1.transform.CompareTag("Bait"))//il y a un mur devant le joueur
                    {
                        bIsBeingAnimated = true;
                        fThrowMultiplier = floatNumber - 1f;
                        ThrowingFeedback(bpmManager.FSPB);
                        return;
                    }
                    else if (hitInfo1.transform.CompareTag("Enemies 1")) //il y a un ennemi devant le joueur
                    {
                        bIsBeingAnimated = true;
                        fThrowMultiplier = floatNumber - 1f;
                        SC_FieldOfView scEnemy = hitInfo1.transform.gameObject.GetComponent<SC_FieldOfView>();
                        scEnemy.bIsDisabled = true;
                        scEnemy.FoeDisabled(scEnemy.bIsDisabled);
                        scEnemy.i_EnnemyBeat = -iTimeFoeDisabled;
                        ThrowingFeedback(bpmManager.FSPB);
                        //Unable l'ennemi
                        return;
                    }
                    else //nothing in front of the player
                    {
                        //nothing
                    }
                }
                else if ((!bpmManager.bPlayPerfect && !bpmManager.bPlayGood && !bpmManager.bPlayBad && i == 6) || (bpmManager.bPlayBad && i == 8) || (bpmManager.bPlayGood && i == 9) || (bpmManager.bPlayPerfect && i == 10))
                {
                    bIsBeingAnimated = true;
                    fThrowMultiplier = floatNumber - 1f;
                    ThrowingFeedback(bpmManager.FSPB);
                    return;
                }
                else
                {
                    //nothing
                }
            }
        }
        bIsBeingAnimated = false;
    }
    private Vector3 FindNewDirection(Vector3 currentDirection, float range)
    {
        // Define possible directions in order of preference
        Vector3[] directions = {
            transform.right, Vector3.left, Vector3.back, transform.forward,
            transform.forward + transform.right,   // Diagonal Top-Right
            transform.forward + Vector3.left,      // Diagonal Top-Left
            Vector3.back + transform.right,        // Diagonal Bottom-Right
            Vector3.back + Vector3.left            // Diagonal Bottom-Left
        };

        foreach (var dir in directions)
        {
            // Skip current direction
            if (dir == currentDirection)
                continue;

            if (dir == transform.right || dir == Vector3.left || dir == Vector3.back || dir == transform.forward)
            {
                // Check for walls in the new direction
                if (!Physics.Raycast(transform.position, dir, out RaycastHit hitInfo, range + 0.2f, LMask))
                {
                    return dir; // Return the first valid direction
                }
            }
            else
            {
                Vector3 diagonalCheckPosition = transform.position + dir * range;

                // Use OverlapSphere to check for colliders at the diagonal position
                Collider[] intersecting = Physics.OverlapSphere(diagonalCheckPosition, 0.4f, LMask);

                if (intersecting.Length > 0)
                {
                    bool bContinue = true;
                    // Loop through colliders to check tags
                    foreach (Collider collider in intersecting)
                    {
                        if (!collider.CompareTag("Bait"))// Block movement if an unpassable object is found
                        {
                            bContinue = false;
                            continue;
                        }
                    }
                    if(bContinue)
                    {
                        return dir; // Return the first valid direction
                    }
                }
                else
                {
                    return dir;
                }
            }
        }

        // If all directions are blocked, return Vector3.zero
        return Vector3.zero;
    }
    private void Move(Vector3 direction)
    {
        // diagonale ?
        if(bIsReplaying)
        {
            Vector3 newPos = posLastCheckPoint + Vector3.zero;
            this.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB).SetEase(Ease.OutBack).SetAutoKill(true);
        }
        else
        {
            if (direction.x != 0 && direction.z != 0 && direction != Vector3.right)
            {
                Vector3 newPos = this.transform.position + new Vector3(Mathf.Sign(direction.x), 0, Mathf.Sign(direction.z));
                this.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB).SetEase(Ease.OutBack).SetAutoKill(true);
                //DOMove(newPos, bpmManager.FSPB).SetAutoKill(true);
                //this.transform.GetChild(0).gameObject.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB).SetEase(Ease.OutBack).SetAutoKill(true);
                //this.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB, true).SetEase(Ease.OutBack).SetAutoKill(true);
            }
            else
            {
                Vector3 newPos = this.transform.position + direction;
                this.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB).SetEase(Ease.OutBack).SetAutoKill(true);
                //DOMove(newPos, bpmManager.FSPB).SetAutoKill(true);
                //this.transform.GetChild(0).gameObject.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB).SetEase(Ease.OutBack).SetAutoKill(true);
                //this.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB, true).SetEase(Ease.OutBack).SetAutoKill(true);
            }
        }
        StartCoroutine(MouvementVFX(bpmManager.FSPB));
        canMove = false;
    }

    //CONCERNANT L'UI ET LES FEEDBACKS IMPORTANTS
    private void UpdateDirectionUI()
    {
        if (Mathf.Abs(lastMoveDirection.x) > tolerance && Mathf.Abs(lastMoveDirection.z) <= tolerance)
        {
            // Mouvement gauche ou droite
            if (Mathf.Sign(lastMoveDirection.x) == -1)
            {
                currentAngleIndex = 1;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1)
            {
                currentAngleIndex = 5;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
            }
        }
        else if (Mathf.Abs(lastMoveDirection.z) > tolerance && Mathf.Abs(lastMoveDirection.x) <= tolerance)
        {
            // Mouvement haut ou bas
            if (Mathf.Sign(lastMoveDirection.z) == 1)
            {
                currentAngleIndex = 3;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
            }
            else if (Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 7;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
            }
        }
        else if (Mathf.Abs(lastMoveDirection.x) > tolerance && Mathf.Abs(lastMoveDirection.z) > tolerance)
        {
            // Mouvement diagonal
            if (Mathf.Sign(lastMoveDirection.x) == -1 && Mathf.Sign(lastMoveDirection.z) == 1)
            {
                currentAngleIndex = 2;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1 && Mathf.Sign(lastMoveDirection.z) == 1)
            {
                currentAngleIndex = 4;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
            }
            else if (Mathf.Sign(lastMoveDirection.x) == -1 && Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 0;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1 && Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 6;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
            }
        }
    }
    private IEnumerator MouvementVFX(float time)
    {
        yield return new WaitForSeconds(time * 2/5f);
        GoVfxSteps.transform.localPosition = fPosVFX_steps;
        vfx_steps.Play();
        yield return new WaitForSeconds(time * (1 - 2 / 5f));
        vfx_steps.Stop();
        GoVfxSteps.transform.localPosition = fPosVFX_steps + new Vector3(0f,50f,0f);
    }
    private IEnumerator NotEnoughPercentLoft(TextMeshPro txt)
    {
        txt.text = "50%";
        txt.color = bpmManager.colorMiss;
        yield return new WaitForSeconds(0.7f);
        txt.color = new Color32(255, 114, 255, 255);
        txt.text = "! ! !";
    }
    private IEnumerator EnoughPercentLoft(TextMeshPro txt)
    {
        txt.text = Mathf.Round(fPercentScore).ToString() + "%";
        txt.color = bpmManager.colorPerfect;
        yield return new WaitForSeconds(0.7f);
        menuManager.LoadScene("LevelChoosing");
        UnityEngine.Cursor.lockState = CursorLockMode.None;
    }
    private void TaggingFeedback(float time, Vector3 dir)
    {
        if (dir.x != 0)
        {
            DG.Tweening.Sequence taggingSequence = DOTween.Sequence();
            taggingSequence.Append(PlayerCapsule.transform.DOMoveY(posMesh.y + 1f, time * 1 / 6));
            taggingSequence.Join(PlayerCapsule.transform.DOLocalMoveZ(localPosMesh.z + 0.75f, time * 1 / 6));
            taggingSequence.Join(PlayerCapsule.transform.DORotate(new Vector3(0, -60f, 0), time * 1 / 6, RotateMode.LocalAxisAdd));
            taggingSequence.Append(PlayerCapsule.transform.DORotate(new Vector3(0, 120f, 0), time * 2 / 6, RotateMode.LocalAxisAdd));
            taggingSequence.Join(PlayerCapsule.transform.DOLocalMoveZ(localPosMesh.z - 0.75f, time * 1 / 6));
            taggingSequence.Append(PlayerCapsule.transform.DORotate(new Vector3(0, -60, 0), time * 1 / 6, RotateMode.LocalAxisAdd));
            taggingSequence.Join(PlayerCapsule.transform.DOLocalMoveZ(localPosMesh.z, time * 1 / 6));
            taggingSequence.Join(PlayerCapsule.transform.DOMoveY(posMesh.y, time * 1 / 6));
            taggingSequence.OnComplete(() =>
            {
                PlayerCapsule.transform.localPosition = localPosMesh;
            });
        }
        else if(dir.z != 0)
        {
            DG.Tweening.Sequence taggingSequence = DOTween.Sequence();
            taggingSequence.Append(PlayerCapsule.transform.DOMoveY(posMesh.y + 1f, time * 1 / 6));
            taggingSequence.Join(PlayerCapsule.transform.DOLocalMoveX(localPosMesh.z + 0.75f, time * 1 / 6));
            taggingSequence.Join(PlayerCapsule.transform.DORotate(new Vector3(0, -30f, 0), time * 1 / 6, RotateMode.LocalAxisAdd));
            taggingSequence.Append(PlayerCapsule.transform.DORotate(new Vector3(0, 60f, 0), time * 2 / 6, RotateMode.LocalAxisAdd));
            taggingSequence.Join(PlayerCapsule.transform.DOLocalMoveX(localPosMesh.z - 0.75f, time * 1 / 6));
            taggingSequence.Append(PlayerCapsule.transform.DORotate(new Vector3(0, -30, 0), time * 1 / 6, RotateMode.LocalAxisAdd));
            taggingSequence.Join(PlayerCapsule.transform.DOLocalMoveX(localPosMesh.z, time * 1 / 6));
            taggingSequence.Join(PlayerCapsule.transform.DOMoveY(posMesh.y, time * 1 / 6));
            taggingSequence.OnComplete(() =>
            {
                PlayerCapsule.transform.localPosition = localPosMesh;
            });
        }
    }
    private IEnumerator TagFeedback(Vector3 dir, float time)
    {
        yield return new WaitForSeconds(time * 1 / 6);
        GoVfxTag.transform.localEulerAngles = dir;
        GoVfxTag.transform.localPosition = -dir *0.01f;
        vfx_tag.Play();
        yield return new WaitForSeconds(time*4/6);
        vfx_tag.Stop();
        GoVfxTag.transform.localPosition = dir + new Vector3(0f, 50f, 0f);
    }
    private void ThrowingFeedback(float time)
    {
        DG.Tweening.Sequence throwingSequence = DOTween.Sequence();
        throwingSequence.Append(PlayerCapsule.transform.DOMoveY(posMesh.y + 1f, time * 1 / 9));
        throwingSequence.Append(PlayerCapsule.transform.DORotate(new Vector3(-45, 0, 0), time * 1 / 6, RotateMode.LocalAxisAdd));
        throwingSequence.AppendInterval(time * 1 / 6);
        throwingSequence.Append(PlayerCapsule.transform.DORotate(new Vector3(45, 0, 0), time * 1 / 6, RotateMode.LocalAxisAdd));
        throwingSequence.AppendInterval(time * 5/18);
        throwingSequence.Append(PlayerCapsule.transform.DOMoveY(posMesh.y, time * 1 / 9));
        throwingSequence.OnComplete(() =>
        {
            PlayerCapsule.transform.localPosition = localPosMesh;
        });
    }
    private IEnumerator CameraShake(float intensity, float time)
    {
        cinemachineBasicMultiChannelPerlin.m_AmplitudeGain = intensity;
        yield return new WaitForSeconds(time);
        cinemachineBasicMultiChannelPerlin.m_AmplitudeGain = 0f;
    }
    private IEnumerator RotationToRight(float time)
    {
        GoVfxRotToRight.transform.localPosition = fPosVFX_RotToRight;
        vfx_RotToRight.Play();
        yield return new WaitForSeconds(time * 4 / 5);
        vfx_RotToRight.Stop();
        GoVfxRotToRight.transform.localPosition = new Vector3(0f, 50f, 0f);
    }
    private IEnumerator RotationToLeft(float time)
    {
        GoVfxRotToLeft.transform.localPosition = fPosVFX_RotToLeft;
        vfx_RotToLeft.Play();
        yield return new WaitForSeconds(time * 4 / 5);
        vfx_RotToLeft.Stop();
        GoVfxRotToLeft.transform.localPosition = new Vector3(0f, 50f, 0f);
    }
    private void RotationVFX(Vector3 dir, float time)
    {
        if (Mathf.Abs(dir.x) > tolerance && Mathf.Abs(dir.z) <= tolerance)
        {
            // Mouvement gauche ou droite
            if (Mathf.Sign(dir.x) == -1)
            {
                currentAngleIndex = 1;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3).SetAutoKill(true);
            }
            else if (Mathf.Sign(dir.x) == 1)
            {
                currentAngleIndex = 5;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3).SetAutoKill(true);
            }
        }
        else if (Mathf.Abs(dir.z) > tolerance && Mathf.Abs(dir.x) <= tolerance)
        {
            // Mouvement haut ou bas
            if (Mathf.Sign(dir.z) == 1)
            {
                currentAngleIndex = 3;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3).SetAutoKill(true);
            }
            else if (Mathf.Sign(dir.z) == -1)
            {
                currentAngleIndex = 7;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3).SetAutoKill(true);
            }
        }
        else if (Mathf.Abs(dir.x) > tolerance && Mathf.Abs(dir.z) > tolerance)
        {
            // Mouvement diagonal
            if (Mathf.Sign(dir.x) == -1 && Mathf.Sign(dir.z) == 1)
            {
                currentAngleIndex = 2;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3).SetAutoKill(true);
            }
            else if (Mathf.Sign(dir.x) == 1 && Mathf.Sign(dir.z) == 1)
            {
                currentAngleIndex = 4;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3).SetAutoKill(true);
            }
            else if (Mathf.Sign(dir.x) == -1 && Mathf.Sign(dir.z) == -1)
            {
                currentAngleIndex = 0;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3).SetAutoKill(true);
            }
            else if (Mathf.Sign(dir.x) == 1 && Mathf.Sign(dir.z) == -1)
            {
                currentAngleIndex = 6;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3).SetAutoKill(true);
            }
        }

        if (lastLastMoveDirection != dir && dir != Vector3.zero)
        {
            if(lastLastMoveDirection.z >0)
            {
                float valeur = lastLastMoveDirection.x - dir.x;
                if (valeur > 0)
                {
                    StartCoroutine(RotationToRight(bpmManager.FSPB));
                }
                else if (valeur < 0)
                {
                    StartCoroutine(RotationToLeft(bpmManager.FSPB));
                }
                else
                {
                    int hasard = Hasard(1, 2);
                    if (hasard == 1)
                    {
                        StartCoroutine(RotationToRight(bpmManager.FSPB));
                    }
                    else
                    {
                        StartCoroutine(RotationToLeft(bpmManager.FSPB));
                    }
                }
            }
            else if(lastLastMoveDirection.z < 0)
            {
                float valeur = lastLastMoveDirection.x - dir.x;
                if (valeur > 0)
                {
                    StartCoroutine(RotationToLeft(time));
                }
                else if (valeur < 0)
                {
                    StartCoroutine(RotationToRight(time));
                }
                else
                {
                    int hasard = Hasard(1, 2);
                    if (hasard == 1)
                    {
                        StartCoroutine(RotationToLeft(time));
                    }
                    else
                    {
                        StartCoroutine(RotationToRight(time));
                    }
                }
            }
            else
            {
                float valeur = lastLastMoveDirection.x - dir.x;
                if (valeur > 0)
                {
                    StartCoroutine(RotationToLeft(time));
                }
                else if (valeur < 0)
                {
                    StartCoroutine(RotationToRight(time));
                }
            }
        }
    }

    //CONCERNANT LE RYTHME
    public void RotationEnemies()
    {
        foreach (SC_FieldOfView enemy in allEnemies)
        {
            if (enemy.bIsDisabled)
            {
                if (!bIsImune)
                {
                    enemy.i_EnnemyBeat += 1;
                    if (enemy.i_EnnemyBeat >= 0)
                    {
                        enemy.bIsDisabled = false;
                        enemy.FoeDisabled(enemy.bIsDisabled);
                    }
                }
            }
            else if (enemy.BCanSee)
            {
                enemy.PlayerDetected(this.gameObject, bpmManager.FSPB);
                enemy.i_EnnemyBeat =6;
            }
            else if(enemy.bHasHeard)
            {
                enemy.BaitHeard(GO_BaitInst);
                if (!bIsImune)
                {
                    enemy.i_EnnemyBeat += 1;
                }
            }
            else
            {
                if (!enemy.isBoss)
                {
                    enemy.EnemieRotation(bpmManager.FSPB);
                }
                else if (enemy.isBoss && !enemy.bIsRemovingTag && enemy.iRemovingRoutine!=10)
                {
                    enemy.EnemieRotation(bpmManager.FSPB);
                    if(!bIsImune)
                    {
                        enemy.iRemovingRoutine -= 1;
                        if (enemy.iRemovingRoutine == 0)
                        {
                            enemy.TagChecking();
                        }
                    }
                }
                else if(enemy.isBoss && enemy.bIsRemovingTag)
                {
                    if (!bIsImune)
                    {
                        enemy.iTimeBeforeRemovingThird -= 1;
                        enemy.RemovingTag();
                    }
                }
            }
        }
    }

    //CONCERNANT LA DETECTION
    void EnemieDetection()
    {
        int i = 0;
        int y = 0;
        foreach (SC_FieldOfView enemie in allEnemies)
        {
            if (enemie.BCanSee)
            {
                BisDetectedByAnyEnemy = true;
                bHasBeenDetectedOneTime = true;
                y++;
            }
            else if (enemie.BCanSee == false)
            {
                i++;
            }
            if(i == allEnemies.Length)
            {
                BisDetectedByAnyEnemy = false;
                StartCoroutine(LooseDetectionLevel());
                i = 0;
                y = 0;
            }
            else if(y + i == allEnemies.Length && i != allEnemies.Length)
            {
                i = 0;
                y = 0;
            }
        }
        if(BisDetectedByAnyEnemy)
        {
            GoVfxDetected.transform.localPosition = fPosVFX_detected;
        }
        else
        {
            GoVfxDetected.transform.localPosition = fPosVFX_detected + new Vector3(0f,50f,0f);
        }
    }
    IEnumerator LooseDetectionLevel()
    {
        yield return new WaitForSeconds(FTimeWithoutLooseDetection);
    }
    public void EyeDetection()
    {
        if(FDetectionLevel <= fDetectionLevelMax *1/5)
        {
            imgEye.material = mEye[0];
        }
        else if(FDetectionLevel <= fDetectionLevelMax * 2/ 5)
        {
            imgEye.material = mEye[1];
        }
        else if (FDetectionLevel <= fDetectionLevelMax * 3/ 5)
        {
            imgEye.material = mEye[2];
        }
        else if (FDetectionLevel <= fDetectionLevelMax * 4 / 5)
        {
            imgEye.material = mEye[3];
        }
        else if (FDetectionLevel <= fDetectionLevelMax)
        {
            imgEye.material = mEye[4];
        }
    }

    //LA FIN DU NIVEAU
    public void EndDialogue()
    {
        Time.timeScale = 0f;
        menuManager.bGameIsPaused = true;
        menuManager.PauseGame();

        menuManager.CgEndDialogue.alpha = 1f;
        menuManager.RtEndDialogue.anchorMin = new Vector2(0, 0);
        menuManager.RtEndDialogue.anchorMax = new Vector2(1, 1);
        menuManager.RtEndDialogue.offsetMax = new Vector2(0f, 0f);
        menuManager.RtEndDialogue.offsetMin = new Vector2(0f, 0f);

        menuManager.BeginDialogue(true);
    }
    public void EndGame(bool hasWon, PlayerData data)
    {
        Time.timeScale = 0f;
        menuManager.bGameIsPaused = true;
        menuManager.PauseGame();
        //PlayerData data = menuManager.gameObject.GetComponent<PlayerData>();

        menuManager.CgScoring.alpha = 1f;
        menuManager.CgScoring.interactable = true;
        menuManager.RtScoring.anchorMin = new Vector2(0, 0);
        menuManager.RtScoring.anchorMax = new Vector2(1, 1);
        menuManager.RtScoring.offsetMax = new Vector2(0f, 0f);
        menuManager.RtScoring.offsetMin = new Vector2(0f, 0f);

        if (hasWon && fPercentScore >= 35)
        {
            //LE SCORING
            menuManager.txtScoringJudgment.text = sJugement(hasWon)[0];
            menuManager.txtScoringScore.text = sJugement(hasWon)[1];
            //LES EXPLOITS
            List<int> ints = iStars();
            UnityEngine.UI.Image[] imgStars = new UnityEngine.UI.Image[ints.Count];
            TMP_Text[] texts = new TMP_Text[ints.Count];
            for (int i =0; i<ints.Count; i++)
            {
                imgStars[i] = menuManager.GoScoringSuccess.transform.GetChild(i).gameObject.transform.GetChild(0).gameObject.GetComponent<UnityEngine.UI.Image>();
                texts[i] = menuManager.GoScoringSuccess.transform.GetChild(i).gameObject.transform.GetChild(1).gameObject.GetComponent<TMP_Text>();
                if (ints[i] == 1) //vrai
                {
                    imgStars[i].color = new Color32(255, 0, 255, 255);
                    texts[i].color = new Color32(255, 255, 255, 255);
                }
                else //Faux
                {
                    imgStars[i].color = new Color32(0, 255, 0, 255);
                    if(i != ints.Count-1)
                    {
                        texts[i].color = new Color32(157, 157, 157, 255);
                    }
                    else
                    {
                        texts[i].color = new Color32(0, 0, 0, 255);
                    }
                }
            }
            PlayerDataUpdate(data);
            //BUTTONS
            UnityEngine.UI.Button[] buttonScorring = new UnityEngine.UI.Button[2];
            TextMeshProUGUI[] txt = new TextMeshProUGUI[2];
            for (int i =0; i<2; i++)
            {
                buttonScorring[i] = menuManager.GoScoringButtons.transform.GetChild(i).GetComponent<UnityEngine.UI.Button>();
                txt[i] = menuManager.GoScoringButtons.transform.GetChild(i).transform.GetChild(0).GetComponent<TextMeshProUGUI>();
            }
            buttonScorring[0].onClick.AddListener(delegate { menuManager.LoadScene("Scenes/World/LevelChoosing"); });
            buttonScorring[1].onClick.AddListener(delegate { menuManager.LoadScene("retry"); });
            if (data.iLanguageNbPlayer == 1)
            {
                txt[0].text = "Continuer";
                txt[1].text = "R�essayer";
            }
            else
            {
                txt[0].text = "Next";
                txt[1].text = "Retry";
            }
            //APPARITION
            menuManager.CgScoringSuccess.alpha = 1f;
            menuManager.RtScoringSuccess.anchorMin = new Vector2(0, 0);
            menuManager.RtScoringSuccess.anchorMax = new Vector2(1, 1);
            menuManager.RtScoringSuccess.offsetMax = new Vector2(0f, 0f);
            menuManager.RtScoringSuccess.offsetMin = new Vector2(0f, 0f);

            menuManager.RtScoringButtons.anchorMin = new Vector2(0.75f, 0.05f);
            menuManager.RtScoringButtons.anchorMax = new Vector2(0.9f, 0.3f);
            menuManager.ImgScoringBackground.sprite = menuManager.spritesScoringBackground[0];
        }
        else
        {
            //LE SCORING
            menuManager.txtScoringJudgment.text = sJugement(hasWon)[0];
            menuManager.txtScoringScore.text = sJugement(hasWon)[1];
            //BUTTONS
            UnityEngine.UI.Button[] buttonScorring = new UnityEngine.UI.Button[2];
            TextMeshProUGUI[] txt = new TextMeshProUGUI[2];
            for (int i = 0; i < 2; i++)
            {
                buttonScorring[i] = menuManager.GoScoringButtons.transform.GetChild(i).GetComponent<UnityEngine.UI.Button>();
                txt[i] = menuManager.GoScoringButtons.transform.GetChild(i).transform.GetChild(0).GetComponent<TextMeshProUGUI>();
            }
            buttonScorring[0].onClick.AddListener(delegate { CheckPoint(true, iCheckPoint); });
            buttonScorring[1].onClick.AddListener(delegate { menuManager.LoadScene("Scenes/World/LevelChoosing"); });
            if (data.iLanguageNbPlayer == 1)
            {
                txt[0].text = "R�essayer";
                txt[1].text = "Revoir la carte";
            }
            else
            {
                txt[0].text = "Retry";
                txt[1].text = "See Map";
            }
            //APPARITION
            menuManager.CgScoringSuccess.alpha = 0f;
            menuManager.RtScoringSuccess.anchorMin = new Vector2(0, 1);
            menuManager.RtScoringSuccess.anchorMax = new Vector2(1, 2);
            menuManager.RtScoringSuccess.offsetMax = new Vector2(0f, 0f);
            menuManager.RtScoringSuccess.offsetMin = new Vector2(0f, 0f);

            menuManager.RtScoringButtons.anchorMin = new Vector2(0.75f, 0.35f);
            menuManager.RtScoringButtons.anchorMax = new Vector2(0.9f, 0.6f);
            menuManager.ImgScoringBackground.sprite = menuManager.spritesScoringBackground[1];
        }
        if (menuManager.controllerConnected) //Si controller
        {
            UnityEngine.Cursor.lockState = CursorLockMode.Locked;
        }
        else //sinon keyboard
        {
            UnityEngine.Cursor.lockState = CursorLockMode.None;
        }
        menuManager.EventSystem.firstSelectedGameObject = menuManager.GoScoringFirstButtonSelected;
        menuManager.GoScoringFirstButtonSelected.GetComponent<UnityEngine.UI.Button>().Select();
        bIsEndGame = true;
    }
    public void CheckPoint(bool isRetrying, int iPreviousCheckPoint)
    {
        if(isRetrying) //has to regain all stats from the previous checkpoint
        {
            bIsReplaying = true;
            bIsEndGame = false;

            this.gameObject.transform.position = posLastCheckPoint;

            ReStartThings(iPreviousCheckPoint);

            menuManager.CgScoring.alpha = 0f;
            menuManager.CgScoring.interactable = false;
            menuManager.RtScoring.anchorMin = new Vector2(0, 1);
            menuManager.RtScoring.anchorMax = new Vector2(1, 2);
            menuManager.RtScoring.offsetMax = new Vector2(0f, 0f);
            menuManager.RtScoring.offsetMin = new Vector2(0f, 0f);

            menuManager.CgLoadingScreen.alpha = 1f;
            menuManager.RtLoadingScreen.anchorMin = new Vector2(0, 0);
            menuManager.RtLoadingScreen.anchorMax = new Vector2(1, 1);
            menuManager.RtLoadingScreen.offsetMax = new Vector2(0f, 0f);
            menuManager.RtLoadingScreen.offsetMin = new Vector2(0f, 0f);

            Time.timeScale = 1f;
            menuManager.bGameIsPaused = false;
            menuManager.PauseGame();
            bIsImune = true;
        }
        else //has to remember all stats from this checkpoint
        {
            posLastCheckPoint = new Vector3(this.gameObject.transform.position.x, posYInit, this.gameObject.transform.position.z);
            iTagPreviouslyDone = itagDone;
            FPreviousScore = FScore;
            fPreviousNbBeat = fNbBeat;
            iCheckPoint = iPreviousCheckPoint;
        }
    }
    private void ReStartThings(int iPreviousCheckPoint)
    {
        //RESTART TAGS
        if (iPreviousCheckPoint == 0)
        {
            itagDone = 0;
            FScore = 0;
            fNbBeat = 0;
            foreach (ing_Tag tag in allTagsUntil1stCheckPoint)
            {
                tag.textOnWall.text = "0/3";
                tag.transform.gameObject.tag = "Tagging";
                tag._renderer.material = tag.untaggedMaterial; //pas de tag
            }
        }
        else
        {
            itagDone = iTagPreviouslyDone;
            FScore = FPreviousScore;
            fNbBeat = fPreviousNbBeat;
            foreach (ing_Tag tag in checkpoints[iCheckPoint-1].tags)
            {
                tag.textOnWall.text = "0/3";
                tag.transform.gameObject.tag = "Tagging";
                tag._renderer.material = tag.untaggedMaterial; //pas de tag
            }
        }

        //RESTART ENNEMIES
        foreach (SC_FieldOfView foe in allEnemies)
        {
            foe.BCanSee = false;
            foe.bSeenOnce = false;
            foe.bHasHeard = false;
            foe.bIsDisabled = false;
            foe.BIsNear = false;
            foe.ResetAllVFX();
        }
        FDetectionLevel = 0f;
        BisDetectedByAnyEnemy = false;

        //RESTART FEEDBACKS ENNEMIES

    }
    private List<int> iStars()
    {
        List<int> List = new List<int>();
        //SHADOW
        if (!bHasBeenDetectedOneTime)
        {
            List.Add(1);
        }
        else
        {
            List.Add(0);
        }
        //CLEAN
        if (bHasNoMiss) 
        {
            List.Add(1);
        }
        else
        {
            List.Add(0);
        }
        //TRUE ARTISTE
        int i = Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value);
        if (itagDone == menuManager.iNbTaggs[i]) 
        {
            List.Add(1);
        }
        else
        {
            List.Add(0);
        }
        //BOOGIE WOOGIE
        if (fPercentScore >= 95) 
        {
            List.Add(1);
        }
        else
        {
            List.Add(0);
        }
        //LE SECRET
        List.Add(0); 
        return List;
    }
    private List<string> sJugement(bool finished)
    {
        if (fPercentScore >= 95 && finished)
        {
            List<string> List = new List<string> { "S+", Mathf.Round(fPercentScore).ToString() + "%" };
            return List;
        }
        else if (fPercentScore >= 80 && finished)
        {
            List<string> List = new List<string> { "S", Mathf.Round(fPercentScore).ToString() + "%" };
            return List;
        }
        else if (fPercentScore >= 65 && finished)
        {
            List<string> List = new List<string> { "A", Mathf.Round(fPercentScore).ToString() + "%" };
            return List;
        }
        else if (fPercentScore >= 50 && finished)
        {
            List<string> List = new List<string>{"B", Mathf.Round(fPercentScore).ToString() + "%" };
            return List;
        }
        else if (fPercentScore >= 35 && finished)
        {
            List<string> List = new List<string> { "C", Mathf.Round(fPercentScore).ToString() + "%" };
            return List;
        }
        else if (!finished)
        {
            List<string> List = new List<string> { "Busted", Mathf.Round(fPercentScore).ToString() + "%" };
            return List;
        }
        else
        {
            List<string> List = new List<string> { "F", Mathf.Round(fPercentScore).ToString() + "%" };
            return List;
        }
    }
    private void PlayerDataUpdate(PlayerData data)
    {
        int i = Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value);
        Debug.Log("le niveau est le " + i);
        if (fPercentScore > data.iScorePerLvlPlayer[i])
        {
            data.iScorePerLvlPlayer[i] = Convert.ToInt32(fPercentScore);
        }
        if (!bHasBeenDetectedOneTime)
        {
            data.iStarsPlayer[0 + 5 * i] = 1;
        }
        if(bHasNoMiss)
        {
            data.iStarsPlayer[1 + 5 * i] = 1;
        }
        if (itagDone == menuManager.iNbTaggs[i])
        {
            data.iStarsPlayer[2 + 5 * i] = 1;
        }
        if(fPercentScore >= 95)
        {
            data.iStarsPlayer[3 + 5 * i] = 1;
        }
        if ("SceneLvl" + data.iLevelPlayer.ToString() == SceneManager.GetActiveScene().name)
        {
            data.iLevelPlayer += 1;
        }
        data.SaveGame();
    }
    private void CheckControllerStatus()
    {
        string[] controllers = Input.GetJoystickNames();

        // Check if at least one controller is connected
        bool isConnected = false;
        foreach (string controller in controllers)
        {
            if (!string.IsNullOrEmpty(controller)) // Check for valid controller name
            {
                isConnected = true;
                break;
            }
        }
        // Detect changes in connection status
        if (isConnected != bHasController)
        {
            bHasController = isConnected;

            if (bHasController)
            {
                Debug.Log("Controller connected!");
            }
            else
            {
                Debug.Log("No controllers connected!");
            }
        }
    }
    private void OnDestroy() // Clean up to prevent memory leaks
    {
        DOTween.KillAll();
    }
}
