using UnityEngine;
using UnityEngine.Splines;
using System.Collections.Generic;
using Unity.Mathematics;

public class MultiObjectSplineMover : MonoBehaviour
{
    [Tooltip("Reference to the SplineContainer component.")]
    public SplineContainer splineContainer;

    [Tooltip("List of objects to move along the spline.")]
    public List<Transform> objectsToMove;

    [Tooltip("Movement speed in units per second.")]
    public float speed = 5f;

    private float[] progress; // Normalized progress [0..1] for each object
    private float totalLength;

    void Start()
    {
        if (splineContainer == null)
        {
            Debug.LogError("SplineContainer reference is missing.");
            enabled = false;
            return;
        }

        if (objectsToMove == null || objectsToMove.Count == 0)
        {
            Debug.LogError("No objects assigned to move along the spline.");
            enabled = false;
            return;
        }

        totalLength = splineContainer.CalculateLength();

        // Initialize progress array
        int count = objectsToMove.Count;
        progress = new float[count];

        for (int i = 0; i < count; i++)
        {
            Transform obj = objectsToMove[i];
            if (obj == null)
                continue;

            // Convert object's world position to spline's local space
            Vector3 localPos = splineContainer.transform.InverseTransformPoint(obj.position);

            // Find the closest point on the spline
            float3 nearestPoint;
            float t;
            SplineUtility.GetNearestPoint(splineContainer.Spline, localPos, out nearestPoint, out t);

            progress[i] = t;
        }
    }

    void Update()
    {
        for (int i = 0; i < objectsToMove.Count; i++)
        {
            Transform obj = objectsToMove[i];
            if (obj == null)
                continue;

            // Advance progress
            float distanceThisFrame = speed * Time.deltaTime;
            progress[i] += distanceThisFrame / totalLength;

            if (progress[i] >= 1f)
            {
                // Teleport back to start
                progress[i] = 0f;
                obj.position = splineContainer.EvaluatePosition(0f);
                //Obj.rotation = splineContainer.EvaluateOrientation(0f);
            }
            else
            {
                // Move along the spline
                obj.position = splineContainer.EvaluatePosition(progress[i]);
                //obj.rotation = splineContainer.EvaluateOrientation(progress[i]);
            }
        }
    }
}