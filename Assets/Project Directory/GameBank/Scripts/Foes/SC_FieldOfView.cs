using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.VisualScripting;
using UnityEngine;

public class SC_FieldOfView : MonoBehaviour
{
    public int i_typeFoe = 1;

    //LE DEPLACEMENT
    [Header("Déplacement")]
    [SerializeField] private Vector3[] posDirections;
    [SerializeField] private int iFirstPos = 0;
    private int iCurrentDirection = 0;

    //LE CONE DE VISION
    [Header("Cone de vision")]
    [Range(0, 8)]
    public float FRadius;
    [Range(0,70)]
    public float FAngle;

    //ROTATION
    [Header("Rotation")]
    [SerializeField] private float minRotation = -90f;
    [SerializeField] private float maxRotation = 45f;
    [SerializeField] private float rotationStep = 45f;

    //GARDE
    private float currentRotation;
    private bool isReversing = false;
    private Vector3 vectLastRot;

    //FEEDBACK SUR ENNEMIE
    [Header("Feedbacks")]
    public GameObject GOPlayerRef;
    [SerializeField] private GameObject Go_vfx_detected;
    [SerializeField] private GameObject Go_vfx_disable;
    [SerializeField] private GameObject Go_vfx_coneVision;
    [SerializeField] private GameObject Go_vfx_Suspicious;
    private ParticleSystem PS_detected;
    private ParticleSystem PS_Suspicious;

    //DETECTION
    [Header("Detection")]
    public LayerMask LMtargetMask;
    public LayerMask LMObstructionMask;
    public int i_EnnemyBeat = 0;
    public GameObject goBaitHearing;

    //ETATS
    [Header("Etats")]
    public bool BCanSee;
    public bool bSeenOnce;
    public bool bHasHeard = false;
    public bool bIsDisabled = false;

    private void Start()
    {
        if (GOPlayerRef == null)
        {
            GOPlayerRef = GameObject.FindGameObjectWithTag("Player");
        }
        PS_detected = Go_vfx_detected.transform.GetChild(0).gameObject.GetComponent<ParticleSystem>();
        PS_Suspicious = Go_vfx_Suspicious.transform.GetChild(0).gameObject.GetComponent<ParticleSystem>();
        StartCoroutine(FOVRoutine());
        if (i_typeFoe == 1) //si l'ennemi est statique
        {
            currentRotation = minRotation;
            transform.eulerAngles = new Vector3(0, currentRotation, 0);
        }
        else
        {
            this.transform.position = posDirections[iFirstPos];
            if (iFirstPos + 1 == posDirections.Length)
            {
                transform.LookAt(new Vector3(posDirections[iFirstPos-1].x, this.transform.position.y, posDirections[iFirstPos-1].z));
                isReversing = true;
                iCurrentDirection = iFirstPos - 1;
            }
            else
            {
                transform.LookAt(new Vector3(posDirections[iFirstPos + 1].x, this.transform.position.y, posDirections[iFirstPos + 1].z));
                isReversing = false;
                iCurrentDirection = iFirstPos + 1;
            }
        }
    }

    private IEnumerator FOVRoutine()
    {
        WaitForSeconds wait = new WaitForSeconds(0.2f);
        
        while(true)
        {
            yield return wait;
            FieldOfViewCheck();
        }
    }
    private void FieldOfViewCheck()
    {
        if (bIsDisabled == false)
        {
            Collider[] rangeChecks = Physics.OverlapSphere(transform.position, FRadius, LMtargetMask);

            if (rangeChecks.Length != 0)
            {
                Transform target = rangeChecks[0].transform;
                Vector3 directionToTarget = (target.position - transform.position).normalized;

                if (Vector3.Angle(transform.forward, directionToTarget) < FAngle / 2)
                {
                    float distanceToTarget = Vector3.Distance(transform.position, target.position);
                    if (!Physics.Raycast(transform.position, directionToTarget, distanceToTarget, LMObstructionMask))
                    {
                        bSeenOnce = true; //vu une fois
                    }
                    else
                    {
                        BCanSee = false; //Ne voit pas
                    }
                }
                else
                {
                    BCanSee = false; //Ne voit pas
                }
            }
            else if (BCanSee == true) //Si le bool est en true alors que c'est faux
            {
                BCanSee = false; //Il ne voit pas
            }
            DetectionChecks();
        }
    }

