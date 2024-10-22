using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using TMPro;

public class SC_Player : MonoBehaviour
{
    PlayerControl control;
    Vector2 move;
    Vector3 lastMoveDirection = Vector3.zero;
    public GameObject PlayerCapsule;

    float tolerance = 0.5f;
    bool canMove = true;

    public float FBPM;
    float FBPS;

    public float FBadTiming;
    float FZoneBadTiming;
    public float FGoodTiming;
    float FZoneGoodTiming;
    public float FPerfectTiming;
    float FZonePerfectTiming;
    float FWaitTime;
    bool BBad = false;
    bool BGood = false;
    bool BPerfect = false;

    public GameObject GOUiBad;
    public GameObject GOUiGood;
    public GameObject GOUiPerfect;

    float FScore;
    public TMP_Text TMPScore;
    public GameObject UI_JoystickH;
    public GameObject UI_JoystickHD;
    public GameObject UI_JoystickHG;
    public GameObject UI_JoystickG;
    public GameObject UI_JoystickD;
    public GameObject UI_JoystickC;
    public GameObject UI_JoystickB;
    public GameObject UI_JoystickBD;
    public GameObject UI_JoystickBG;

    public float FDetectionRate = 2f;
    private float FDetectionLevel;
    private SC_FieldOfView[] allEnemies;
    public float FTimeWithoutLooseDetection = 5f;
    private bool BLooseDetectLevel;
    public TMP_Text TMPDetectLevel;
    bool BisDetectedByAnyEnemy = false;


    private float[] angles = { -135f, -90f, -45f, 0f, 45f, 90f, 135f, 180f };
    private int currentAngleIndex = 3;

    public float taggingRange = 1f;
    public Material taggedMaterial; 
    private RaycastHit hitInfo; 


    GameObject[] Enemies1;


    void OnEnable()
    {
        control.GamePlay.Enable();
    }

    void OnDisable()
    {
        control.GamePlay.Disable();
    }

    void Awake()
    {
        control = new PlayerControl();
    }

    void Start()
    {
        Enemies1 = GameObject.FindGameObjectsWithTag("Enemies 1");
        allEnemies = FindObjectsOfType<SC_FieldOfView>();
        FBPS = 60/FBPM;
        FZoneBadTiming = FBadTiming/2;
        FZoneGoodTiming = FGoodTiming/2;
        FZonePerfectTiming = FPerfectTiming/2;
        FWaitTime = FBPS - FZoneBadTiming;
        StartCoroutine(wait());
        FDetectionRate = 1f;
    }

    IEnumerator wait()
    {
        RotationEnemies();
        yield return new WaitForSeconds(FWaitTime);
        StartCoroutine(bad());
    }

    IEnumerator bad()
    {
        canMove = true;
        BBad = true;
        yield return new WaitForSeconds(FZoneBadTiming);
        BBad = false;
        StartCoroutine(good());
        yield return new WaitForSeconds(FZoneGoodTiming + FZonePerfectTiming + FZoneGoodTiming);
        BBad = true;
        yield return new WaitForSeconds(FZoneBadTiming);
        BBad = false;
        canMove = false;
    }

    IEnumerator good()
    {
        BGood = true;
        yield return new WaitForSeconds(FZoneGoodTiming);
        BGood = false;
        StartCoroutine(perfect());
        yield return new WaitForSeconds(FZonePerfectTiming);
        BGood = true;
        yield return new WaitForSeconds(FZoneGoodTiming);
        BGood = false;
    }

    IEnumerator perfect()
    {
        BPerfect = true;
        yield return new WaitForSeconds(FZonePerfectTiming/2);
        if(BisDetectedByAnyEnemy)
        {
            FDetectionLevel += 30f;
        }
        StartCoroutine(wait());
        yield return new WaitForSeconds(FZonePerfectTiming/2);
        BPerfect = false;
    }

    void Update()
    {
        
        TMPScore.SetText(FScore.ToString());
        TMPDetectLevel.SetText(FDetectionLevel.ToString());

        
        move = control.GamePlay.Orientation.ReadValue<Vector2>();
      
      if (move != Vector2.zero)
        {
        
            Vector3 direction = GetDirectionFromJoystick(move);

            if (direction != Vector3.zero)
            {
                lastMoveDirection = direction;
            }

            UpdateDirectionUI();
        }
        
    
        if (control.GamePlay.Move.triggered && canMove)
        {
            if(BBad == true)
            {
                FScore = FScore + 10f;
            }

            if(BGood == true)
            {
                FScore = FScore + 50f;
            }
            if(BPerfect == true)
            {
                FScore = FScore + 100f;
            }
            Mouvement();
        }


        

        MouvementClavier();
        EnemieDetection();
        Rythme();
        Tagging();
        
    }

