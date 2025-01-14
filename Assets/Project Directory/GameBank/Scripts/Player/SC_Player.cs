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
//using UnityEditor.PackageManager;

public class SC_Player : MonoBehaviour
{
    public bool bisTuto = false;
    public bool bGameIsPaused = false;
    [SerializeField] private SoundManager soundManager;
    public MenuManager menuManager;
    public bool bIsOnComputer = true;
    public bool bOnControllerConstraint = false;
    [SerializeField] private BPM_Manager bpmManager;

    //LE PLAYER ET SES MOUVEMENTS
    [Header("Player and movement")]
    public PlayerControl control;
    Vector2 move;
    public Vector3 lastMoveDirection;
    public GameObject PlayerCapsule;
    private float tolerance = 0.5f;
    public bool canMove = false;
    public bool bcanRotate = false;
    /*
    //LE BEAT
    [Header("Beat")]
    public float FBPM;
    private float FBPS;
    public float FSPB;
    [SerializeField] private CinemachineFollowZoom FOVS;
    private bool b_more = false;
    private bool b_less = false;
    [SerializeField] private EventReference playerLoop;
    private FMOD.Studio.EventInstance playerLoopInstance;

    //FEEDBACK ON TIMING
    [Header("Timing Feedbacks")]
    [SerializeField] private Color32 colorMiss;
    [SerializeField] private Color32 colorBad;
    [SerializeField] private Color32 colorGood;
    [SerializeField] private Color32 colorPerfect;
    private float FBadTiming;
    private float FZoneBadTiming;
    private float FGoodTiming;
    private float FZoneGoodTiming;
    private float FPerfectTiming;
    private float FZonePerfectTiming;
    private float FWaitTime;
    public bool BBad = false;
    public bool BGood = false;
    public bool BPerfect = false;
    private bool bBaitBad = false;
    private bool bBaitGood = false;
    private bool bBaitPerfect = false;
    [SerializeField] private TMP_Text txt_Feedback;
    public GameObject GOUiBad;
    public GameObject GOUiGood;
    public GameObject GOUiPerfect;
    */
    //LE BAIT
    [Header("Bait")]
    [SerializeField] private GameObject GOBait;
    private GameObject GO_BaitInst;
    public bool newThrow = false;
    public bool hasAlreadyBaited = false;
    private float fThrowMultiplier = 1f;

    //LE SCORE
    [Header("Score")]
    public float FScore;
    public TMP_Text TMPScore;

    //LE JOYSTICK
    [Header("Joystick")]
    [Tooltip("0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG")] public GameObject[] UI_Joystick;
    private float[] angles = { -135f, -90f, -45f, 0f, 45f, 90f, 135f, 180f };
    private int currentAngleIndex = 3;

    //LA DETECTION
    [Header("Detection")]
    public float fDetectionDangerosity = 20f;
    [SerializeField] private float fDetectionLessers = 2f;
    public float FDetectionRate = 2f;
    public float FDetectionLevel = 0f;
    private float fDetectionLevelMax = 200f;
    [SerializeField] private SC_FieldOfView[] allEnemies;
    public float FTimeWithoutLooseDetection = 5f;
    private bool BLooseDetectLevel;
    [SerializeField] private UnityEngine.UI.Slider sliderDetection;
    public bool BisDetectedByAnyEnemy = false;

    //LE TAG
    [Header("Tag")]
    public float taggingRange = 1.1f;
    public Material taggedMaterial; 
    private RaycastHit[] hitInfo = new RaycastHit[4];
    [SerializeField] private LayerMask LMask;
    /*[SerializeField] private float fFOVmin = 10f;
    [SerializeField] private float fFOVmax = 10.6f;*/