    IEnumerator NumDetectedVFX(bool bNewDetected, bool isactive)
    {
        if (bNewDetected && !isactive)
        {
            Go_vfx_detected.SetActive(true); 
            PS_detected.Play();
            yield return new WaitForSeconds(0.5f);
            PS_detected.Pause();
        }
        else if(!bNewDetected && isactive)
        {
            Go_vfx_detected.SetActive(false);
            PS_detected.Play();
            yield return new WaitForSeconds(0.5f);
            PS_detected.Stop();
        }
    }
    IEnumerator NumSuspiciousVFX(bool bNewDetected, bool isactive)
    {
        if (bNewDetected && !isactive)
        {
            Go_vfx_Suspicious.SetActive(true);
            PS_Suspicious.Play();
            yield return new WaitForSeconds(0.5f);
            PS_Suspicious.Pause();
        }
        else if (!bNewDetected && isactive)
        {
            Go_vfx_Suspicious.SetActive(false);
            PS_Suspicious.Play();
            yield return new WaitForSeconds(0.5f);
            PS_Suspicious.Stop();
        }
    }

    public void PlayerDetected(GameObject GOPlayer)
    {
        transform.LookAt(GOPlayer.transform);
        if(i_typeFoe == 2) // Si l'ennemi est movible : bouge vers le joueur
        {
            Debug.Log("enemie 2 is watching player");
        }
    }
    public void BaitHeard(GameObject GOBait)
    {
        transform.LookAt(GOBait.transform);
        goBaitHearing = GOBait;
    }
    public void FoeDisabled(bool _isDisable)
    {
        Go_vfx_coneVision.SetActive(!_isDisable);
        Go_vfx_disable.SetActive(_isDisable);
    }
    private void DetectionChecks ()
    {
        if (bIsDisabled)
        {
            Go_vfx_Suspicious.SetActive(false);
            PS_Suspicious.Stop();
            Go_vfx_detected.SetActive(false);
            PS_detected.Stop();
        }
        else if (bSeenOnce)
        {
            BCanSee = true;
            bSeenOnce = false;
            StartCoroutine(NumDetectedVFX(true, Go_vfx_detected.activeInHierarchy));
            Go_vfx_Suspicious.SetActive(false);
            PS_Suspicious.Stop();
        }
        if(BCanSee == false && bHasHeard == false)
        {
            if (i_typeFoe == 1)
            {
                transform.eulerAngles = vectLastRot;
            }
            else
            {
                transform.LookAt(new Vector3(posDirections[iCurrentDirection].x, this.transform.position.y, posDirections[iCurrentDirection].z));
            }
            StartCoroutine(NumDetectedVFX(false, Go_vfx_detected.activeInHierarchy));
        }
        if(bHasHeard==true)
        {
            StartCoroutine(NumSuspiciousVFX(true, Go_vfx_Suspicious.activeInHierarchy));
        }
        else
        {
            StartCoroutine(NumSuspiciousVFX(false, Go_vfx_Suspicious.activeInHierarchy));
        }
    }

