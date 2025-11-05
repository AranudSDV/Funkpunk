using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class SC_VisionConeGPU : MonoBehaviour
{
    [Header("Matériaux & Field of View")]
    [SerializeField] private Material mVisionCone;
    [SerializeField] private SC_FieldOfView scFieldView;
    [SerializeField] private Material mDetectedCone;
    [SerializeField] private Material mHeardCone;

    [Header("Paramètres")]
    [SerializeField] private int coneResolution = 30;
    [SerializeField] private LayerMask obstructionMask;
    [SerializeField] private float offsetAmount = 0f;
    [SerializeField] private int heightSegments = 2;
    [SerializeField] private float farPointExtraOffset = 0f;
    [SerializeField] private float farCircleHeight = 0f;

    [Header("Compute Shader (source unique)")]
    [SerializeField] private ComputeShader computeShaderSource;

    // --- Instances & Mesh ---
    private ComputeShader computeShaderInstance; // instance GPU isolée
    private int kernelID = -1;
    private Mesh coneMesh;
    private MeshFilter meshFilter;
    private MeshRenderer coneRenderer;

    // --- Buffers & Data ---
    private Vector3[] baseVertices;
    private Vector2[] uvs;
    private int[] triangles;
    private Vector3[] farCircleLocal;
    private Vector3[] farCircleOriginalLocal;

    // NEW: store world positions so we can lock Y in world-space
    private Vector3[] farCircleWorld;
    private bool[] collisionActive;

    private ComputeBuffer vertexBuffer;
    private ComputeBuffer uvBuffer;
    private ComputeBuffer normalBuffer;
    private ComputeBuffer farCircleBuffer;

    public int iBossTagsPhase2 = 0;
    public bool bOnlyMeshable = false;

    // ===========================================================
    //  INITIALISATION
    // ===========================================================
    private void OnEnable()
    {
        meshFilter = GetComponent<MeshFilter>();
        coneRenderer = GetComponent<MeshRenderer>();

        coneMesh = new Mesh();
        coneMesh.name = "SC_VisionConeGPU_Mesh_" + GetInstanceID();
        coneMesh.MarkDynamic();
        meshFilter.sharedMesh = coneMesh;

        if (mVisionCone != null)
            coneRenderer.sharedMaterial = mVisionCone;

        if (scFieldView == null)
        {
            Debug.LogError("[SC_VisionConeGPU] scFieldView not assigned!");
            enabled = false;
            return;
        }

        // ⚙️ Création du mesh de base (initialise aussi farCircleWorld / collisionActive)
        PreloadConeMesh();

        // 🧩 Instanciation isolée du compute shader
        if (computeShaderSource != null)
            computeShaderInstance = Instantiate(computeShaderSource);
        else
        {
            Debug.LogError("[SC_VisionConeGPU] Compute shader source manquant !");
            enabled = false;
            return;
        }

        SetupComputeShader();
    }

    private void OnDisable()
    {
        vertexBuffer?.Release();
        uvBuffer?.Release();
        normalBuffer?.Release();
        farCircleBuffer?.Release();

        vertexBuffer = uvBuffer = normalBuffer = farCircleBuffer = null;
    }

    // ===========================================================
    //  UPDATE
    // ===========================================================
    private void Update()
    {
        UpdateFarCircleCPU();   // collisions CPU (met farCircleLocal + collisionActive)
        UpdateFarCircleHeight(); // lock Y in world space for non-colliding points
        RunComputeShader();     // update GPU mesh
        UpdateMaterial();       // visuel dynamique
    }

    private void UpdateMaterial()
    {
        if (coneRenderer == null || scFieldView == null) return;

        if (scFieldView.BCanSee)
            coneRenderer.sharedMaterial = mDetectedCone;
        else if (scFieldView.bHasHeard)
            coneRenderer.sharedMaterial = mHeardCone;
        else
            coneRenderer.sharedMaterial = mVisionCone;
    }

    // ===========================================================
    //  PRELOAD CPU — Forme conforme fRadius/fAngle
    //  (ici on initialise aussi farCircleWorld & collisionActive)
    // ===========================================================
    private void PreloadConeMesh()
    {
        Vector3 guardWorld = transform.position;
        float fRadius = scFieldView.FRadius;
        float fAngle = scFieldView.FAngle;
        float halfAngleRad = fAngle * Mathf.Deg2Rad * 0.5f;

        Vector3 farPoint = guardWorld + transform.forward * fRadius;
        farPoint.y = guardWorld.y + farCircleHeight;

        float totalDistance = Vector3.Distance(guardWorld, farPoint);
        float farRadius = totalDistance * Mathf.Tan(halfAngleRad);
        farRadius = Mathf.Clamp(farRadius, 0f, 100f);

        Vector3[] localFarCircle = new Vector3[coneResolution];
        Vector3 right = transform.right;
        Vector3 forward = transform.forward;
        Vector3 offsetDir = Vector3.ProjectOnPlane((guardWorld - farPoint), Vector3.up).normalized;

        // compute farCircle in world space (respecting offsetAmount and clamp radial)
        farCircleWorld = new Vector3[coneResolution];
        for (int i = 0; i < coneResolution; i++)
        {
            float angle = 2f * Mathf.PI * i / coneResolution;
            Vector3 dir = (right * Mathf.Cos(angle) + forward * Mathf.Sin(angle)).normalized;

            float angleFromForward = Mathf.Acos(Mathf.Clamp(Vector3.Dot(dir, forward), -1f, 1f));
            float scale = angleFromForward <= halfAngleRad
                ? 1f
                : Mathf.Clamp01(Mathf.Cos((angleFromForward - halfAngleRad) / (Mathf.PI - halfAngleRad) * Mathf.PI * 0.5f));
            float deformedRadius = farRadius * scale;

            Vector3 basePoint = farPoint + dir * deformedRadius;

            // Offset interne axial
            float dot = Vector3.Dot((basePoint - farPoint).normalized, offsetDir);
            if (dot > 0f && offsetAmount != 0f)
            {
                basePoint += offsetDir * (offsetAmount * dot);
                basePoint.y = farPoint.y;
            }

            // Clamp radial (respect du fRadius)
            Vector3 fromGuard = basePoint - guardWorld;
            if (fromGuard.magnitude > fRadius)
            {
                basePoint = guardWorld + fromGuard.normalized * fRadius;
                basePoint.y = farPoint.y;
            }

            farCircleWorld[i] = basePoint;
        }

        // Convert to local buffers used by GPU
        farCircleLocal = new Vector3[coneResolution];
        farCircleOriginalLocal = new Vector3[coneResolution];
        collisionActive = new bool[coneResolution];
        for (int i = 0; i < coneResolution; i++)
        {
            Vector3 local = transform.InverseTransformPoint(farCircleWorld[i]);
            farCircleLocal[i] = local;
            farCircleOriginalLocal[i] = local;
            collisionActive[i] = false;
        }

        // Build the mesh local
        Vector3 guardLocal = transform.InverseTransformPoint(guardWorld);
        int rings = heightSegments;
        baseVertices = new Vector3[rings * coneResolution];
        uvs = new Vector2[baseVertices.Length];
        triangles = new int[(rings - 1) * coneResolution * 6];

        int triIndex = 0;
        for (int ring = 0; ring < rings; ring++)
        {
            float t = (float)ring / (rings - 1);
            for (int j = 0; j < coneResolution; j++)
            {
                int idx = ring * coneResolution + j;
                baseVertices[idx] = Vector3.Lerp(farCircleLocal[j], guardLocal, t);
                uvs[idx] = new Vector2((float)j / (coneResolution - 1), t);

                if (ring < rings - 1)
                {
                    int jNext = (j + 1) % coneResolution;
                    int nextRing = (ring + 1) * coneResolution;
                    triangles[triIndex++] = idx;
                    triangles[triIndex++] = nextRing + j;
                    triangles[triIndex++] = nextRing + jNext;

                    triangles[triIndex++] = idx;
                    triangles[triIndex++] = nextRing + jNext;
                    triangles[triIndex++] = ring * coneResolution + jNext;
                }
            }
        }

        coneMesh.Clear();
        coneMesh.vertices = baseVertices;
        coneMesh.triangles = triangles;
        coneMesh.uv = uvs;
        coneMesh.RecalculateBounds();
        coneMesh.RecalculateNormals();
    }

    // ===========================================================
    //  UPDATE COLLISION (CPU)
    //  - met à jour farCircleLocal selon collisions
    //  - maintient collisionActive[] pour le lock de hauteur
    // ===========================================================
    private void UpdateFarCircleCPU()
    {
        if (farCircleLocal == null || farCircleOriginalLocal == null) return;

        Vector3 guardWorld = transform.position;
        float maxDist = scFieldView.FRadius;

        bool anyChange = false;
        for (int j = 0; j < coneResolution; j++)
        {
            Vector3 candidateWorld = transform.TransformPoint(farCircleOriginalLocal[j]);
            Vector3 dir = (candidateWorld - guardWorld).normalized;

            if (Physics.Raycast(guardWorld, dir, out RaycastHit hit, maxDist, obstructionMask))
            {
                Vector3 hitLocal = transform.InverseTransformPoint(hit.point);
                if ((hitLocal - farCircleLocal[j]).sqrMagnitude > 1e-6f)
                {
                    farCircleLocal[j] = hitLocal;
                    // set world pos accordingly and mark collision active
                    farCircleWorld[j] = hit.point;
                    collisionActive[j] = true;
                    anyChange = true;
                }
            }
            else
            {
                // no collision: if previously in collision, we clear flag and restore original local
                if (collisionActive[j])
                {
                    collisionActive[j] = false;
                    // restore to original local (will be re-y-locked in UpdateFarCircleHeight)
                    farCircleLocal[j] = farCircleOriginalLocal[j];
                    // also update farCircleWorld accordingly
                    farCircleWorld[j] = transform.TransformPoint(farCircleOriginalLocal[j]);
                    anyChange = true;
                }
            }
        }

        if (anyChange && farCircleBuffer != null)
            farCircleBuffer.SetData(farCircleLocal);
    }

    // ===========================================================
    //  LOCK FAR CIRCLE HEIGHT (WORLD SPACE)
    //  - for non-colliding points, force Y = transform.position.y + farCircleHeight
    //  - immediate (no lerp)
    // ===========================================================
    private void UpdateFarCircleHeight()
    {
        if (farCircleWorld == null || farCircleLocal == null) return;

        float targetY = transform.position.y + farCircleHeight;
        bool anyChange = false;

        for (int i = 0; i < coneResolution; i++)
        {
            if (!collisionActive[i])
            {
                Vector3 w = farCircleWorld[i];
                if (Mathf.Abs(w.y - targetY) > 1e-6f)
                {
                    w.y = targetY;
                    farCircleWorld[i] = w;
                    // update local buffer used by GPU
                    farCircleLocal[i] = transform.InverseTransformPoint(w);
                    anyChange = true;
                }
            }
            else
            {
                // if collisionActive, ensure farCircleLocal matches world collision point (in case guard moved)
                farCircleLocal[i] = transform.InverseTransformPoint(farCircleWorld[i]);
            }
        }

        if (anyChange && farCircleBuffer != null)
            farCircleBuffer.SetData(farCircleLocal);
    }

    // ===========================================================
    //  SETUP COMPUTE
    // ===========================================================
    private void SetupComputeShader()
    {
        kernelID = computeShaderInstance.FindKernel("VisionCone");

        vertexBuffer = new ComputeBuffer(baseVertices.Length, sizeof(float) * 3);
        uvBuffer = new ComputeBuffer(uvs.Length, sizeof(float) * 2);
        normalBuffer = new ComputeBuffer(baseVertices.Length, sizeof(float) * 3);
        farCircleBuffer = new ComputeBuffer(farCircleLocal.Length, sizeof(float) * 3);

        vertexBuffer.SetData(baseVertices);
        uvBuffer.SetData(uvs);
        normalBuffer.SetData(baseVertices); // placeholder
        farCircleBuffer.SetData(farCircleLocal);

        computeShaderInstance.SetBuffer(kernelID, "vertices", vertexBuffer);
        computeShaderInstance.SetBuffer(kernelID, "uvs", uvBuffer);
        computeShaderInstance.SetBuffer(kernelID, "normals", normalBuffer);
        computeShaderInstance.SetBuffer(kernelID, "farCircleLocal", farCircleBuffer);
        computeShaderInstance.SetInt("resolution", coneResolution);
        computeShaderInstance.SetInt("heightSegments", heightSegments);
        computeShaderInstance.SetFloat("maxDist", scFieldView.FRadius);
    }

    // ===========================================================
    //  GPU UPDATE
    // ===========================================================
    private void RunComputeShader()
    {
        if (computeShaderInstance == null || kernelID < 0) return;

        computeShaderInstance.SetFloat("maxDist", scFieldView.FRadius);
        computeShaderInstance.SetInt("resolution", coneResolution);
        computeShaderInstance.SetInt("heightSegments", heightSegments);

        int threadGroups = Mathf.CeilToInt((float)coneResolution / 64f);
        computeShaderInstance.Dispatch(kernelID, threadGroups, 1, 1);

        Vector3[] verticesOut = new Vector3[baseVertices.Length];
        Vector2[] uvsOut = new Vector2[uvs.Length];
        Vector3[] normalsOut = new Vector3[baseVertices.Length];

        vertexBuffer.GetData(verticesOut);
        uvBuffer.GetData(uvsOut);
        normalBuffer.GetData(normalsOut);

        coneMesh.vertices = verticesOut;
        coneMesh.uv = uvsOut;
        coneMesh.normals = normalsOut;
        coneMesh.RecalculateBounds();
    }

    // ===========================================================
    //  PLACEHOLDER iBoss
    // ===========================================================
    //public void iBossTagPhase() => Debug.Log("To fix BossTagsPhase");
    //public void iBossTagPhase2() => Debug.Log("To fix BossTagsPhase2");
}
