using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.VisualScripting;
using UnityEngine;

public class SC_FieldOfView : MonoBehaviour
{
    public float FRadius;
    [Range(0,360)]
    public float FAngle;

    public GameObject GOPlayerRef;
    [SerializeField] private GameObject Go_vfx_detected;
    [SerializeField] private GameObject Go_vfx_disable;
    [SerializeField] private GameObject Go_vfx_coneVision;
    [SerializeField] private GameObject Go_vfx_Suspicious;

    private ParticleSystem PS_detected;
    private ParticleSystem PS_Suspicious;

    public LayerMask LMtargetMask;
    public LayerMask LMObstructionMask;
    public bool BCanSee;
    public bool bSeenOnce;
    public bool bHasHeard = false;
    public bool bIsDisabled = false;
    public float minRotation = -90f;  
    public float maxRotation = 45f;   
    public float rotationStep = 45f;

    private Vector3 vectLastRot;

    private float currentRotation;    
    private bool isReversing = false;
    public int i_EnnemyBeat = 0;
    public GameObject goBaitHearing;


    private void Start()
    {
        if (GOPlayerRef == null)
        {
            GOPlayerRef = GameObject.FindGameObjectWithTag("Player");
        }
        PS_detected = Go_vfx_detected.transform.GetChild(0).gameObject.GetComponent<ParticleSystem>();
        PS_Suspicious = Go_vfx_Suspicious.transform.GetChild(0).gameObject.GetComponent<ParticleSystem>();
        StartCoroutine(FOVRoutine());
        currentRotation = minRotation;
        transform.eulerAngles = new Vector3(0, currentRotation, 0);
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
            transform.eulerAngles = vectLastRot;
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

    public void EnemieRotation()
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
}
