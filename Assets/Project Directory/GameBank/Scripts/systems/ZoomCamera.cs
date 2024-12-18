using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ZoomCamera : MonoBehaviour
{
   [Header("Zoom Settings")]
    [Tooltip("Vitesse de zoom de la caméra.")]
    public float zoomSpeed = 10f;

    [Tooltip("Distance minimale du zoom.")]
    public float minZoom = 5f;

    [Tooltip("Distance maximale du zoom.")]
    public float maxZoom = 50f;

    private Camera cameraComponent;

    void Start()
    {
        // Récupère le composant Camera attaché à l'objet
        cameraComponent = GetComponent<Camera>();

        if (cameraComponent == null)
        {
            Debug.LogError("Aucun composant Camera n'est attaché à cet objet. Veuillez ajouter une caméra.");
        }
    }

    void Update()
    {
        if (cameraComponent != null)
        {
            // Récupère l'entrée de la molette de la souris
            float scrollInput = Input.GetAxis("Mouse ScrollWheel");

            if (scrollInput != 0)
            {
                if (cameraComponent.orthographic)
                {
                    // Zoom pour une caméra orthographique
                    float newSize = cameraComponent.orthographicSize - scrollInput * zoomSpeed;
                    cameraComponent.orthographicSize = Mathf.Clamp(newSize, minZoom, maxZoom);
                }
                else
                {
                    // Zoom pour une caméra en perspective
                    float newZoom = cameraComponent.fieldOfView - scrollInput * zoomSpeed;
                    cameraComponent.fieldOfView = Mathf.Clamp(newZoom, minZoom, maxZoom);
                }
            }
        }
    }
}
