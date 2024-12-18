using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotationDiorama : MonoBehaviour
{
    [Header("Rotation Settings")]
    [Tooltip("Vitesse de rotation de l'objet.")]
    public float rotationSpeed = 5f;

    void Update()
    {
        // Effectue une rotation sur l'axe X uniquement
        transform.Rotate(Vector3.right * rotationSpeed * Time.deltaTime);
    }
}