    void OnEnable()
    {
        if (!bIsOnComputer)
        {
            control = new PlayerControl();
            control.GamePlay.Enable();
        }
    }
    void OnDisable()
    {
        if (!bIsOnComputer)
        {
            control.GamePlay.Disable();
        }
    }
    private void Awake()
    {
        CheckControllerStatus();
    }
    void Start()
    {
        UnityEngine.Cursor.lockState = CursorLockMode.Locked;
        if (menuManager == null)
        {
            GameObject goMenu = GameObject.FindWithTag("Manager");
            if (goMenu == null)
            {
                bIsOnComputer = true;
            }
            else
            {
                menuManager = goMenu.GetComponent<MenuManager>();
                control = menuManager.control;
                bIsOnComputer = !menuManager.controllerConnected;
            }
        }
        else
        {
            control = menuManager.control;
            bIsOnComputer = !menuManager.controllerConnected;
        }
        if (FDetectionRate == 0f)
        {
            FDetectionRate = 1f;
        }
        //soundManager.PlayMusic("lvl0_Tambour");
        //FBPS = 60/FBPM;
        /*FBPS = FBPM/60f;
        FSPB = 1f/FBPS;
        FPerfectTiming = 2/14f * FSPB;
        FGoodTiming = 4/14f * FSPB;
        FBadTiming = 6/14f * FSPB;
        FZoneBadTiming = FBadTiming;
        FZoneGoodTiming = FGoodTiming;
        FZonePerfectTiming = FPerfectTiming;
        FWaitTime = FSPB - FZoneBadTiming;
        StartCoroutine(wait());
        playerLoopInstance = RuntimeManager.CreateInstance(playerLoop);
        playerLoopInstance.start(); 
        playerLoopInstance.setParameterByName("fPausedVolume", 0.8f);*/
    }
    /*public void StartAfterTuto()
    {
        StartCoroutine(wait());
    }*/
    /*
    //LE TEMPO
    IEnumerator wait()
    {
        if (!bisTuto)
        {
            bcanRotate = true;
        }
        RotationEnemies();
        yield return new WaitForSeconds(FWaitTime);
        StartCoroutine(bad());
    }
    IEnumerator bad()
    {
        canMove = true;
        txt_Feedback.text = "";
        txt_Feedback.color = new Color32(0, 0, 0, 0);
        BBad = true;
        yield return new WaitForSeconds(FZoneBadTiming);
        BBad = false;
        StartCoroutine(good());
        yield return new WaitForSeconds(FZoneGoodTiming + FZonePerfectTiming + FZoneGoodTiming);
    }
    IEnumerator good()
    {
        BGood = true;
        yield return new WaitForSeconds(FZoneGoodTiming);
        BGood = false;
        StartCoroutine(perfect());
        yield return new WaitForSeconds(FZonePerfectTiming);
    }
    IEnumerator perfect()
    {
        BPerfect = true;
        yield return new WaitForSeconds(FZonePerfectTiming);
        if(BisDetectedByAnyEnemy)
        {
            FDetectionLevel += fDetectionDangerosity;
        }
        BPerfect = false;
        canMove = false;
        if (BBad == false && BGood == false && BPerfect == false && bcanRotate == true)
        {
            txt_Feedback.text = "Miss";
            txt_Feedback.color = colorMiss;
            bBaitBad = false;
            bBaitGood = false;
            bBaitPerfect = false;
        }
        if (bisTuto ==false)
        {
            CheckForward(lastMoveDirection, taggingRange);
        }
        StartCoroutine(wait());
    }*/
    
    //L'UPDATE
    void Update()
    {
        CheckControllerStatus();
        TMPScore.SetText(FScore.ToString());
        sliderDetection.value = FDetectionLevel / fDetectionLevelMax;
        if(FDetectionLevel>= fDetectionLevelMax)
        {
            EndGame(false);
        }
        if (bcanRotate == true)
        {
            UpdateDirAndMovOnJoystickOrPC();
        }
        //CheckIfInputOnTempo();
        EnemieDetection();
        /*Rythme();
        CameraRythm(Time.deltaTime, fFOVmax, fFOVmin);*/
    }
    public void PauseGame()
    {
        if(bGameIsPaused)
        {
            Time.timeScale = 0f;
            if(bisTuto == false)
            {
                bpmManager.playerLoopInstance.setParameterByName("fPausedVolume", 0.8f);
            }
        }
        else
        {
            Time.timeScale = 1f;
            bpmManager.playerLoopInstance.setParameterByName("fPausedVolume", 1f);
        }
    }

