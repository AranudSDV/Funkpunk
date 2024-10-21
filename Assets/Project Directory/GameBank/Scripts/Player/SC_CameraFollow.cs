using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SC_CameraFollow : MonoBehaviour
{
    public Transform target;  
    public Vector3 offset;    
    public float followSpeed = 5f;  
    
    void Start()
    {
        
    }

    
    void Update()
    {
        Vector3 targetPosition = target.position + offset;
        transform.position = Vector3.Lerp(transform.position, targetPosition, followSpeed * Time.deltaTime);
    }
}
