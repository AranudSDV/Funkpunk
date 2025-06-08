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
using UnityEngine.SceneManagement;
using static UnityEngine.EventSystems.EventTrigger;
using Cinemachine;
using UnityEngine.Rendering.PostProcessing;
using FMODUnity;
using System.Text.RegularExpressions;
using DG.Tweening;
using UnityEditor;
using UnityEngine.EventSystems;
using Unity.Splines.Examples;
using UnityEngine.ProBuilder.Shapes;
using UnityEngine.UIElements;
using UnityEngine.VFX;
//using UnityEditor.PackageManager;

public class SC_Player : Singleton<SC_Player>
{
    public EventSystem _eventSystem;
    public Camera camUIOverlay;
    public bool bisTuto = false;
    public MenuManager menuManager;
    public bool bHasController = true;
    public BPM_Manager bpmManager;
    public sc_tuto_generic tutoGen = null;
    [SerializeField] private CanvasGroup CgInGame;
    public GameObject GoCanvasArrow;

    //LES CHALLENGES
    private bool bHasBeenDetectedOneTime = false;
    public bool bHasNoMiss = true;
    private int itagDone = 0;

    //LE PLAYER ET SES MOUVEMENTS
    [Header("Player and movement")]
    [SerializeField] private Transform inputDirIndicator;
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
    private bool bEnsureRotation = false;

    //LE BAIT
    [Header("Bait")]
    [SerializeField] private GameObject GOBait;
    [SerializeField] private CinemachineVirtualCamera cinemachineVirtualCamera;
    private CinemachineBasicMultiChannelPerlin cinemachineBasicMultiChannelPerlin;
    private GameObject GO_BaitInst;
    public bool hasAlreadyBaited = false;
    private float fThrowMultiplier = 1f;
    private float fShakeFoeBasic = 9f;
    [SerializeField] private EventReference sfx_baitStun;
    [SerializeField] private EventReference sfx_baitThrown;
    [SerializeField] private EventReference[] sfx_tag = new EventReference[3];
    [SerializeField] private EventReference sfx_wall_hit;

    //LE SCORE
    [Header("Score")]
    public float FScore;
    [Tooltip("Missed, Bad, Good, Perfect")] public float[] fScoreDetails = new float[4] { 0f,0f,0f,0f};
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
    private bool bIsTagging = false;
    [SerializeField] private CinemachineVirtualCamera VCam_Cinematic;
    [SerializeField] private float fBodyFollowOffset = 10f;
    public float taggingRange = 1f;
    private RaycastHit[] hitInfo = new RaycastHit[4];
    [SerializeField] private GameObject GoVfxTag;
    [SerializeField] private ParticleSystem vfx_tag;
    [SerializeField] private LayerMask LMask;
    private Vector3[] points;
    private int iBossDoorTag = 0;

    //CHECKPOINTS STATS
    [Header("Checkpoints Stats")]
    [SerializeField] private ing_Bait[] ingBaitLvl2 = null;
    [SerializeField] private sc_CheckPoint[] checkpoints;
    [SerializeField] private ing_Tag[] allTagsUntil1stCheckPoint;
    [SerializeField] private Vector3 posLastCheckPoint;
    [SerializeField] private float posYInit;
    private int iTagPreviouslyDone = 0;
    private float FPreviousScore = 0f;
    private float fPreviousNbBeat = 0f;
    private float[] fPreviousNbBeatScoring = new float[4] { 0f, 0f, 0f, 0f};
    public int iCheckPoint = 0;
    public bool bIsReplaying = false;

    [SerializeField] private GameObject go_Grid;

    [SerializeField, Button(nameof(testy))] bool test;

