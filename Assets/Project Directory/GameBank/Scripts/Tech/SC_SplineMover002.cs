using UnityEngine;
using UnityEngine.Splines;
using System.Collections.Generic;

public class SplineTrainMover_WithSpacing002 : MonoBehaviour
{
    [Header("Spline Settings")]
    public SplineContainer splineContainer;

    [Header("Train Cars")]
    [Tooltip("Index 0 is head; others are wagons in order.")]
    public List<Transform> cars;

    [Header("Movement")]
    public float speed = 5f;                             // units per second

    [Header("Spacing")]
    [Tooltip("Normalized spacing along the spline between consecutive cars (0-1).")]
    [Range(0f, 1f)]
    public float spacing = 0.1f;

    [Header("Pause Settings")]
    public bool usePause = true;
    public float pauseMin = 1f;
    public float pauseMax = 3f;

    [Header("Rotation")]
    public bool applyRotation = true;

    private float totalLength;
    private float headProgress;
    public float[] progress;
    private bool[] isPaused;
    public float[] pauseTimer;
    public float pauseDuration;

    void Start()
    {
        if (splineContainer == null) Debug.LogError("Assign a SplineContainer!", this);
        if (cars == null || cars.Count == 0) Debug.LogError("Assign at least one car!", this);

        totalLength = splineContainer.CalculateLength();
        int n = cars.Count;

        progress = new float[n];
        isPaused = new bool[n];
        pauseTimer = new float[n];

        // Set initial head progress to its nearest point
        headProgress = FindNearestT(cars[0].position);

        // Initialize each car's progress based on uniform spacing
        for (int i = 0; i < n; i++)
        {
            progress[i] = Mathf.Repeat(headProgress - spacing * i, 1f);
            isPaused[i] = false;
            pauseTimer[i] = 0f;
        }

        // Roll initial pause duration for this cycle
        pauseDuration = Random.Range(pauseMin, pauseMax);
    }

    void Update()
    {
        for (int i = 0; i < cars.Count; i++)
        {
            // Advance or pause each car independently
            if (usePause && isPaused[i])
            {
                pauseTimer[i] += Time.deltaTime;
                if (pauseTimer[i] >= pauseDuration)
                {
                    // End pause: teleport to A and reset
                    isPaused[i] = false;
                    pauseTimer[i] = 0f;
                    progress[i] = 0f;
                }
            }
            else
            {
                // Move forward
                progress[i] += speed * Time.deltaTime / totalLength;
            }

            // Clamp and handle reaching B
            if (!isPaused[i] && progress[i] >= 1f)
            {
                // Snap to B and start pause
                progress[i] = 1f;
                if (usePause)
                {
                    isPaused[i] = true;
                    pauseTimer[i] = 0f;
                }
                else
                {
                    // Immediate loop
                    progress[i] = 0f;
                }

                // If this was the last car, reroll pause for next cycle
                if (i == cars.Count - 1)
                {
                    pauseDuration = Random.Range(pauseMin, pauseMax);
                }
            }

            // Update position
            // Position
            Vector3 pos = splineContainer.EvaluatePosition(progress[i]);
            cars[i].position = pos;

            // Tangente directionnelle
            Vector3 tangent = splineContainer.EvaluateTangent(progress[i]);

            // Projeter la tangente sur le plan horizontal pour éviter la rotation en X
            Vector3 flatForward = Vector3.ProjectOnPlane(tangent, Vector3.up).normalized;

            if (applyRotation && flatForward.sqrMagnitude > 0.001f)
            {
                Quaternion rot = Quaternion.LookRotation(flatForward, Vector3.up);
                rot *= Quaternion.Euler(0f, 90f, 0f); // adapte si ton modèle ne regarde pas en Z
                cars[i].rotation = rot;
            }
        }
    }

    // Helper to find normalized t along spline from world position along spline from world position
    float FindNearestT(Vector3 worldPos)
    {
        Vector3 localPos = splineContainer.transform.InverseTransformPoint(worldPos);
        SplineUtility.GetNearestPoint(splineContainer.Spline, localPos, out _, out float t);
        return t;
    }
}