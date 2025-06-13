using UnityEngine;
using UnityEngine.Splines;
using System.Collections.Generic;
using Unity.Collections.LowLevel.Unsafe;
using Unity.VisualScripting;
using TMPro;
using UnityEngine.EventSystems;

public class SplineTrainMover_WithSpacing : MonoBehaviour
{
    public EventSystem _eventSystem;
    [Header("Spline Settings")]
    public SplineContainer splineContainer;

    [Header("Train Cars")]
    [Tooltip("Index 0 is head; others are wagons in order.")]
    public List<Transform> cars;
    public Renderer[] renderCars;

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

    private float totalLength;
    private float headProgress;
    public float[] progress;
    private bool[] isPaused;
    public float[] pauseTimer;
    public float pauseDuration;
    public bool bStop = false;
    [SerializeField]private CanvasGroup CgButtons;
    public CanvasGroup cgCredits;
    public CanvasGroup[] cgChildrenCredits;
    public sc_textChange[] txtChildrenCredits;
    public int iCredits = 0;
    public bool bOnce = false;

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
        if(!bStop)
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
                        if (CgButtons.alpha == 1f)
                        {
                            bStop = true;
                        }
                        else
                        {
                            bStop = false;
                        }
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
                cars[i].position = splineContainer.EvaluatePosition(progress[i]);
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