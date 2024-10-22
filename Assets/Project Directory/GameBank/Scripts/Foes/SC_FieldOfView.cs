using System.Collections;
using System.Collections.Generic;
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
    public float minRotation = -90f;  
    public float maxRotation = 45f;   
    public float rotationStep = 45f;  

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
                BCanSee = true;
                }
                else
                {
                BCanSee = false;
                }

            }
            else
            {
                BCanSee = false;
            }
        }
        else if(BCanSee == true)
        {
            BCanSee = false;
        }

    }
    
    void Update()
    {
        
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
    }
}