    public void EnemieRotation(float ftime)
    {
        if (i_typeFoe ==1) //Si l'ennemi est statique, ne bouge que sa rotation
        {
            if (!isReversing && currentRotation >= maxRotation)
            {
                isReversing = true;
            }
            else if (isReversing && currentRotation <= minRotation)
            {
                isReversing = false;
            }

            if (isReversing)
            {
                currentRotation -= rotationStep;
            }
            else
            {
                currentRotation += rotationStep;
            }
            currentRotation = Mathf.Clamp(currentRotation, minRotation, maxRotation);
            transform.eulerAngles = new Vector3(0, currentRotation, 0);
            vectLastRot = transform.eulerAngles;
        }
        else if(i_typeFoe == 2)//Si l'ennemi suit un chemin, est movible
        {
            if(!isReversing && iCurrentDirection + 1 != posDirections.Length && posDirections.Length != 2) //Si ça ne reverse pas et que la prochaine direction existe
            {
                if (this.transform.position.x != posDirections[iCurrentDirection].x || this.transform.position.z != posDirections[iCurrentDirection].z) //Si l'ennemi n'est pas déjà à la position de nouvelle direction
                {
                    Vector3 newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection + 1].x - this.transform.position.x, 0, posDirections[iCurrentDirection + 1].z - this.transform.position.z).normalized;
                    this.transform.position = newPos;
                }
                else //Le joueur est à la position de prochaine direction
                {
                    Vector3 newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection + 1].x - this.transform.position.x, 0, posDirections[iCurrentDirection + 1].z - this.transform.position.z).normalized;
                    this.transform.DOMove(newPos, ftime, false).SetAutoKill(true);
                    iCurrentDirection = iCurrentDirection + 1;
                    transform.LookAt(new Vector3(posDirections[iCurrentDirection].x, this.transform.position.y, posDirections[iCurrentDirection].z));
                }
            }
            else if(!isReversing && (iCurrentDirection + 1 == posDirections.Length || posDirections.Length == 2)) //Si ça ne reverse pas et que la prochaine direction n'existe pas ou aller-retour
            {
                if (this.transform.position.x != posDirections[iCurrentDirection].x || this.transform.position.z != posDirections[iCurrentDirection].z) //Si l'ennemi n'est pas déjà à la position de nouvelle direction
                {
                    Vector3 newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection].x - this.transform.position.x, 0, posDirections[iCurrentDirection].z - this.transform.position.z).normalized;
                    this.transform.DOMove(newPos, ftime, false).SetAutoKill(true);
                }
                else //Le joueur est à la position de prochaine direction
                {
                    Vector3 newPos = new Vector3(0,0,0);
                    if (posDirections.Length != 2)
                    {
                        newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection +1].x - this.transform.position.x, 0, posDirections[iCurrentDirection +1].z - this.transform.position.z).normalized;
                    }
                    else
                    {
                        newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection].x - this.transform.position.x, 0, posDirections[iCurrentDirection].z - this.transform.position.z).normalized;
                    }
                    this.transform.DOMove(newPos, ftime, false).SetAutoKill(true);
                    if (iCurrentDirection != 0)
                    {
                        iCurrentDirection = iCurrentDirection - 1;
                    }
                    isReversing = true;
                    transform.LookAt(new Vector3(posDirections[iCurrentDirection].x, this.transform.position.y, posDirections[iCurrentDirection].z));
                }
            }
            else if(isReversing && iCurrentDirection -1 != -1 && posDirections.Length != 2)//Si ça se reverse et que la prochaine direction existe
            {
                if (this.transform.position.x != posDirections[iCurrentDirection].x || this.transform.position.z != posDirections[iCurrentDirection].z) //Si l'ennemi n'est pas déjà à la position de nouvelle direction
                {
                    Vector3 newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection - 1].x - this.transform.position.x, 0, posDirections[iCurrentDirection - 1].z - this.transform.position.z).normalized;
                    this.transform.DOMove(newPos, ftime, false).SetAutoKill(true);
                }
                else //Le joueur est à la position de prochaine direction
                {
                    Vector3 newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection - 1].x - this.transform.position.x, 0, posDirections[iCurrentDirection - 1].z - this.transform.position.z).normalized;
                    this.transform.DOMove(newPos, ftime, false).SetAutoKill(true);
                    iCurrentDirection = iCurrentDirection - 1;
                    isReversing = false;
                    transform.LookAt(new Vector3(posDirections[iCurrentDirection].x, this.transform.position.y, posDirections[iCurrentDirection].z));
                }
            }
            else if (isReversing && (iCurrentDirection -1 == -1 || posDirections.Length == 2))//Si ça se reverse et que la prochaine direction n'xiste pas ou aller-retour
            {
                if (this.transform.position.x != posDirections[iCurrentDirection].x || this.transform.position.z != posDirections[iCurrentDirection ].z) //Si l'ennemi n'est pas déjà à la position de nouvelle direction
                {
                    Vector3 newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection].x - this.transform.position.x, 0, posDirections[iCurrentDirection].z - this.transform.position.z).normalized;
                    this.transform.DOMove(newPos, ftime, false).SetAutoKill(true);
                }
                else //Le joueur est à la position de prochaine direction
                {
                    Vector3 newPos = new Vector3(0, 0, 0);
                    if (posDirections.Length != 2)
                    {
                        newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection + 1].x - this.transform.position.x, 0, posDirections[iCurrentDirection + 1].z - this.transform.position.z).normalized;
                    }
                    else
                    {
                        newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection].x - this.transform.position.x, 0, posDirections[iCurrentDirection].z - this.transform.position.z).normalized;
                    }
                    this.transform.DOMove(newPos, ftime, false).SetAutoKill(true);
                    iCurrentDirection = iCurrentDirection + 1;
                    isReversing = false;
                    transform.LookAt(new Vector3(posDirections[iCurrentDirection].x, this.transform.position.y, posDirections[iCurrentDirection].z));
                }
            }
        }
    }
}