    //CONCERNANT LES CONTROLS
    private void UpdateDirAndMovOnJoystickOrPC()
    {
        //MOUVEMENT SUR CLAVIER OU MANETTE?
        if (!bIsOnComputer || bOnControllerConstraint)
        {
            move = control.GamePlay.Orientation.ReadValue<Vector2>();
        }
        else if (bIsOnComputer)
        {
            move = new Vector2(1, 0);
        }
        //UDPATE LA DIRECTION
        if (move != Vector2.zero)
        {
            Vector3 direction = Vector3.forward;
            if (!bIsOnComputer || bOnControllerConstraint)
            {
                direction = GetDirectionFromJoystick(move);
            }
            else if (bIsOnComputer)
            {
                direction = GetDirectionFromClavier();
            }
            if (direction != Vector3.zero)
            {
                lastMoveDirection = direction;
            }
            UpdateDirectionUI();
        }
    }
    /*private void CheckIfInputOnTempo()
    {
        if (bcanRotate && canMove && (((!bIsOnComputer|| bOnControllerConstraint) && control.GamePlay.Move.triggered)|| (bIsOnComputer && !bOnControllerConstraint &&Input.GetButtonDown("Jump"))))
        {
            if (BBad == true)
            {
                FScore = FScore + 10f;
                txt_Feedback.text = "Bad";
                txt_Feedback.color = colorBad;
                bBaitBad = true;
                bBaitGood = false;
                bBaitPerfect = false;
            }
            else if (BGood == true)
            {
                FScore = FScore + 50f;
                txt_Feedback.text = "Good";
                txt_Feedback.color = colorGood;
                bBaitBad = false;
                bBaitGood = true;
                bBaitPerfect = false;
            }
            else if (BPerfect == true)
            {
                FScore = FScore + 100f;
                txt_Feedback.text = "Perfect!";
                txt_Feedback.color = colorPerfect;
                bBaitBad = false;
                bBaitGood = false;
                bBaitPerfect = true;
            }
            bcanRotate = false;
        }
    }*/
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
    public void ShootBait()
    {
        CheckForward(lastMoveDirection, 0f);
        if (fThrowMultiplier == 0f)
        {
            //nothing
        }
        else
        {
            Baiting(new Vector3(this.transform.position.x, this.transform.position.y-0.5f, this.transform.position.z) + lastMoveDirection * fThrowMultiplier);
        }
    }
    private void Baiting(Vector3 _spawnpos)
    {
        newThrow = true;
        GO_BaitInst = Instantiate(GOBait, _spawnpos, Quaternion.identity);
        GO_BaitInst.transform.GetChild(0).transform.gameObject.GetComponent<bait_juicy>().enabled = true;
        ing_Bait scBait = GO_BaitInst.GetComponent< ing_Bait>();
        scBait.b_BeenThrown = true;
        StartCoroutine (BaitChange(1f));
    }
    private IEnumerator BaitChange(float waitTime)
    {
        yield return new WaitForSeconds(waitTime);
        newThrow = false;
    }

