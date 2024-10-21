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
    bool BWait = true;
    bool BBad = false;
    bool BGood = false;
    bool BPerfect = false;

    public GameObject GOUiBad;
    public GameObject GOUiGood;
    public GameObject GOUiPerfect;

    float FScore;
    public TMP_Text TMPScore;

    GameObject newActiveUI = null;
    public GameObject UI_JoystickH;
    public GameObject UI_JoystickHD;
    public GameObject UI_JoystickHG;
    public GameObject UI_JoystickG;
    public GameObject UI_JoystickD;
    public GameObject UI_JoystickC;
    public GameObject UI_JoystickB;
    public GameObject UI_JoystickBD;
    public GameObject UI_JoystickBG;

    private float[] angles = { -135f, -90f, -45f, 0f, 45f, 90f, 135f, 180f };
    private int currentAngleIndex = 3;


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
        FBPS = 60/FBPM;
        FZoneBadTiming = FBadTiming/2;
        FZoneGoodTiming = FGoodTiming/2;
        FZonePerfectTiming = FPerfectTiming/2;
        FWaitTime = FBPS - FZoneBadTiming;
        StartCoroutine(wait());
    }

    IEnumerator wait()
    {
        yield return new WaitForSeconds(FWaitTime);
        BWait = false;
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
        StartCoroutine(wait());
        yield return new WaitForSeconds(FZonePerfectTiming/2);
        BPerfect = false;
    }

    void Update()
    {
        
        TMPScore.SetText(FScore.ToString());

        
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
                UI_JoystickG.SetActive(true); // Gauche
                UI_JoystickBG.SetActive(false);
                UI_JoystickHG.SetActive(false);
                UI_JoystickD.SetActive(false);
                UI_JoystickBD.SetActive(false);
                UI_JoystickHD.SetActive(false);
                UI_JoystickB.SetActive(false);
                UI_JoystickH.SetActive(false);
                UI_JoystickC.SetActive(false);
            
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1)
            {
                currentAngleIndex = 5;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UI_JoystickD.SetActive(true); // Droite
                UI_JoystickG.SetActive(false);
                UI_JoystickBG.SetActive(false);
                UI_JoystickHG.SetActive(false);
                UI_JoystickBD.SetActive(false);
                UI_JoystickHD.SetActive(false);
                UI_JoystickB.SetActive(false);
                UI_JoystickH.SetActive(false);
                UI_JoystickC.SetActive(false);
            }
        }
        else if (Mathf.Abs(lastMoveDirection.z) > tolerance && Mathf.Abs(lastMoveDirection.x) <= tolerance)
        {
            // Mouvement haut ou bas
            if (Mathf.Sign(lastMoveDirection.z) == 1)
            {   
                currentAngleIndex = 3;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UI_JoystickH.SetActive(true); // Haut
                UI_JoystickG.SetActive(false);
                UI_JoystickBG.SetActive(false);
                UI_JoystickHG.SetActive(false);
                UI_JoystickD.SetActive(false);
                UI_JoystickBD.SetActive(false);
                UI_JoystickHD.SetActive(false);
                UI_JoystickB.SetActive(false);
                UI_JoystickC.SetActive(false);
            }
            else if (Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 7;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UI_JoystickB.SetActive(true); // Bas
                UI_JoystickG.SetActive(false);
                UI_JoystickBG.SetActive(false);
                UI_JoystickHG.SetActive(false);
                UI_JoystickD.SetActive(false);
                UI_JoystickBD.SetActive(false);
                UI_JoystickHD.SetActive(false);
                UI_JoystickH.SetActive(false);
                UI_JoystickC.SetActive(false);
            }
        }
        else if (Mathf.Abs(lastMoveDirection.x) > tolerance && Mathf.Abs(lastMoveDirection.z) > tolerance)
        {
            // Mouvement diagonal
            if (Mathf.Sign(lastMoveDirection.x) == -1 && Mathf.Sign(lastMoveDirection.z) == 1)
            {
                currentAngleIndex = 2;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UI_JoystickHG.SetActive(true); // HautGauche
                UI_JoystickG.SetActive(false);
                UI_JoystickBG.SetActive(false);
                UI_JoystickD.SetActive(false);
                UI_JoystickBD.SetActive(false);
                UI_JoystickHD.SetActive(false);
                UI_JoystickB.SetActive(false);
                UI_JoystickH.SetActive(false);
                UI_JoystickC.SetActive(false);
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1 && Mathf.Sign(lastMoveDirection.z) == 1)
            {
                currentAngleIndex = 4;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UI_JoystickHD.SetActive(true); // Haut-Droite
                UI_JoystickG.SetActive(false);
                UI_JoystickBG.SetActive(false);
                UI_JoystickHG.SetActive(false);
                UI_JoystickD.SetActive(false);
                UI_JoystickBD.SetActive(false);
                UI_JoystickB.SetActive(false);
                UI_JoystickH.SetActive(false);
                UI_JoystickC.SetActive(false);
            }
            else if (Mathf.Sign(lastMoveDirection.x) == -1 && Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 0;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UI_JoystickBG.SetActive(true); // Bas Gauche
                UI_JoystickG.SetActive(false);
                UI_JoystickHG.SetActive(false);
                UI_JoystickD.SetActive(false);
                UI_JoystickBD.SetActive(false);
                UI_JoystickHD.SetActive(false);
                UI_JoystickB.SetActive(false);
                UI_JoystickH.SetActive(false);
                UI_JoystickC.SetActive(false);
            }
            else if (Mathf.Sign(lastMoveDirection.x) == 1 && Mathf.Sign(lastMoveDirection.z) == -1)
            {
                currentAngleIndex = 6;
                PlayerCapsule.transform.rotation = Quaternion.Euler(0, angles[currentAngleIndex], 0);
                UI_JoystickBD.SetActive(true); // Bas Droite
                UI_JoystickG.SetActive(false);
                UI_JoystickBG.SetActive(false);
                UI_JoystickHG.SetActive(false);
                UI_JoystickD.SetActive(false);
                UI_JoystickHD.SetActive(false);
                UI_JoystickB.SetActive(false);
                UI_JoystickH.SetActive(false);
                UI_JoystickC.SetActive(false);
            }
        }
    }
}
