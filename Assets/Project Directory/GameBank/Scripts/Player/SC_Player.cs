using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using TMPro;
using System.Globalization;
using System;
using Unity.VisualScripting;

public class SC_Player : MonoBehaviour
{
    PlayerControl control;
    Vector2 move;
    Vector3 lastMoveDirection = Vector3.zero;
    public GameObject PlayerCapsule;
    [SerializeField] private bool bIsOnComputer = false;

    float tolerance = 0.5f;
    bool canMove = true;

    public float FBPM;
    float FBPS;
    private float FSPB;

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
    [SerializeField] private TMP_Text txt_Feedback;

    public GameObject GOUiBad;
    public GameObject GOUiGood;
    public GameObject GOUiPerfect;

    float FScore;
    public TMP_Text TMPScore;
    [Tooltip("0 is H, 1 is HD, 2 is HG, 3 is G, 4 is D, 5 is C, 6 is B, 7 is BD, 8 is BG")] public GameObject[] UI_Joystick;

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
    private RaycastHit[] hitInfo = new RaycastHit[4];
    private Vector3 [] vectTransform = new Vector3 [4];
    private bool bHasMovedOnce = false;
    private bool bIsBaiting = false;

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
        //FBPS = 60/FBPM;
        FBPS = FBPM/60f;
        FSPB = 1f/FBPS;
        FPerfectTiming = 2/14f * FSPB;
        FGoodTiming = 4/14f * FSPB;
        FBadTiming = 6/14f * FSPB;
        FZoneBadTiming = FBadTiming/2;
        FZoneGoodTiming = FGoodTiming/2;
        FZonePerfectTiming = FPerfectTiming/2;
        FWaitTime = FSPB - FZoneBadTiming;
        StartCoroutine(wait());
        FDetectionRate = 1f;
        vectTransform[0] = transform.forward;
        vectTransform[1] = transform.right;
        vectTransform[2] = Vector3.left;
        vectTransform[3] = Vector3.back;
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
        txt_Feedback.text = "";
        txt_Feedback.color = new Color32(0, 0, 0, 0);
        bHasMovedOnce = false;
        yield return new WaitForSeconds(FZoneBadTiming);
        BBad = false;
        StartCoroutine(good());
        yield return new WaitForSeconds(FZoneGoodTiming + FZonePerfectTiming + FZoneGoodTiming);
        BBad = true;
        yield return new WaitForSeconds(FZoneBadTiming);
        BBad = false;
        canMove = false;
        if(BBad == false && BGood  == false && BPerfect  == false && bHasMovedOnce == false)
        {
            CheckForward();
            txt_Feedback.text = "Miss";
            txt_Feedback.color = new Color32(255,0,0, 255);
        }
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
        int iDetectionLevel = Mathf.RoundToInt(FDetectionLevel);
        TMPDetectLevel.SetText(iDetectionLevel.ToString());


        if (bIsOnComputer == false)
        {
            move = control.GamePlay.Orientation.ReadValue<Vector2>();
        }
        else if(bIsOnComputer == true)
        {
            move = new Vector2(1, 0);
        }
      
        if (move != Vector2.zero)
        {
            Vector3 direction = Vector3.forward;
            if (bIsOnComputer == false)
            {
                direction = GetDirectionFromJoystick(move);
            }
            else if (bIsOnComputer == true)
            {
                direction = GetDirectionFromClavier();
            }
            if (direction != Vector3.zero)
            {
                lastMoveDirection = direction;
            }
            UpdateDirectionUI();
        }