    //VERIFIER LE MOUVEMENT
    public void CheckForward(Vector3 vectDir, float fRange)
    {
        if (fRange == taggingRange)
        {
            // 1. Check for diagonal movement first
            if (vectDir.x != 0f && vectDir.z != 0f) // Diagonal movement
            {
                Vector3 diagonalCheckPosition = transform.position + vectDir.normalized * fRange;

                // Use OverlapSphere to check for colliders at the diagonal position
                Collider[] intersecting = Physics.OverlapSphere(diagonalCheckPosition, 0.1f, LMask);
                bool canMoveDiagonally = true;

                if (intersecting.Length > 0)
                {
                    // Loop through colliders to check tags
                    foreach (Collider collider in intersecting)
                    {
                        if (!collider.CompareTag("Bait"))
                        {
                            canMoveDiagonally = false; // Block movement if an unpassable object is found
                            break;
                        }
                    }
                }

                if (canMoveDiagonally)
                {
                    // Move diagonally if no blocking objects or only passable ones
                    Move(vectDir);
                    return;
                }
                else
                {
                    Debug.Log("Diagonal blocked, finding new direction...");
                    Vector3 newDirection = FindNewDirection(vectDir, fRange);
                    if (newDirection != Vector3.zero)
                    {
                        Move(newDirection);
                    }
                    return;
                }
            }
            // Check for walls in the current direction
            else
            {
                if (Physics.Raycast(transform.position, vectDir, out RaycastHit hitInfo, fRange + 0.2f, LMask))
                {
                    if (hitInfo.transform.CompareTag("Tagging")) //c'est un mur à tagger
                    {
                        Renderer wallRenderer = hitInfo.transform.GetComponent<Renderer>();
                        GameObject wallTagged = hitInfo.transform.gameObject;
                        wallRenderer.material = taggedMaterial; //le joueur tag
                        wallTagged.tag = "Wall";
                        if (wallTagged.gameObject.name == "EndingWall")
                        {
                            EndGame(true);
                        }
                        return;
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
                    if (intersecting.Length > 0 && ((!bpmManager.bBaitPerfect && !bpmManager.bBaitGood && !bpmManager.bBaitBad && i <= 5) || (bpmManager.bBaitBad && i <= 7) || (bpmManager.bBaitGood && i <= 8) || (bpmManager.bBaitPerfect && i <= 9)))
                    {
                        foreach(Collider col in intersecting)
                        {
                            if (col.transform.CompareTag("Wall") || col.transform.CompareTag("Tagging") || col.transform.CompareTag("Bait"))
                            {
                                fThrowMultiplier = floatNumber - 1f;
                                return;
                            }
                            else if (col.transform.CompareTag("Enemies 1")) //il y a un ennemi devant le joueur
                            {
                                fThrowMultiplier = floatNumber - 1f;
                                SC_FieldOfView scEnemy = col.transform.gameObject.GetComponent<SC_FieldOfView>();
                                scEnemy.bIsDisabled = true;
                                scEnemy.FoeDisabled(scEnemy.bIsDisabled);
                                scEnemy.i_EnnemyBeat = -5;
                                //Unable l'ennemi
                                return;
                            }
                            else //nothing in front of the player
                            {
                                //nothing
                            }
                        }
                    }
                    else if ((!bpmManager.bBaitPerfect && !bpmManager.bBaitGood && !bpmManager.bBaitBad && i == 6) || (bpmManager.bBaitBad && i == 8) || (bpmManager.bBaitGood && i == 9) || (bpmManager.bBaitPerfect && i == 10))
                    {
                        fThrowMultiplier = floatNumber - 1f;
                        return;
                    }
                    else
                    {
                        //nothing
                    }
                }
                // Check for walls in the current direction
                else if (Physics.Raycast(transform.position, vectDir, out RaycastHit hitInfo1, floatNumber + 0.1f, LMask) && ((!bpmManager.bBaitPerfect && !bpmManager.bBaitGood && !bpmManager.bBaitBad && i <= 5) || (bpmManager.bBaitBad && i <= 7) || (bpmManager.bBaitGood && i <= 8) || (bpmManager.bBaitPerfect && i <= 9))) //qqc est devant le joueur au plus près
                {
                    if (hitInfo1.transform.CompareTag("Wall") || hitInfo1.transform.CompareTag("Tagging") || hitInfo1.transform.CompareTag("Bait"))//il y a un mur devant le joueur
                    {
                        fThrowMultiplier = floatNumber - 1f;
                        return;
                    }
                    else if (hitInfo1.transform.CompareTag("Enemies 1")) //il y a un ennemi devant le joueur
                    {
                        fThrowMultiplier = floatNumber - 1f;
                        SC_FieldOfView scEnemy = hitInfo1.transform.gameObject.GetComponent<SC_FieldOfView>();
                        scEnemy.bIsDisabled = true;
                        scEnemy.FoeDisabled(scEnemy.bIsDisabled);
                        scEnemy.i_EnnemyBeat = -5;
                        //Unable l'ennemi
                        return;
                    }
                    else //nothing in front of the player
                    {
                        //nothing
                    }
                }
                else if ((!bpmManager.bBaitPerfect && !bpmManager.bBaitGood && !bpmManager.bBaitBad && i == 6) || (bpmManager.bBaitBad && i == 8) || (bpmManager.bBaitGood && i == 9) || (bpmManager.bBaitPerfect && i == 10))
                {
                    fThrowMultiplier = floatNumber - 1f;
                    return;
                }
                else
                {
                    //nothing
                }
            }
        }
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

            // Check for walls in the new direction
            if (!Physics.Raycast(transform.position, dir, out RaycastHit hitInfo, range + 0.2f, LMask))
            {
                return dir; // Return the first valid direction
            }
        }

        // If all directions are blocked, return Vector3.zero
        return Vector3.zero;
    }
    private void Move(Vector3 direction)
    {
        // diagonale ?
        if (Mathf.Abs(direction.x) > 0 && Mathf.Abs(direction.z) > 0)
        {
            // mouvement x et z
            transform.position += new Vector3(Mathf.Sign(direction.x), 0, Mathf.Sign(direction.z));
        }
        else
        {
            transform.position += direction;  // mouvement  1 case
        }
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
                UIFlase();
                UI_Joystick[3].SetActive(true); // Gauche
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1)
            {
                currentAngleIndex = 5;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_Joystick[4].SetActive(true); // Droite
            }
        }
        else if (Mathf.Abs(lastMoveDirection.z) > tolerance && Mathf.Abs(lastMoveDirection.x) <= tolerance)
        {
            // Mouvement haut ou bas
            if (Mathf.Sign(lastMoveDirection.z) == 1)
            {
                currentAngleIndex = 3;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_Joystick[0].SetActive(true); // Haut
            }
            else if (Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 7;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_Joystick[6].SetActive(true); // Bas
            }
        }
        else if (Mathf.Abs(lastMoveDirection.x) > tolerance && Mathf.Abs(lastMoveDirection.z) > tolerance)
        {
            // Mouvement diagonal
            if (Mathf.Sign(lastMoveDirection.x) == -1 && Mathf.Sign(lastMoveDirection.z) == 1)
            {
                currentAngleIndex = 2;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_Joystick[2].SetActive(true); // HautGauche
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1 && Mathf.Sign(lastMoveDirection.z) == 1)
            {
                currentAngleIndex = 4;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_Joystick[1].SetActive(true); // Haut-Droite
            }
            else if (Mathf.Sign(lastMoveDirection.x) == -1 && Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 0;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_Joystick[8].SetActive(true); // Bas Gauche
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1 && Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 6;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_Joystick[7].SetActive(true); // Bas Droite
            }
        }
    }
    private void UIFlase()
    {
        for (int i = 0; i < UI_Joystick.Length; i++)
        {
            UI_Joystick[i].SetActive(false);
        }
    }

    //CONCERNANT LE RYTHME
    public void RotationEnemies()
    {
        foreach (SC_FieldOfView enemy in allEnemies)
        {
            if (enemy.bIsDisabled)
            {
                enemy.i_EnnemyBeat += 1;
                if(enemy.i_EnnemyBeat >= 0)
                {
                    enemy.bIsDisabled = false;
                    enemy.FoeDisabled(enemy.bIsDisabled);
                }
            }
            else if (enemy.BCanSee)
            {
                enemy.PlayerDetected(this.gameObject);
                enemy.i_EnnemyBeat =6;
            }
            else if(enemy.bHasHeard)
            {
                enemy.BaitHeard(GO_BaitInst);
                enemy.i_EnnemyBeat += 1;
            }
            else
            {
                enemy.EnemieRotation(); 
            }
        }
    }
    /*private void Rythme()
    {
        if(BBad == true)
        {
            GOUiBad.SetActive(true);
        }
        if(BGood == true)
        {
            GOUiGood.SetActive(true);
        }
        if(BPerfect == true)
        {
            GOUiPerfect.SetActive(true);
        }
        if(BPerfect == false)
        {
            GOUiPerfect.SetActive(false);
        }
        if(BPerfect == false && BGood == false)
        {
            GOUiPerfect.SetActive(false);
            GOUiGood.SetActive(false);
        }
        if(BPerfect == false && BGood == false && BBad == false)
        {
            GOUiPerfect.SetActive(false);
            GOUiGood.SetActive(false);
            GOUiBad.SetActive(false);
        }
    }
    private void CameraRythm(float f_time, float f_max, float f_min)
    {
        float fov = FOVS.m_MinFOV;
        if(BPerfect == true)
        {
            b_more = true;
            b_less = false;
        }
        else if(BBad == true)
        {
            b_more = false;
            b_less = true;
        }
        if (b_less)
        {
            fov = Mathf.Lerp(f_max, f_min, -f_time);
            FOVS.m_Width = fov;
        }
        else if(b_more)
        {
            fov = Mathf.Lerp(f_min, f_max, f_time);
            FOVS.m_Width = fov;
        }
    }*/

    //CONCERNANT LA DETECTION
    void EnemieDetection()
    {
        int i = 0;
        int y = 0;
        foreach (SC_FieldOfView enemie in allEnemies)
        {
            if (enemie.BCanSee)
            {
                if(enemie.bIsFakeEnemy == false)
                {
                    BLooseDetectLevel = false;
                    BisDetectedByAnyEnemy = true;
                }
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
 
        if (BLooseDetectLevel)
        {
            FDetectionLevel -= FDetectionRate * Time.deltaTime* fDetectionLessers;
            FDetectionLevel = Mathf.Max(FDetectionLevel, 0);
        }

        if(BisDetectedByAnyEnemy)
        {
            GameObject GoChild = this.gameObject.transform.GetChild(2).gameObject;
            GoChild.SetActive(true);
        }
        else
        {
            GameObject GoChild = this.gameObject.transform.GetChild(2).gameObject;
            GoChild.SetActive(false);
        }
    }
    IEnumerator LooseDetectionLevel()
    {
        yield return new WaitForSeconds(FTimeWithoutLooseDetection);
        BLooseDetectLevel = true;
    }

    //LA FIN DU NIVEAU
    private void EndGame(bool hasWon)
    {
        bGameIsPaused = true;
        PauseGame();
        PlayerData data = menuManager.gameObject.GetComponent<PlayerData>();
        GameObject ScoringGo = menuManager.gameObject.transform.GetChild(2).gameObject;
        ScoringGo.SetActive(true);
        TMP_Text textScoring = ScoringGo.transform.GetChild(0).gameObject.transform.GetChild(0).gameObject.GetComponent<TMP_Text>();
        TMP_Text textTitle = ScoringGo.transform.GetChild(0).gameObject.transform.GetChild(1).gameObject.GetComponent<TMP_Text>();
        TMP_Text textButton = ScoringGo.transform.GetChild(0).gameObject.transform.GetChild(2).gameObject.transform.GetChild(2).gameObject.transform.GetChild(0).gameObject.GetComponent<TMP_Text>();
        if (hasWon)
        {
            textScoring.text = "Your score is : " + FScore.ToString();
            textTitle.text = "Congratulations!";
            textButton.text = "Save";
            UnityEngine.UI.Button btn = menuManager.gameObject.transform.GetChild(2).gameObject.transform.GetChild(0).gameObject.transform.GetChild(2).gameObject.transform.GetChild(2).gameObject.GetComponent<UnityEngine.UI.Button>();
            btn.onClick.AddListener(() => data.SaveGame());
            PlayerDataUpdate(data);
        }
        else
        {
            textScoring.text = "Your score could have been higher than : " + FScore.ToString();
            textTitle.text = "You've been detected...";
            textButton.text = "Replay";
            UnityEngine.UI.Button btn = menuManager.gameObject.transform.GetChild(2).gameObject.transform.GetChild(0).gameObject.transform.GetChild(2).gameObject.transform.GetChild(2).gameObject.GetComponent<UnityEngine.UI.Button>();
            btn.onClick.AddListener(() => menuManager.LoadScene(SceneManager.GetActiveScene().name));
        }
    }
    private void PlayerDataUpdate(PlayerData data)
    {
        data.iScorePerLvPlayerl[data.iLevelPlayer] = Convert.ToInt32(FScore);
        data.iLevelPlayer += 1;
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
        if (isConnected == bIsOnComputer)
        {
            bIsOnComputer = !isConnected;

            if (!bIsOnComputer)
            {
                Debug.Log("Controller connected!");
            }
            else
            {
                Debug.Log("No controllers connected!");
            }
        }
    }
}