    void Tagging()
    {
        if (control.GamePlay.Tagging.triggered)
        {
            if (Physics.Raycast(transform.position, transform.forward, out hitInfo, taggingRange))
            {
                if (hitInfo.transform.CompareTag("Tagging"))
                {
                    Renderer wallRenderer = hitInfo.transform.GetComponent<Renderer>();   
                    wallRenderer.material = taggedMaterial;
                }
            }
        }
    }
    

    void RotationEnemies()
    {
        foreach (SC_FieldOfView enemy in allEnemies)
        {
            enemy.EnemieRotation();
        }
    }

    void Rythme()
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

    void EnemieDetection()
    {
        

        foreach (SC_FieldOfView enemie in allEnemies)
        {
            if (enemie.BCanSee)
            {
                
                BLooseDetectLevel = false;
                BisDetectedByAnyEnemy = true;
            }
            
        }

        if (!BisDetectedByAnyEnemy && !BLooseDetectLevel)
        {
            StartCoroutine(LooseDetectionLevel());
        }

 
        if (BLooseDetectLevel)
        {
            FDetectionLevel -= FDetectionRate * Time.deltaTime;
            FDetectionLevel = Mathf.Max(FDetectionLevel, 0);
        }

        Debug.Log("Niveau de detection : " + FDetectionLevel);
        Debug.Log("detection : " + BLooseDetectLevel);
    }

    IEnumerator LooseDetectionLevel()
    {
        yield return new WaitForSeconds(FTimeWithoutLooseDetection);
        BLooseDetectLevel = true;
    }

    void MouvementClavier()
    {
        if(Input.GetKeyDown(KeyCode.A))
        {
            transform.Translate(Vector3.left, Space.World);
        }
        if(Input.GetKeyDown(KeyCode.W))
        {
            transform.Translate(Vector3.forward, Space.World);
        }
        if(Input.GetKeyDown(KeyCode.D))
        {
            transform.Translate(Vector3.right, Space.World);
        }
        if(Input.GetKeyDown(KeyCode.X))
        {
            transform.Translate(Vector3.back, Space.World);
        }
        if(Input.GetKeyDown(KeyCode.Q))
        {
            transform.position += new Vector3(-1, 0, 1);
        }
        if(Input.GetKeyDown(KeyCode.E))
        {
            transform.position += new Vector3(1, 0, 1);
        }
        if(Input.GetKeyDown(KeyCode.C))
        {
            transform.position += new Vector3(1, 0, -1);
        }
        if(Input.GetKeyDown(KeyCode.Z))
        {
            transform.position += new Vector3(-1, 0, -1);
        }
    }

    Vector3 GetDirectionFromJoystick(Vector2 moveInput)
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

    void Mouvement()
    {
        Move(lastMoveDirection);
    }

    void Move(Vector3 direction)
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


    void UpdateDirectionUI()
    {
        if (Mathf.Abs(lastMoveDirection.x) > tolerance && Mathf.Abs(lastMoveDirection.z) <= tolerance)
        {
            // Mouvement gauche ou droite
            if (Mathf.Sign(lastMoveDirection.x) == -1)
            {
                currentAngleIndex = 1;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_JoystickG.SetActive(true); // Gauche
                
            
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1)
            {
                currentAngleIndex = 5;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_JoystickD.SetActive(true); // Droite
            
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
                UI_JoystickH.SetActive(true); // Haut
              
            }
            else if (Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 7;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_JoystickB.SetActive(true); // Bas
             
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
                UI_JoystickHG.SetActive(true); // HautGauche
              
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1 && Mathf.Sign(lastMoveDirection.z) == 1)
            {
                currentAngleIndex = 4;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_JoystickHD.SetActive(true); // Haut-Droite
                
            }
            else if (Mathf.Sign(lastMoveDirection.x) == -1 && Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 0;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_JoystickBG.SetActive(true); // Bas Gauche
                
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1 && Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 6;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UIFlase();
                UI_JoystickBD.SetActive(true); // Bas Droite
              
            }
        }
    }

    void UIFlase()
    {
        UI_JoystickG.SetActive(false);
        UI_JoystickBG.SetActive(false);
        UI_JoystickHG.SetActive(false);
        UI_JoystickD.SetActive(false);
        UI_JoystickBD.SetActive(false);
        UI_JoystickHD.SetActive(false);
        UI_JoystickB.SetActive(false);
        UI_JoystickH.SetActive(false);
        UI_JoystickC.SetActive(false);
    }
}
