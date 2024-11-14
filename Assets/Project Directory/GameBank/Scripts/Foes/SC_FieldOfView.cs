using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class SC_FieldOfView : MonoBehaviour
{
    public float FRadius;
    [Range(0,360)]
    public float FAngle;

    public GameObject GOPlayerRef;

    public LayerMask LMtargetMask;
    public LayerMask LMObstructionMask;

    public bool BCanSee;
    public bool bSeenOnce;
    public float minRotation = -90f;  
    public float maxRotation = 45f;   
    public float rotationStep = 45f;

    private Vector3 vectLastRot;

    private float currentRotation;    
    private bool isReversing = false; 

    
    private void Start()
    {
        GOPlayerRef = GameObject.FindGameObjectWithTag("Player");
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
        Collider[] rangeChecks = Physics.OverlapSphere(transform.position, FRadius, LMtargetMask);

        if(rangeChecks.Length != 0)
        {
            Transform target = rangeChecks[0].transform;
            Vector3 directionToTarget = (target.position - transform.position).normalized;

            if(Vector3.Angle(transform.forward, directionToTarget) < FAngle /2 )
            {
                float distanceToTarget = Vector3.Distance(transform.position, target.position);
                if(!Physics.Raycast(transform.position, directionToTarget, distanceToTarget, LMObstructionMask))
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
        else if(BCanSee == true) //Si le bool est en true alors que c'est faux
        {
            BCanSee = false; //Il ne voit pas
        }
        DetectionChecks();
    }

    public void PlayerDetected(GameObject GOPlayer)
    {
        Vector3 vectToPlayer = GOPlayer.transform.position - this.transform.position;
        vectToPlayer = vectToPlayer.normalized;
        Vector3 vectFor = Vector3.forward.normalized;
        float crossProduct = (vectToPlayer.x * vectFor.z) - (vectToPlayer.z * vectFor.x);
        if (crossProduct < 0) //si le joueur est à gauche du vecteur de l'ennemi
        {
            transform.eulerAngles = new Vector3(0, transform.eulerAngles.y - 20f, 0);
        }
        if (crossProduct > 0) //si le joueur est à droite du vecteur de l'ennemi
        {
            transform.eulerAngles = new Vector3(0, transform.eulerAngles.y + 20f, 0);
        }
    }

    public void DetectionChecks ()
    {
        if (bSeenOnce)
        {
            BCanSee = true;
            bSeenOnce = false;
        }
        if(BCanSee == false)
        {
            transform.eulerAngles = vectLastRot;
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