        if ((control.GamePlay.Move.triggered && canMove && bIsOnComputer == false) || (Input.GetButtonDown("Jump") && canMove && bIsOnComputer == true))
        {
            if(BBad == true)
            {
                FScore = FScore + 10f;
                txt_Feedback.text = "Bad";
                txt_Feedback.color = new Color32(255, 0, 255, 255);
            }
            else if(BGood == true)
            {
                FScore = FScore + 50f;
                txt_Feedback.text = "Good";
                txt_Feedback.color = new Color32(0, 0, 255, 255);
            }
            else if(BPerfect == true)
            {
                FScore = FScore + 100f;
                txt_Feedback.text = "Perfect!";
                txt_Feedback.color = new Color32(0, 255, 255, 255);
            }
            CheckForward();
        }
        EnemieDetection();
        Rythme();
        
    }

    public void Baiting()
    {
        bIsBaiting = true;

        //Lignes de 3 à 5 cubes éloignés du joueur sont en surbrillance devant lui
        //S'update en fonction de son orientation
        //Une flèche en arc de cercle va du joueur à la case en question en fonction du beat

        //Si le joueur appuie sur sa touche pour lancer le projectile,
        //En fonction du good, perfect ou bad, le projectil se lance sur la case correspondante entre 3 et 5
        //Le joueur gagne des points en fonction de sa précision sur le tempo
        //Le bait a été instancié sur la case en question : cette instanciation a un nombre de tempo de vie
        //Enclanche la detection de l'ennemi => EnnemiHasHeardSomething qui est dans l'objet instantié
        //Le joueur a fait son mouvement dans le tempo
        //Il n'y a plus les feedback de lancée

        //Si le joueur n'appuie pas sur la touche
        //Le joueur miss et le bait est lancé à 2 cases de lui dans l'orientation qu'il avait
        //Le joueur ne gagne pas de points
        //Le bait a été instancié sur la case en question : cette instanciation a un nombre de tempo de vie
        // Enclanche la detection de l'ennemi => Ennemi has Heard Somethingqui est dans l'objet instantié
        //Le joueur a fait son mouvement dans le tempo
        //Il n'y a plus les feedback de lancée
    }

    private void CheckForward()
    {
        for (int i = 0; i < 4; i++)
        {
            if (Physics.Raycast(transform.position, vectTransform[i], out hitInfo[i], taggingRange)) //qqc est devant le joueur
            {
                if (hitInfo[i].transform.CompareTag("Tagging")) //c'est un mur à tagger
                {
                    Renderer wallRenderer = hitInfo[i].transform.GetComponent<Renderer>();
                    GameObject wallTagged = hitInfo[i].transform.gameObject;
                    wallRenderer.material = taggedMaterial; //le joueur tag
                    wallTagged.tag = "Wall";
                    bHasMovedOnce = true;
                    break;
                }
                else if (hitInfo[i].transform.CompareTag("Wall"))//ce n'est pas un mur à tagger
                {
                    if (i != 3)
                    {
                        if (Physics.Raycast(transform.position, vectTransform[i + 1], out hitInfo[i + 1], taggingRange)) //qqc obstrue le mouvement de glissade
                        {
                            if (hitInfo[i].transform.CompareTag("Wall") || hitInfo[i].transform.CompareTag("Tagging"))
                            {
                                return; //est-ce un mur taggable? Refaire le processus
                            }
                            else //il n'y a rien devant le joueur
                            {
                                Mouvement(i);
                                break;
                            }
                        }
                        else //il n'y a rien à cet endroit alors s'y déplace
                        {
                            Mouvement(i + 1);
                            break;
                        }
                    }
                    else
                    {
                        break;
                    }
                }
                else //il n'y a rien devant le joueur
                {
                    Mouvement(i);
                    break;
                }
            }
            else //il n'y a rien devant le joueur, alors s'y déplace
            {
                Mouvement(i);
                break;
            }
        }
    }
    
    void RotationEnemies()
    {
        foreach (SC_FieldOfView enemy in allEnemies)
        {
            if(enemy.BCanSee)
            {
                enemy.PlayerDetected(this.gameObject);
            }
            else
            {
                enemy.EnemieRotation(); 
            }
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
        int i = 0;
        int y = 0;
        foreach (SC_FieldOfView enemie in allEnemies)
        {
            if (enemie.BCanSee)
            {
                BLooseDetectLevel = false;
                BisDetectedByAnyEnemy = true;
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

        /*if (!BisDetectedByAnyEnemy && !BLooseDetectLevel)
        {
            StartCoroutine(LooseDetectionLevel());
        }*/
 
        if (BLooseDetectLevel)
        {
            FDetectionLevel -= FDetectionRate * Time.deltaTime*2;
            /*int iDetectionLevel = Mathf.RoundToInt(FDetectionLevel);
            FDetectionLevel = Convert.ToSingle(iDetectionLevel);*/
            FDetectionLevel = Mathf.Max(FDetectionLevel, 0);
        }
    }

    IEnumerator LooseDetectionLevel()
    {
        yield return new WaitForSeconds(FTimeWithoutLooseDetection);
        BLooseDetectLevel = true;
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

    private void Mouvement(int i)
    {
        if (i == 0) //devant le player = forward
        {
            Move(lastMoveDirection);
            bHasMovedOnce = true;
            return ;
        }
        else if (i == 1) // a droite du player
        {
            Vector3 newVector = transform.right;
            Move(newVector);
            bHasMovedOnce = true;
            return;
        }
        else if (i == 2) //a gauche du player
        {
            Vector3 newVector = Vector3.left;
            Move(newVector);
            bHasMovedOnce = true;
            return;
        }
        else if(i==3) //derriere le player
        {
            Vector3 newVector =  Vector3.back;
            Move(newVector);
            bHasMovedOnce = true;
            return;
        }
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
}
