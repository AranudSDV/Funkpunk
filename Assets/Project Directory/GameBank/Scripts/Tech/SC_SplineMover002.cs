using UnityEngine;
using UnityEngine.Splines;
using System.Collections.Generic;

public class SplineTrainMover : MonoBehaviour
{
    [Header("Spline Settings")]
    public SplineContainer splineContainer;

    [Header("Objects on the spline")]
    [Tooltip("Index 0 is head; others follow in order")]
    public List<Transform> cars;

    [Header("Movement")]
    public float speed = 5f;               // units per second

    [Header("Pause Settings")]
    public bool usePause = true;
    public float pauseMin = 1f;
    public float pauseMax = 3f;

    [Header("Rotation")]
    public bool applyRotation = true;

    // internals
    private float totalLength;
    private float headProgress;            // t de la tête
    private float pauseTimer = 0f;
    private float pauseDuration;
    private bool isPaused = false;

    // per-car data
    private float[] progressOffset;        // décalage t[i] = t_i_init - t_head_init
    private Vector3[] positionOffset;      // decalage latéral initial
    private Quaternion[] rotationOffset;   // decalage de rotation initiale

    void Start()
    {
        if (splineContainer == null)
        {
            Debug.LogError("Assign a SplineContainer!", this);
            enabled = false;
            return;
        }

        if (cars == null || cars.Count == 0)
        {
            Debug.LogError("Assign at least one car!", this);
            enabled = false;
            return;
        }

        totalLength = splineContainer.CalculateLength();
        int n = cars.Count;

        progressOffset = new float[n];
        positionOffset = new Vector3[n];
        rotationOffset = new Quaternion[n];

        // 1) On stocke le t initial de chaque car
        float headTInit = FindNearestT(cars[0].position);
        headProgress = headTInit;

        for (int i = 0; i < n; i++)
        {
            // t initial de ce car
            float tInit = FindNearestT(cars[i].position);
            // décalage relatif au head
            progressOffset[i] = Mathf.Repeat(tInit - headTInit, 1f);

            // position « théorique » sur spline à tInit
            Vector3 onSpline = splineContainer.EvaluatePosition(tInit);
            // on garde leur offset 3D par rapport à la spline
            positionOffset[i] = cars[i].position - onSpline;

            if (applyRotation)
            {
                // rotation théorique sur spline
                Quaternion splineRot = Quaternion.LookRotation(
                    Vector3.ProjectOnPlane(splineContainer.EvaluateTangent(tInit), Vector3.up).normalized,
                    Vector3.up
                ) * Quaternion.Euler(0f, 90f, 0f);
                rotationOffset[i] = cars[i].rotation * Quaternion.Inverse(splineRot);
            }
        }

        if (usePause)
            pauseDuration = Random.Range(pauseMin, pauseMax);
    }

    void Update()
    {
        // === GESTION DE LA TÊTE + PAUSE ===
        if (usePause && isPaused)
        {
            pauseTimer += Time.deltaTime;
            if (pauseTimer >= pauseDuration)
            {
                isPaused = false;
                pauseTimer = 0f;
                headProgress = 0f; // reset au début
            }
        }
        else
        {
            headProgress += speed * Time.deltaTime / totalLength;
        }

        // lorsqu'on atteint la fin
        if (!isPaused && headProgress >= 1f)
        {
            headProgress = 1f;
            if (usePause)
            {
                isPaused = true;
                pauseTimer = 0f;
                pauseDuration = Random.Range(pauseMin, pauseMax);
            }
            else
            {
                headProgress = 0f;
            }
        }

        // === MISE À JOUR DE CHAQUE CAR ===
        for (int i = 0; i < cars.Count; i++)
        {
            // t actuel de ce car = tête + son décalage initial
            float t = Mathf.Repeat(headProgress + progressOffset[i], 1f);

            // position sur la spline + offset latéral
            Vector3 basePos = splineContainer.EvaluatePosition(t);
            cars[i].position = basePos + positionOffset[i];

            if (applyRotation)
            {
                // rotation spline
                Vector3 tan = splineContainer.EvaluateTangent(t);
                Vector3 fwd = Vector3.ProjectOnPlane(tan, Vector3.up).normalized;
                if (fwd.sqrMagnitude > 0.001f)
                {
                    Quaternion splineRot = Quaternion.LookRotation(fwd, Vector3.up)
                                            * Quaternion.Euler(0f, 90f, 0f);
                    // on applique le décalage enregistré
                    cars[i].rotation = splineRot * rotationOffset[i];
                }
            }
        }
    }

    // renvoie t (0–1) le plus proche sur la spline depuis worldPos
    float FindNearestT(Vector3 worldPos)
    {
        Vector3 localPos = splineContainer.transform.InverseTransformPoint(worldPos);
        SplineUtility.GetNearestPoint(splineContainer.Spline, localPos, out _, out float t);
        return t;
    }
}