    [ContextMenu("lols")]
    private void testy()
    {
        Debug.Log("lol ça marche !");
    }

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
        if (MenuManager.instance == null)
        {
            Debug.LogWarning("MenuManager.instance was null. Delaying initialization.");
            StartCoroutine(WaitForMenuManager());
            return;
        }
        InitWithMenuManager(MenuManager.instance);
    }
    private IEnumerator WaitForMenuManager()
    {
        yield return new WaitUntil(() => MenuManager.instance != null);
        InitWithMenuManager(MenuManager.instance);
    }

    private void InitWithMenuManager(MenuManager menu)
    {
        GameObject goMenu = menu.gameObject;
        FScore = Mathf.Round(fPercentScore);
        bIsEndGame = false;
        posMesh = PlayerCapsule.transform.position;
        CheckControllerStatus();
        cinemachineBasicMultiChannelPerlin = cinemachineVirtualCamera.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();
        if (menuManager == null)
        {
            goMenu = MenuManager.instance.gameObject;
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
        menuManager.gameObject.GetComponent<Canvas>().worldCamera = camUIOverlay;
        menuManager.EventSystem = _eventSystem;
        Debug.Log("event system done");
        EyeDetection();
        // Your logic here
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
        if(menuManager!=null && !menuManager.bGameIsPaused)
        {
            CgInGame.alpha = 1f;
            if (fNbBeat > 0 && FScore > 0)
            {
                fPercentScore = FScore / fNbBeat;
            }
            else
            {
                fPercentScore = 0;
            }
            if (SceneManager.GetActiveScene().name == "Loft" && fNbBeat >= 10f)
            {
                FScore = Mathf.Round(fPercentScore);
                fNbBeat = 1;
            }
            TMPScore.SetText(Mathf.Round(fPercentScore).ToString() + "%");
            if (FDetectionLevel >= fDetectionLevelMax && !bIsEndGame)
            {
                StartCoroutine(EndGame(false, menuManager._playerData));
            }
            if (FDetectionLevel < 0)
            {
                FDetectionLevel = 0;
                EyeDetection();
            }
            if (bcanRotate == true)
            {
                UpdateDirAndMovOnJoystickOrPC();
                bEnsureRotation = false;
            }
            else
            {
                EnsureRotation();
            }
            EnemieDetection();
        }
        else if(menuManager != null && menuManager.bGameIsPaused && !bisTuto)
        {
            bIsImune = true;
            CgInGame.alpha = 0f;
        }
        if(menuManager!=null)
        {
            if(menuManager.bOnceGrid == false && go_Grid!=null)
            {
                if(menuManager._playerData.iGrid == 1)//true
                {
                    go_Grid.SetActive(true);
                }
                else
                {
                    go_Grid.SetActive(false);
                }
                menuManager.bOnceGrid = true;
            }
        }
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
            if (direction != Vector3.zero)
            {
                lastMoveDirection = direction;
            }
        }
    }
    private Vector3 GetDirectionFromJoystick(Vector2 moveInput)
    {
        Transform tr = Camera.main.transform;
        Vector3 forward = tr.forward;
        forward = Vector3.ProjectOnPlane(forward, Vector3.up);
        forward.Normalize();

        Vector3 right = tr.right;
        right = Vector3.ProjectOnPlane(right, Vector3.up);
        right.Normalize();

        Vector3 directionAligned = moveInput.x * right + moveInput.y * forward;
        moveInput = new Vector2(directionAligned.x, directionAligned.z).normalized;
        Vector3 direction = Vector3.zero;

        float angle = -Vector2.SignedAngle(Vector2.up, moveInput);
        if (angle < 0)
            angle += 360f;

        if (angle < 22.5f)
            direction = Vector3.forward; // Up
        else if (angle < 67.5f)
            direction = (Vector3.forward + Vector3.right).normalized; // Up-Right
        else if (angle < 112.5f)
            direction = Vector3.right; // Right
        else if (angle < 157.5f)
            direction = (Vector3.back + Vector3.right).normalized; // Down-Right
        else if (angle < 202.5f)
            direction = Vector3.back; // Down
        else if (angle < 247.5f)
            direction = (Vector3.back + Vector3.left).normalized; // Down-Left
        else if (angle < 292.5f)
            direction = Vector3.left; // Left
        else if (angle < 337.5f)
            direction = (Vector3.forward + Vector3.left).normalized; // Up-Left
        else
            direction = Vector3.forward; // Up (wraparound)

        inputDirIndicator.forward = directionAligned;

        return direction;
    }

    //CONCERNANT LE BAIT
    public void ShootBait(ing_Bait bait)
    {
        fThrowMultiplier = CheckForwardBait(lastMoveDirection);
        GO_BaitInst = bait.transform.gameObject;
        Debug.Log(fThrowMultiplier);
        Vector3 _spawnpos = new Vector3(this.transform.position.x, this.transform.position.y - 0.5f, this.transform.position.z) + (lastMoveDirection * fThrowMultiplier);
        bait.newPos = _spawnpos;
        bait.midPos = new Vector3(this.transform.position.x, this.transform.position.y + 2.5f, this.transform.position.z) + (lastMoveDirection * fThrowMultiplier / 2);
        bait.bIsBeingThrown = true;
        StartCoroutine(CameraShake(fThrowMultiplier * 1 / 3, bpmManager.FSPB * 1 / 4));
    }

    //VERIFIER LE MOUVEMENT
    public void CheckForward(Vector3 vectDir)
    {
        // 1. Check for diagonal movement first
        if (vectDir.x != 0f && vectDir.z != 0f) // Diagonal movement
        {
            Vector3 diagonalCheckPosition = new Vector3(transform.position.x, transform.position.y-0.5f, transform.position.z) + (vectDir * 1.5f);
            // Use OverlapSphere to check for colliders at the diagonal position
            Collider[] intersecting = Physics.OverlapSphere(diagonalCheckPosition, 0.35f, LMask); 
            bool canMoveDiagonally = false;

            if (intersecting.Length > 0)
            {
                // Loop through colliders to check tags
                foreach (Collider collider in intersecting)
                {
                    if(collider.CompareTag("Tagging"))
                    {
                        bIsBeingAnimated = true;
                        ing_Tag ingTag = collider.transform.gameObject.GetComponent<ing_Tag>();
                        for (int i = 0; i < 4; i++)
                        {
                            if (bpmManager.bPlayBad)
                            {
                                if (ingTag.iCompletition == 0)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 1, 0.66f);
                                }
                                else if (ingTag.iCompletition == 1)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.66f, 0.33f);
                                }
                                if (ingTag.iCompletition == 2)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.33f, 0f);
                                }
                                ingTag.iCompletition += 1;
                                //PlayCinematicFocus(collider.transform.gameObject, vectDir, bpmManager.FSPB, i+1);
                                TaggingFeedback(bpmManager.FSPB, vectDir);
                                StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                break;
                            }
                            else if (bpmManager.bPlayGood)
                            {
                                if (ingTag.iCompletition == i)
                                {
                                    if (ingTag.iCompletition == 0)
                                    {
                                        GraffitiRenderer(ingTag.decalProj.material, 1, 0.33f);
                                    }
                                    else if (ingTag.iCompletition == 1)
                                    {
                                        GraffitiRenderer(ingTag.decalProj.material, 0.66f, 0f);
                                    }
                                    if (ingTag.iCompletition == 2)
                                    {
                                        GraffitiRenderer(ingTag.decalProj.material, 0.33f, 0f);
                                    }
                                    if (i < 2)
                                    {
                                        ingTag.iCompletition += 2;
                                        //PlayCinematicFocus(collider.transform.gameObject, vectDir, bpmManager.FSPB, i + 1);
                                        TaggingFeedback(bpmManager.FSPB, vectDir);
                                        StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                    }
                                    else
                                    {
                                        ingTag.iCompletition = 3;
                                        //PlayCinematicFocus(collider.transform.gameObject, vectDir, bpmManager.FSPB, i + 1);
                                        TaggingFeedback(bpmManager.FSPB, vectDir);
                                        StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                    }
                                    break;
                                }
                            }
                            else if (bpmManager.bPlayPerfect)
                            {
                                if (ingTag.iCompletition == 0)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 1, 0f);
                                }
                                else if (ingTag.iCompletition == 1)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.66f, 0f);
                                }
                                if (ingTag.iCompletition == 2)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.33f, 0f);
                                }
                                ingTag.iCompletition = 3;
                                //PlayCinematicFocus(collider.transform.gameObject, vectDir, bpmManager.FSPB, i + 1);
                                TaggingFeedback(bpmManager.FSPB, vectDir);
                                StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                break;
                            }
                            else if (!bpmManager.bPlayPerfect && !bpmManager.bPlayGood && !bpmManager.bPlayBad)
                            {
                                Move(Vector3.zero, 0.3f);
                                break;
                            }
                        }
                        if (ingTag.iCompletition == 1)
                        {
                            SoundManager.Instance.PlayOneShot(sfx_tag[0]);
                        }
                        else if (ingTag.iCompletition == 2)
                        {
                            SoundManager.Instance.PlayOneShot(sfx_tag[1]);
                        }
                        else if (ingTag.iCompletition == 3)
                        {
                            foreach(VisualEffect vfx in ingTag.PS_Sound)
                            {
                                vfx.Stop();
                            }
                            ingTag.PlayVFXSoundWave();
                            SoundManager.Instance.PlayOneShot(sfx_tag[2]);
                            ingTag.vfx_completition.Play();
                            //ingTag._renderer.material = ingTag.taggedMaterial; 
                            ingTag.transform.gameObject.tag = "Wall";
                            ingTag.goArrow.transform.localPosition = new Vector3(ingTag.goArrow.transform.localPosition.x, ingTag.goArrow.transform.localPosition.y - 50f, ingTag.goArrow.transform.localPosition.z);
                            itagDone += 1;
                            if (ingTag.scFoes != null)
                            {
                                foreach (SC_FieldOfView foe in ingTag.scFoes)
                                {
                                    foe.bIsDisabled = true;
                                    foe.FoeDisabled(foe.bIsDisabled);
                                    StartCoroutine(foe.FoeStunOnceVFX());
                                    foe.i_EnnemyBeat = -iTimeFoeDisabled * 10;
                                }
                                CameraShake(fShakeFoeBasic, bpmManager.FSPB * 1 / 3);
                            }
                            if (ingTag.transform.gameObject.name == "EndingWall")
                            {
                                StartCoroutine(EndGame(true, menuManager._playerData));
                            }
                            if (ingTag.bBossTag)
                            {
                                if(!ingTag.scBoss.bFinalPhase)
                                {
                                    ingTag.scBoss.iNbTaggsDonePhase1 += 1;
                                    ingTag.scBoss.BossTagAnglePhase1();
                                }
                                else
                                {
                                    ingTag.scBoss.iNbTaggsDonePhase2 += 1;
                                    ingTag.scBoss.BossTagAnglePhase2();
                                }
                                //feedback degat boss
                                CameraShake(fShakeFoeBasic * 2, bpmManager.FSPB * 1 / 3);
                            }
                            if(ingTag.bBossDoorTag)
                            {
                                iBossDoorTag += 1;
                                ingTag.textOnWallBossDoor.text = (iBossDoorTag).ToString() + "/2";
                                if (iBossDoorTag == 2)
                                {
                                    BossDoor(ingTag.boxColliderBoss, ingTag.goBossDoor, ingTag.camBossDoor);
                                    //Porte ouverte
                                }
                            }
                            break;
                        }
                    }
                    else if (collider.CompareTag("Wall") || collider.CompareTag("Enemies 1"))
                    {
                        // Wall detected, find a new direction
                        SoundManager.Instance.PlayOneShot(sfx_wall_hit);
                        Move(Vector3.zero, 1f);
                    }
                    else if (collider.CompareTag("Bait") || (collider.CompareTag("Untagged") && collider.gameObject.name == "BossDoor"))
                    {
                        canMoveDiagonally = true;
                        if(collider.CompareTag("Bait"))
                        {
                            Debug.Log("bait ok");
                        }
                    }
                    else if (collider.transform.CompareTag("MapObject"))
                    {
                        if (collider.gameObject.name == "World")
                        {
                            menuManager.LoadScene("Scenes/World/SceneSplash");
                        }
                        else
                        {
                            menuManager.LoadScene("Scenes/World/LevelChoosing");
                        }
                    }
                }
            }
            else if(intersecting.Length == 0)
            {
                canMoveDiagonally = true;
            }
            if (canMoveDiagonally && !bIsTagging)
            {
                // Move diagonally if no blocking objects or only passable ones
                Move(vectDir, 1f);
            }
            else if(!bIsTagging)
            {
                Move(Vector3.zero, 1f);
            }
        }
        // Check for walls in the current direction
        else
        {
            Vector3 CheckPosition = new Vector3(transform.position.x, transform.position.y - 0.5f, transform.position.z) + vectDir;
            // Use OverlapSphere to check for colliders at the diagonal position
            Collider[] intersecting = Physics.OverlapSphere(CheckPosition, 0.35f, LMask);
            bool canMoveFront = false;
            if (intersecting.Length > 0)
            {
                foreach (Collider collider in intersecting)
                {
                    if (collider.CompareTag("Tagging")) //c'est un mur à tagger
                    {
                        bIsBeingAnimated = true;
                        ing_Tag ingTag = collider.gameObject.GetComponent<ing_Tag>();
                        for (int i = 0; i < 4; i++)
                        {
                            if (bpmManager.bPlayBad)
                            {
                                if (ingTag.iCompletition == 0)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 1, 0.66f);
                                }
                                else if (ingTag.iCompletition == 1)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.66f, 0.33f);
                                }
                                if (ingTag.iCompletition == 2)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.33f, 0f);
                                }
                                ingTag.iCompletition += 1;
                                //PlayCinematicFocus(hitInfo.transform.gameObject, vectDir, bpmManager.FSPB, i + 1);
                                TaggingFeedback(bpmManager.FSPB, vectDir);
                                StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                break;
                            }
                            else if (bpmManager.bPlayGood)
                            {
                                if (ingTag.iCompletition == 0)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 1, 0.33f);
                                }
                                else if (ingTag.iCompletition == 1)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.66f, 0f);
                                }
                                if (ingTag.iCompletition == 2)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.33f, 0f);
                                }
                                if (ingTag.iCompletition == i)
                                {
                                    if (i < 2)
                                    {
                                        ingTag.iCompletition += 2;
                                        //PlayCinematicFocus(hitInfo.transform.gameObject, vectDir, bpmManager.FSPB, i + 1);
                                        TaggingFeedback(bpmManager.FSPB, vectDir);
                                        StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                    }
                                    else
                                    {
                                        ingTag.iCompletition = 3;
                                        //PlayCinematicFocus(hitInfo.transform.gameObject, vectDir, bpmManager.FSPB, i + 1);
                                        TaggingFeedback(bpmManager.FSPB, vectDir);
                                        StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                    }
                                    break;
                                }
                            }
                            else if (bpmManager.bPlayPerfect)
                            {
                                if (ingTag.iCompletition == 0)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 1, 0f);
                                }
                                else if (ingTag.iCompletition == 1)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.66f, 0f);
                                }
                                if (ingTag.iCompletition == 2)
                                {
                                    GraffitiRenderer(ingTag.decalProj.material, 0.33f, 0f);
                                }
                                ingTag.iCompletition = 3;
                                //PlayCinematicFocus(hitInfo.transform.gameObject, vectDir, bpmManager.FSPB, i + 1);
                                TaggingFeedback(bpmManager.FSPB, vectDir);
                                StartCoroutine(TagFeedback(vectDir, bpmManager.FSPB));
                                break;
                            }
                            else if (!bpmManager.bPlayPerfect && !bpmManager.bPlayGood && !bpmManager.bPlayBad)
                            {
                                Move(Vector3.zero, 0.3f);
                                break;
                            }
                        }
                        if (ingTag.iCompletition == 1)
                        {
                            SoundManager.Instance.PlayOneShot(sfx_tag[0]);
                        }
                        else if (ingTag.iCompletition == 2)
                        {
                            SoundManager.Instance.PlayOneShot(sfx_tag[1]);
                        }
                        else if (ingTag.iCompletition == 3)
                        {
                            foreach (VisualEffect vfx in ingTag.PS_Sound)
                            {
                                vfx.Stop();
                            }
                            ingTag.PlayVFXSoundWave();
                            SoundManager.Instance.PlayOneShot(sfx_tag[2]);
                            ingTag.vfx_completition.Play();
                            //ingTag._renderer.material = ingTag.taggedMaterial; //le joueur tag
                            ingTag.transform.gameObject.tag = "Wall";
                            ingTag.goArrow.transform.localPosition = new Vector3(ingTag.goArrow.transform.localPosition.x, ingTag.goArrow.transform.localPosition.y - 50f, ingTag.goArrow.transform.localPosition.z);
                            itagDone += 1;
                            if (ingTag.scFoes != null)
                            {
                                foreach (SC_FieldOfView foe in ingTag.scFoes)
                                {
                                    foe.bIsDisabled = true;
                                    foe.FoeDisabled(foe.bIsDisabled);
                                    StartCoroutine(foe.FoeStunOnceVFX());
                                    foe.i_EnnemyBeat = -iTimeFoeDisabled * 10;
                                }
                                StartCoroutine(CameraShake(fShakeFoeBasic, bpmManager.FSPB * 1 / 3));
                            }
                            if (ingTag.transform.gameObject.name == "EndingWall")
                            {
                                StartCoroutine(EndGame(true, menuManager._playerData));
                            }
                            if (ingTag.bBossTag)
                            {
                                if (!ingTag.scBoss.bFinalPhase)
                                {
                                    ingTag.scBoss.iNbTaggsDonePhase1 += 1;
                                    ingTag.scBoss.BossTagAnglePhase1();
                                }
                                else
                                {
                                    ingTag.scBoss.iNbTaggsDonePhase2 += 1;
                                    ingTag.scBoss.BossTagAnglePhase2();
                                }
                                //feedback degat boss
                                StartCoroutine(CameraShake(fShakeFoeBasic * 2, bpmManager.FSPB * 1 / 3));
                            }
                            if (ingTag.bBossDoorTag)
                            {
                                iBossDoorTag += 1;
                                ingTag.textOnWallBossDoor.text = (iBossDoorTag).ToString() + "/2";
                                if (iBossDoorTag == 2)
                                {
                                    BossDoor(ingTag.boxColliderBoss, ingTag.goBossDoor, ingTag.camBossDoor);
                                    //Porte ouverte
                                }
                            }
                            break;
                        }
                    }
                    else if (collider.CompareTag("Wall") || collider.CompareTag("Enemies 1"))
                    {
                        // Wall detected, find a new direction
                        SoundManager.Instance.PlayOneShot(sfx_wall_hit);
                        Move(Vector3.zero, 1f);
                    }
                    else if (collider.CompareTag("MapObject"))
                    {
                        if (collider.gameObject.name == "World")
                        {
                            menuManager.LoadScene("Scenes/World/SceneSplash");
                        }
                        else
                        {
                            menuManager.LoadScene("Scenes/World/LevelChoosing");
                        }
                    }
                    else if(collider.CompareTag("Bait") || (collider.CompareTag("Untagged") && collider.gameObject.name == "BossDoor"))
                    {
                        canMoveFront = true;
                    }
                }
            }
            else if (intersecting.Length == 0)
            {
                canMoveFront = true;
            }
            if (canMoveFront && !bIsTagging)
            {
                // Move diagonally if no blocking objects or only passable ones
                Move(vectDir, 1f);
            }
            else if (!bIsTagging)
            {
                Move(Vector3.zero, 1f);
            }
        }
        bIsBeingAnimated = false;
    }
    private float CheckForwardBait(Vector3 vectDir)
    {
        for (int i = 1; i < 10; i++)
        {
            float floatNumber = Convert.ToSingle(i);
            // 1. Check for diagonal movement first
            if (vectDir.x != 0f && vectDir.z != 0f) // Diagonal movement
            {
                Debug.Log("diagonal");
                Vector3 diagonalCheckPosition = transform.position + (vectDir * 1.5f) * floatNumber;
                // Use OverlapSphere to check for colliders at the diagonal position
                Collider[] intersecting = Physics.OverlapSphere(diagonalCheckPosition, 0.4f, LMask);
                if (intersecting.Length > 0 && i <= 9)
                {
                    foreach (Collider col in intersecting)
                    {
                        if (col.transform.CompareTag("Wall") || col.transform.CompareTag("Tagging") || col.transform.CompareTag("Bait"))
                        {
                            bIsBeingAnimated = true;
                            fThrowMultiplier = floatNumber - 1f;
                            ThrowingFeedback(bpmManager.FSPB, false, null);
                        }
                        else if (col.transform.CompareTag("Enemies 1")) //il y a un ennemi devant le joueur
                        {
                            bIsBeingAnimated = true;
                            fThrowMultiplier = floatNumber - 1f;
                            SC_FieldOfView scEnemy = col.transform.gameObject.GetComponent<SC_FieldOfView>();
                            if (!scEnemy.bIsDisabled)
                            {
                                scEnemy.bIsDisabled = true;
                                scEnemy.FoeDisabled(scEnemy.bIsDisabled);
                                scEnemy.i_EnnemyBeat = -iTimeFoeDisabled;
                                ThrowingFeedback(bpmManager.FSPB, true, scEnemy);
                                //Unable l'ennemi
                            }
                            else
                            {
                                ThrowingFeedback(bpmManager.FSPB, false, null);
                            }
                        }
                    }
                    bIsBeingAnimated = false;
                    return fThrowMultiplier;
                }
                else if (intersecting.Length == 0 && i==9)
                {
                    bIsBeingAnimated = true;
                    fThrowMultiplier = floatNumber - 1f;
                    ThrowingFeedback(bpmManager.FSPB, false, null);
                    bIsBeingAnimated = false;
                    return fThrowMultiplier;
                }
            }
            // Check for walls in the current direction
            else //qqc est devant le joueur au plus près
            {
                Debug.Log("devant");
                Vector3 CheckPosition = transform.position + vectDir * floatNumber;
                // Use OverlapSphere to check for colliders at the diagonal position
                Collider[] intersecting = Physics.OverlapSphere(CheckPosition, 0.4f, LMask);
                if (intersecting.Length > 0 && i <= 9)
                {
                    foreach (Collider col in intersecting)
                    {
                        if (col.transform.CompareTag("Wall") || col.transform.CompareTag("Tagging") || col.transform.CompareTag("Bait"))
                        {
                            bIsBeingAnimated = true;
                            fThrowMultiplier = floatNumber - 1f;
                            ThrowingFeedback(bpmManager.FSPB, false, null);
                        }
                        else if (col.transform.CompareTag("Enemies 1")) //il y a un ennemi devant le joueur
                        {
                            bIsBeingAnimated = true;
                            fThrowMultiplier = floatNumber - 1f;
                            SC_FieldOfView scEnemy = col.transform.gameObject.GetComponent<SC_FieldOfView>();
                            if (!scEnemy.bIsDisabled)
                            {
                                scEnemy.bIsDisabled = true;
                                scEnemy.FoeDisabled(scEnemy.bIsDisabled);
                                scEnemy.i_EnnemyBeat = -iTimeFoeDisabled;
                                ThrowingFeedback(bpmManager.FSPB, true, scEnemy);
                                //Unable l'ennemi
                            }
                            else
                            {
                                ThrowingFeedback(bpmManager.FSPB, false, null);
                            }
                        }
                    }
                    bIsBeingAnimated = false;
                    return fThrowMultiplier;
                }
                else if (intersecting.Length == 0 && i == 9)
                {
                    bIsBeingAnimated = true;
                    fThrowMultiplier = floatNumber - 1f;
                    ThrowingFeedback(bpmManager.FSPB, false, null);
                    bIsBeingAnimated = false;
                    return fThrowMultiplier;
                }
            }
        }
        bIsBeingAnimated = false;
        return fThrowMultiplier;
    }
    private void Move(Vector3 direction, float jumpPower)
    {
        // diagonale ?
        if (bIsReplaying)
        {
            Vector3 newPos = posLastCheckPoint + Vector3.zero;
            this.transform.DOJump(newPos, jumpPower, 0, bpmManager.FSPB).SetEase(Ease.OutBack);
        }
        else if(bIsImune)
        {
            this.transform.DOJump(this.transform.position, jumpPower, 0, bpmManager.FSPB).SetEase(Ease.OutBack);
        }
        else
        {
            if (direction.x != 0 && direction.z != 0 && direction != Vector3.right)
            {
                Vector3 newPos = this.transform.position + new Vector3(Mathf.Sign(direction.x), 0, Mathf.Sign(direction.z));
                this.transform.DOJump(newPos, jumpPower, 0, bpmManager.FSPB).SetEase(Ease.OutBack);
                //DOMove(newPos, bpmManager.FSPB).SetAutoKill(true);
                //this.transform.GetChild(0).gameObject.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB).SetEase(Ease.OutBack).SetAutoKill(true);
                //this.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB, true).SetEase(Ease.OutBack).SetAutoKill(true);
            }
            else
            {
                Vector3 newPos = this.transform.position + direction;
                this.transform.DOJump(newPos, jumpPower, 0, bpmManager.FSPB).SetEase(Ease.OutBack);
                //DOMove(newPos, bpmManager.FSPB).SetAutoKill(true);
                //this.transform.GetChild(0).gameObject.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB).SetEase(Ease.OutBack).SetAutoKill(true);
                //this.transform.DOJump(newPos, 1f, 0, bpmManager.FSPB, true).SetEase(Ease.OutBack).SetAutoKill(true);
            }
        }
        StartCoroutine(MouvementVFX(bpmManager.FSPB));
        canMove = false;
    }
    private void EnsureRotation()
    {
        if (!bEnsureRotation)
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
            bEnsureRotation = true;
        }
    }
    private void BossDoor(BoxCollider collider, GameObject goDoor, CinemachineVirtualCamera cam)
    {
        menuManager.bGameIsPaused = true;
        collider.gameObject.tag = "Untagged";
        bIsImune = true;
        collider.isTrigger = true;
        cam.Priority = 20;
        DG.Tweening.Sequence sequenceDoor = DOTween.Sequence();
        sequenceDoor.Append(goDoor.transform.DORotate(new Vector3(0, 180, 90), 3f));
        sequenceDoor.OnComplete(() =>
        {
            cam.Priority = 2;
            DG.Tweening.Sequence sequenceDoor1 = DOTween.Sequence();
            sequenceDoor1.AppendInterval(2f);
            sequenceDoor1.OnComplete(() =>
            {
                menuManager.bGameIsPaused = false;
                bIsImune = true;
                StartCoroutine(menuManager.ImuneToPause(bpmManager));
            });
        });
    }
    public void BossDoorToFoe(GameObject goDoor, CinemachineVirtualCamera BossCam, CinemachineVirtualCamera DoorCam, BoxCollider boxColliderBoss)
    {
        DG.Tweening.Sequence sequenceDoor = DOTween.Sequence();
        sequenceDoor.AppendInterval(bpmManager.FSPB*3);
        sequenceDoor.OnComplete(() =>
        {
            boxColliderBoss.isTrigger = false;
            boxColliderBoss.gameObject.tag = "Wall";
            menuManager.bGameIsPaused = true;
            bIsImune = true;
            DoorCam.m_LookAt = null;
            DoorCam.transform.position = new Vector3(73.61456f, 9.834801f, 83.07201f);
            DoorCam.transform.rotation = Quaternion.Euler(40.03f, -74.4f, 0f);
            DoorCam.Priority = 20;
            DG.Tweening.Sequence sequenceDoor1 = DOTween.Sequence();
            sequenceDoor1.Append(goDoor.transform.DORotate(new Vector3(0, 0, 90), 3f));
            sequenceDoor1.OnComplete(() =>
            {
                DoorCam.Priority = 2;
                BossCam.Priority = 20;
                NextExplicationBoss(BossCam);
            });
        });
    }
    private void NextExplicationBoss(CinemachineVirtualCamera BossCam)
    {
        Debug.Log("next explication");
        DG.Tweening.Sequence sequenceDoor2 = DOTween.Sequence();
        sequenceDoor2.AppendInterval(2f);
        sequenceDoor2.OnComplete(() =>
        {
            tutoGen.StartBossExplication(BossCam);
        });
    }

    //CONCERNANT L'UI ET LES FEEDBACKS IMPORTANTS
    //Mouvement
    private IEnumerator MouvementVFX(float time)
    {
        yield return new WaitForSeconds(time * 2/5f);
        GoVfxSteps.transform.localPosition = fPosVFX_steps;
        vfx_steps.Play();
        yield return new WaitForSeconds(time * (1 - 2 / 5f));
        vfx_steps.Stop();
        GoVfxSteps.transform.localPosition = fPosVFX_steps + new Vector3(0f,-50f,0f);
    }
    //Rotation
    private IEnumerator RotationToRight(float time)
    {
        GoVfxRotToRight.transform.localPosition = fPosVFX_RotToRight;
        vfx_RotToRight.Play();
        yield return new WaitForSeconds(time * 4 / 5);
        vfx_RotToRight.Stop();
        GoVfxRotToRight.transform.localPosition = new Vector3(0f, -50f, 0f);
    }
    private IEnumerator RotationToLeft(float time)
    {
        GoVfxRotToLeft.transform.localPosition = fPosVFX_RotToLeft;
        vfx_RotToLeft.Play();
        yield return new WaitForSeconds(time * 4 / 5);
        vfx_RotToLeft.Stop();
        GoVfxRotToLeft.transform.localPosition = new Vector3(0f, -50f, 0f);
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
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3);
            }
            else if (Mathf.Sign(dir.x) == 1)
            {
                currentAngleIndex = 5;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3);
            }
        }
        else if (Mathf.Abs(dir.z) > tolerance && Mathf.Abs(dir.x) <= tolerance)
        {
            // Mouvement haut ou bas
            if (Mathf.Sign(dir.z) == 1)
            {
                currentAngleIndex = 3;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3);
            }
            else if (Mathf.Sign(dir.z) == -1)
            {
                currentAngleIndex = 7;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3);
            }
        }
        else if (Mathf.Abs(dir.x) > tolerance && Mathf.Abs(dir.z) > tolerance)
        {
            // Mouvement diagonal
            if (Mathf.Sign(dir.x) == -1 && Mathf.Sign(dir.z) == 1)
            {
                currentAngleIndex = 2;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3);
            }
            else if (Mathf.Sign(dir.x) == 1 && Mathf.Sign(dir.z) == 1)
            {
                currentAngleIndex = 4;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3);
            }
            else if (Mathf.Sign(dir.x) == -1 && Mathf.Sign(dir.z) == -1)
            {
                currentAngleIndex = 0;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3);
            }
            else if (Mathf.Sign(dir.x) == 1 && Mathf.Sign(dir.z) == -1)
            {
                currentAngleIndex = 6;
                Quaternion quater = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                PlayerCapsule.transform.DORotateQuaternion(quater, time * 1 / 3);
            }
        }

        if (lastLastMoveDirection != dir && dir != Vector3.zero)
        {
            if (lastLastMoveDirection.z > 0)
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
            else if (lastLastMoveDirection.z < 0)
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
    //Tag
    private void TaggingFeedback(float time, Vector3 dir)
    {
        bIsTagging = true;
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
                bIsTagging = false;
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
                bIsTagging = false;
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
        GoVfxTag.transform.localPosition = dir + new Vector3(0f, -50f, 0f);
    }
    private void GraffitiRenderer(Material mat, float startValue, float targetValue)
    {
        float duration = bpmManager.FSPB; // Duration in seconds

        DOTween.To(() => startValue, x =>
        {
            startValue = x;
            mat.SetFloat("_ErosionValue", x);
        }, targetValue, duration);
    }
    private void PlayCinematicFocus(GameObject GoTag, Vector3 dir, float time, int TagsDone)
    {
        Transform focusTarget = GoTag.transform;
        Vector3 position = cinemachineVirtualCamera.transform.position + (GoTag.transform.position- cinemachineVirtualCamera.transform.position)*50/100f;
        //Vector3 newDire = -(GoTag.transform.position - cinemachineVirtualCamera.transform.position) * 4f/10f;
        if (dir.z != 0)
        {
            if(dir.x != 0) //alors c'est une diagonale
            {
                points = new Vector3[4]
                { position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, this.transform.position.z - GoTag.transform.position.z),
                position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, this.transform.position.z - GoTag.transform.position.z) + new Vector3(1, 1, 0),
                position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, this.transform.position.z - GoTag.transform.position.z) + new Vector3(-1, 1, 0),
                position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, this.transform.position.z - GoTag.transform.position.z) + new Vector3(1, 1, -1) };
            }
            else
            {
                points = new Vector3[4]
                { position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, 0),
                position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, 0) + new Vector3(1, 1, 0),
                position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, 0) + new Vector3(-1, 1, 0),
                position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, 0) + new Vector3(1, 1, -1) };
            }
        }
        else if(dir.x != 0)
        {
            if(dir.z != 0)//alors c'est une diagonale
            {
                points = new Vector3[4]
            { position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, this.transform.position.z - GoTag.transform.position.z),
                position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, this.transform.position.z - GoTag.transform.position.z) + new Vector3(0, 1, 1),
                position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, this.transform.position.z - GoTag.transform.position.z) + new Vector3(0, 1, -1),
                position + new Vector3(this.transform.position.x - GoTag.transform.position.x, 0, this.transform.position.z - GoTag.transform.position.z) + new Vector3(-1, 1, 1) };
            }
            else
            {
                points = new Vector3[4]
            { position + new Vector3(0, 0, this.transform.position.z - GoTag.transform.position.z),
                position + new Vector3(0, 0, this.transform.position.z - GoTag.transform.position.z) + new Vector3(0, 1, 1),
                position + new Vector3(0, 0, this.transform.position.z - GoTag.transform.position.z) + new Vector3(0, 1, -1),
                position + new Vector3(0, 0, this.transform.position.z - GoTag.transform.position.z) + new Vector3(-1, 1, 1) };
            }
        }
        VCam_Cinematic.transform.position = points[TagsDone - 1];
        VCam_Cinematic.LookAt = focusTarget;
        cinemachineVirtualCamera.Priority = 5;
        VCam_Cinematic.Priority = 10;

        DG.Tweening.Sequence camSequence = DOTween.Sequence().SetUpdate(true); 
        camSequence.Append(
            VCam_Cinematic.transform.DOMove(points[TagsDone], time).SetEase(Ease.InOutSine)
        );
        camSequence.OnComplete(() =>
        {
            VCam_Cinematic.Priority = 5;
            cinemachineVirtualCamera.Priority = 10;
            VCam_Cinematic.LookAt = null;
        });
    }
    //Bait
    private void ThrowingFeedback(float time, bool bOnFoe, SC_FieldOfView scFoe)
    {
        SoundManager.Instance.PlayOneShot(sfx_baitThrown);
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
            if(bOnFoe)
            {
                GO_BaitInst.transform.GetComponent<ing_Bait>().bOnFoe = true;
                SoundManager.Instance.PlayOneShot(sfx_baitStun);
                if (scFoe.isBoss)
                {
                    Debug.Log("endGame");
                    StartCoroutine(EndGame(true, menuManager._playerData));
                }
            }
            else
            {
                GO_BaitInst.transform.GetComponent<ing_Bait>().bOnFoe = false;
            }
        });
    }
    public IEnumerator CameraShake(float intensity, float time)
    {
        cinemachineBasicMultiChannelPerlin.m_AmplitudeGain = intensity;
        yield return new WaitForSeconds(time);
        cinemachineBasicMultiChannelPerlin.m_AmplitudeGain = 0f;
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
                    if (enemy.i_EnnemyBeat >= 0 && enemy.isBoss)
                    {
                        enemy.bIsDisabled = false;
                        enemy.FoeDisabled(enemy.bIsDisabled);
                    }
                }
            }
            else if (enemy.BCanSee && !enemy.bIsPhaseAnimated)
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
                if (!enemy.isBoss || (enemy.isBoss && enemy.bFinalPhase))
                {
                    enemy.EnemieRotation(bpmManager.FSPB);
                }
                else if(enemy.isBoss && !enemy.bFinalPhase)
                {
                    if(enemy.iRest == 1)
                    {
                        enemy.iRest = 0;
                    }
                    else
                    {
                        enemy.iRest = 1;
                        enemy.EnemieRotation(bpmManager.FSPB);
                    }
                }
                /*else if (enemy.isBoss && !enemy.bIsRemovingTag && enemy.iRemovingRoutine!= enemy.iRemovingRoutineSelection*2)
                {
                    enemy.EnemieRotation(bpmManager.FSPB);
                    if(!bIsImune && !enemy.bFinalPhase)
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
                    if (!bIsImune && !enemy.bFinalPhase)
                    {
                        enemy.iTimeBeforeRemovingThird -= 1;
                        enemy.RemovingTag();
                    }
                }*/
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
            if (enemie.BCanSee && !enemie.bIsPhaseAnimated)
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
            GoVfxDetected.transform.localPosition = fPosVFX_detected + new Vector3(0f,-50f,0f);
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
        menuManager.bGameIsPaused = true;
        bIsImune = true;
        //yield return new WaitForSeconds(2f);
        Time.timeScale = 0f;
        menuManager.PauseGame();

        menuManager.CgEndDialogue.alpha = 1f;
        menuManager.CgEndDialogue.blocksRaycasts = true;
        menuManager.RtEndDialogue.anchorMin = new Vector2(0, 0);
        menuManager.RtEndDialogue.anchorMax = new Vector2(1, 1);
        menuManager.RtEndDialogue.offsetMax = new Vector2(0f, 0f);
        menuManager.RtEndDialogue.offsetMin = new Vector2(0f, 0f);

        if(fPercentScore >= 35)
        {
            menuManager.BeginDialogue(true, true);
        }
        else
        {
            menuManager.BeginDialogue(true, false);
        }
    }
    public IEnumerator EndGame(bool hasWon, PlayerData data)
    {
        menuManager.bGameIsPaused = true;
        bIsImune = true;
        if(hasWon)
        {
            menuManager.textBravo.color = new Color32(255, 255, 255, 255);
            menuManager.textBravo.transform.localScale = new Vector3(3f, 3f, 3f);
            menuManager.textBravo.transform.DOScale(new Vector3(1f, 1f, 1f), 1f).SetEase(Ease.InOutElastic);
        }
        else
        {
            menuManager.textBravo.color = new Color32(255, 255, 255, 0);
            menuManager.textBravo.transform.localScale = new Vector3(3, 3, 3);
        }
        yield return new WaitForSeconds(3f);
        if (hasWon)
        {
            menuManager.textBravo.color = new Color32(255, 255, 255, 0);
            menuManager.textBravo.transform.localScale = new Vector3(3, 3, 3);
        }
        Time.timeScale = 0f;
        menuManager.PauseGame();
        //PlayerData data = menuManager.gameObject.GetComponent<PlayerData>();

        menuManager.CgScoring.alpha = 1f;
        menuManager.CgScoring.blocksRaycasts = true;
        menuManager.CgScoring.interactable = true;
        menuManager.RtScoring.anchorMin = new Vector2(0, 0);
        menuManager.RtScoring.anchorMax = new Vector2(1, 1);
        menuManager.RtScoring.offsetMax = new Vector2(0f, 0f);
        menuManager.RtScoring.offsetMin = new Vector2(0f, 0f);

        StartCoroutine(ScoringDetails(hasWon, data));
        if (hasWon && fPercentScore >= 35)
        {
            if (data.iLanguageNbPlayer == 1)
            {
                menuManager.txt_Title.text = "Félicitation!";
            }
            else
            {
                menuManager.txt_Title.text = "Congratulation!";
            }
            //BUTTONS
            UnityEngine.UI.Button[] buttonScorring = new UnityEngine.UI.Button[2];
            TextMeshProUGUI[] txt = new TextMeshProUGUI[2];
            for (int i =0; i<2; i++)
            {
                buttonScorring[i] = menuManager.GoScoringButtons.transform.GetChild(i).GetComponent<UnityEngine.UI.Button>();
                txt[i] = menuManager.GoScoringButtons.transform.GetChild(i).transform.GetChild(0).GetComponent<TextMeshProUGUI>();
            }
            buttonScorring[0].onClick.AddListener(delegate { EndDialogue(); });
            buttonScorring[1].onClick.AddListener(delegate { menuManager.LoadScene("retry"); });
            if (data.iLanguageNbPlayer == 1)
            {
                txt[0].text = "Continuer";
                txt[1].text = "Réessayer";
            }
            else
            {
                txt[0].text = "Next";
                txt[1].text = "Retry";
            }
            //APPARITION
            menuManager.CgScoringSuccess.alpha = 1f;
            menuManager.CgScoringSuccess.blocksRaycasts = true;
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
            menuManager.txt_Title.text = "Game Over!";
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
                txt[0].text = "Réessayer";
                txt[1].text = "Revoir la carte";
            }
            else
            {
                txt[0].text = "Retry";
                txt[1].text = "See Map";
            }
            //APPARITION
            menuManager.CgScoringSuccess.alpha = 0f;
            menuManager.CgScoringSuccess.blocksRaycasts = false;
            menuManager.RtScoringSuccess.anchorMin = new Vector2(0, 1);
            menuManager.RtScoringSuccess.anchorMax = new Vector2(1, 2);
            menuManager.RtScoringSuccess.offsetMax = new Vector2(0f, 0f);
            menuManager.RtScoringSuccess.offsetMin = new Vector2(0f, 0f);

            menuManager.RtScoringButtons.anchorMin = new Vector2(0.75f, 0.35f);
            menuManager.RtScoringButtons.anchorMax = new Vector2(0.9f, 0.6f);
            menuManager.ImgScoringBackground.sprite = menuManager.spritesScoringBackground[1];
        }
        menuManager.EventSystem.SetSelectedGameObject(menuManager.GoScoringFirstButtonSelected);
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
            menuManager.CgScoring.blocksRaycasts = false;
            menuManager.RtScoring.anchorMin = new Vector2(0, 1);
            menuManager.RtScoring.anchorMax = new Vector2(1, 2);
            menuManager.RtScoring.offsetMax = new Vector2(0f, 0f);
            menuManager.RtScoring.offsetMin = new Vector2(0f, 0f);

            menuManager.CgLoadingScreen.alpha = 1f;
            menuManager.CgLoadingScreen.blocksRaycasts = true;
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
            posLastCheckPoint = new Vector3(Mathf.Round(this.gameObject.transform.position.x), posYInit, Mathf.Round(this.gameObject.transform.position.z));
            iTagPreviouslyDone = itagDone;
            FPreviousScore = FScore;
            fPreviousNbBeat = fNbBeat;
            fPreviousNbBeatScoring[0] = fScoreDetails[0];
            fPreviousNbBeatScoring[1] = fScoreDetails[1];
            fPreviousNbBeatScoring[2] = fScoreDetails[2];
            fPreviousNbBeatScoring[3] = fScoreDetails[3];
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
            fScoreDetails[0] = 0f;
            fScoreDetails[1] = 0f;
            fScoreDetails[2] = 0f;
            fScoreDetails[3] = 0f;
            foreach (ing_Tag tag in allTagsUntil1stCheckPoint)
            {
                foreach (VisualEffect vfx in tag.PS_Sound)
                {
                    vfx.Play();
                }
                tag.iCompletition = 0;
                tag.transform.gameObject.tag = "Tagging";
                //tag._renderer.material = tag.untaggedMaterial; //pas de tag
                tag.decalProj.material.SetFloat("_ErosionValue", 1f);
            }
        }
        else
        {
            itagDone = iTagPreviouslyDone;
            FScore = FPreviousScore;
            fNbBeat = fPreviousNbBeat;
            fScoreDetails[0] = fPreviousNbBeatScoring[0];
            fScoreDetails[1] = fPreviousNbBeatScoring[1];
            fScoreDetails[2] = fPreviousNbBeatScoring[2];
            fScoreDetails[3] = fPreviousNbBeatScoring[3];
            foreach (ing_Tag tag in checkpoints[iCheckPoint-1].tags)
            {
                foreach (VisualEffect vfx in tag.PS_Sound)
                {
                    vfx.Play();
                }
                tag.iCompletition = 0;
                tag.transform.gameObject.tag = "Tagging";
                //tag._renderer.material = tag.untaggedMaterial; //pas de tag
                tag.decalProj.material.SetFloat("_ErosionValue",1f);
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

        //RESTART BAITS LVL2
        if(SceneManager.GetActiveScene().name == "SceneLvl2")
        {
            foreach(ing_Bait bait in ingBaitLvl2)
            {
                if(bait.transform.position != bait.beginVect)
                {
                    bait.bOnFoe = false;
                    bait.transform.position = bait.beginVect;
                    bait.sc_juice.Restart();
                }
            }
        }
    }
    private List<int> iStars()
    {
        List<int> List = new List<int>();

        //BOOGIE WOOGIE
        List.Add(1);

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
        //LORD OF THE BEAT
        if (fPercentScore >= 80) 
        {
            List.Add(1);
        }
        else
        {
            List.Add(0);
        }
        return List;
    }
    private List<string> sJugement(bool finished, PlayerData data, float fScore)
    {
        if (fScore >= 95 && finished)
        {
            List<string> List = new List<string> { "S+", Mathf.Round(fScore).ToString() + "%" };
            return List;
        }
        else if (fScore >= 80 && finished)
        {
            List<string> List = new List<string> { "S", Mathf.Round(fScore).ToString() + "%" };
            return List;
        }
        else if (fScore >= 65 && finished)
        {
            List<string> List = new List<string> { "A", Mathf.Round(fScore).ToString() + "%" };
            return List;
        }
        else if (fScore >= 50 && finished)
        {
            List<string> List = new List<string>{"B", Mathf.Round(fScore).ToString() + "%" };
            return List;
        }
        else if (fScore >= 35 && finished)
        {
            List<string> List = new List<string> { "C", Mathf.Round(fScore).ToString() + "%" };
            return List;
        }
        else if (!finished)
        {
            if(data.iLanguageNbPlayer == 1)
            {
                List<string> List = new List<string> { "Grillé", Mathf.Round(fScore).ToString() + "%" };
                return List;
            }
            else
            {
                List<string> List = new List<string> { "Busted", Mathf.Round(fScore).ToString() + "%" };
                return List;
            }
        }
        else
        {
            List<string> List = new List<string> { "F", Mathf.Round(fScore).ToString() + "%" };
            return List;
        }
    }
    private IEnumerator ScoringDetails(bool bhasWon, PlayerData data)
    {
        if (bhasWon)
        {
            menuManager.cgScoreDetails.alpha = 1f;
            menuManager.txtScoringJudgment.color = new Color32(255, 255, 255, 0);
            menuManager.txtScoringScore.color = new Color32(255, 255, 255, 0);
            bool[] bDispayedDetails = new bool[4] { true, false, false, false};
            bool bOnce = false;
            int[] displayedScoreDetails = new int[4] { 0, 0, 0, 0 };
            int[] actualScoreDetails = new int[4] { (int)Math.Round((fScoreDetails[0]/fNbBeat)*100), (int)Math.Round((fScoreDetails[1] / fNbBeat)*100), (int)Math.Round((fScoreDetails[2] / fNbBeat)*100), (int)Math.Round((fScoreDetails[3] / fNbBeat) * 100) };
            for (int i = 0; i < 4; i++)
            {
                if (!bOnce)
                {
                    menuManager.txtScoringScoreDetails[i].color = new Color32(255, 255, 255, 0);
                    if(i==3)
                    {
                        bOnce = true;
                    }
                }
                while (bDispayedDetails[i])
                {
                    menuManager.txtScoringScoreDetails[i].color = new Color32(255, 255, 255, 255);
                    yield return new WaitForSecondsRealtime(0.05f);
                    int difference = actualScoreDetails[i] - displayedScoreDetails[i];

                    if (difference != 0)
                    {
                        int constantTerm = 1;

                        int proportionalTerm = difference / 5;

                        int moveStep = Mathf.Abs(proportionalTerm) + constantTerm;

                        displayedScoreDetails[i] = (int)Mathf.MoveTowards(displayedScoreDetails[i], actualScoreDetails[i], moveStep);

                        menuManager.txtScoringScoreDetails[i].text = displayedScoreDetails[i].ToString() + "%";
                        /// now use displayedScore to update your text output
                    }
                    else
                    {
                        menuManager.txtScoringScoreDetails[i].text = Mathf.Round((fScoreDetails[i] / fNbBeat) * 100).ToString() + "%";
                        bDispayedDetails[i] = false;
                        if(i != 3)
                        {
                            bDispayedDetails[i + 1] = true;
                        }
                    }
                }
            }
            yield return new WaitForSecondsRealtime(0.2f);
            bool bDisplayed = false;
            int displayedScore = 0;
            int actualScore = (int)fPercentScore;
            while (!bDisplayed)
            {
                yield return new WaitForSecondsRealtime(0.05f);

                int difference = actualScore - displayedScore;

                if (difference != 0)
                {
                    int constantTerm = 1;

                    int proportionalTerm = difference / 5;

                    int moveStep = Mathf.Abs(proportionalTerm) + constantTerm;

                    displayedScore = (int)Mathf.MoveTowards(displayedScore, actualScore, moveStep);

                    menuManager.txtScoringJudgment.text = sJugement(bhasWon, data, displayedScore)[0];
                    menuManager.txtScoringScore.text = sJugement(bhasWon, data, displayedScore)[1];
                    menuManager.txtScoringJudgment.color = new Color32(255, 255, 255, 255);
                    menuManager.txtScoringScore.color = new Color32(255, 255, 255, 255);
                    float fDifferenceScale = (100-difference) / 100F;
                    menuManager.txtScoringJudgment.transform.localScale = new Vector3(fDifferenceScale, fDifferenceScale, fDifferenceScale);
                    menuManager.txtScoringScore.transform.localScale = new Vector3(fDifferenceScale, fDifferenceScale, fDifferenceScale);
                    /// now use displayedScore to update your text output
                }
                else
                {
                    bDisplayed = true;
                    menuManager.txtScoringScore.transform.localScale = new Vector3(1f, 1f, 1f);
                    menuManager.txtScoringJudgment.transform.localScale = new Vector3(1.1f, 1.1f, 1.1f);
                    menuManager.txtScoringJudgment.text = sJugement(bhasWon, data, fPercentScore)[0];
                    menuManager.txtScoringScore.text = sJugement(bhasWon, data, fPercentScore)[1];
                }
            }
            if (fPercentScore >= 35)
            {
                //LES EXPLOITS
                List<int> ints = iStars();
                UnityEngine.UI.Image[] imgStars = new UnityEngine.UI.Image[ints.Count];
                TMP_Text[] texts = new TMP_Text[ints.Count];
                for (int i = 0; i < ints.Count; i++)
                {
                    imgStars[i] = menuManager.GoScoringSuccess.transform.GetChild(i).gameObject.transform.GetChild(0).gameObject.GetComponent<UnityEngine.UI.Image>();
                    texts[i] = menuManager.GoScoringSuccess.transform.GetChild(i).gameObject.transform.GetChild(1).gameObject.GetComponent<TMP_Text>();
                    if (ints[i] == 1) //vrai
                    {
                        imgStars[i].sprite = menuManager.sprite_star_completed;
                        texts[i].color = new Color32(255, 255, 255, 255);
                    }
                    else //Faux
                    {
                        imgStars[i].sprite = menuManager.sprite_star_empty;
                        if (i != ints.Count - 1)
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
            }
        }
        else
        {
            //LE SCORING
            menuManager.txtScoringJudgment.text = sJugement(bhasWon, data, fPercentScore)[0];
            menuManager.txtScoringScore.text = sJugement(bhasWon, data, fPercentScore)[1];
            menuManager.cgScoreDetails.alpha = 0f;
        }
        yield return new WaitForSecondsRealtime(0.1f);
    }
    private void PlayerDataUpdate(PlayerData data)
    {
        int i = Int32.Parse(Regex.Match(SceneManager.GetActiveScene().name, @"\d+").Value);
        Debug.Log("le niveau est le " + i);
        if (fPercentScore > data.iScorePerLvlPlayer[i])
        {
            data.iScorePerLvlPlayer[i] = Convert.ToInt32(fPercentScore);
        }
        data.iStarsPlayer[0 + 5 * i] = 1;
        if (!bHasBeenDetectedOneTime)
        {
            data.iStarsPlayer[1 + 5 * i] = 1;
        }
        if(bHasNoMiss)
        {
            data.iStarsPlayer[2 + 5 * i] = 1;
        }
        if (itagDone == menuManager.iNbTaggs[i])
        {
            data.iStarsPlayer[3 + 5 * i] = 1;
        }
        if(fPercentScore >= 80)
        {
            data.iStarsPlayer[4 + 5 * i] = 1;
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
