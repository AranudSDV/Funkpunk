using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class SC_VisionConeCasting : MonoBehaviour
{
    public bool bOnlyMeshable = false;
    public int iBossTagsPhase2 = 0;

    [Header("Matériau & Paramètres du Field of View")]
    [SerializeField] private Material mVisionCone;
    [SerializeField] private SC_FieldOfView scFieldView;
    [SerializeField] private Material mDetectedCone;
    [SerializeField] private Material mHeardCone;

    [Header("Parameters")]
    [SerializeField] private int coneResolution = 30;
    [SerializeField] private LayerMask groundMask;
    [SerializeField] private LayerMask obstructionMask;
    [SerializeField] private float guardVerticalOffset = 0f;
    [SerializeField] private float farPointExtraOffset = 0f;
    [SerializeField] private float GroundHeight = 0f;

    [Header("Offset pour la partie interne")]
    [SerializeField] private float offsetAmount = 0f;

    [Header("Subdivision")]
    [SerializeField] private int heightSegments = 3;


    private Mesh coneMesh;
    private MeshFilter meshFilter;
    public MeshRenderer ConeRenderer;

    // Buffers internes
    private Vector3[] baseVertices;    // Cône “idéal” sans collisions
    private Vector3[] workingVertices; // Copie runtime
    private Vector2[] uvs;
    private int[] triangles;

    private void Awake()
    {
        meshFilter = GetComponent<MeshFilter>();
        ConeRenderer = GetComponent<MeshRenderer>();
        coneMesh = new Mesh();
        meshFilter.mesh = coneMesh;

        if (mVisionCone != null)
            ConeRenderer.material = mVisionCone;

        PreloadConeMesh();
    }

    private void Update()
    {
        UpdateConeVertices();

        if (!bOnlyMeshable)
        {
            CheckStatus();
        }
    }

    private void CheckStatus()
    {
        if (scFieldView.BCanSee)
        {
            ConeRenderer.material = mDetectedCone;
        }
        else if (scFieldView.bHasHeard)
        {
            ConeRenderer.material = mHeardCone;
        }
        else
        {
            ConeRenderer.material = mVisionCone;
        }
    }

    // -------------------
    // MESH BASE (STATIC)
    // -------------------
    private void PreloadConeMesh()
    {
        // 1. Base positions
        Vector3 guardPos = transform.position + Vector3.up * guardVerticalOffset;
        float maxDist = scFieldView.FRadius;
        Vector3 farPoint = guardPos + transform.forward * maxDist;
        farPoint.y = GroundHeight;
        farPoint += transform.forward * farPointExtraOffset;

        // 2. Angle & rayon max
        float totalDistance = Vector3.Distance(guardPos, farPoint);
        float halfAngleRad = scFieldView.FAngle * Mathf.Deg2Rad / 2f;
        float farRadius = totalDistance * Mathf.Tan(halfAngleRad);
        farRadius = Mathf.Clamp(farRadius, 0f, 100f);

        // 3. Far circle (sans collisions)
        Vector3[] farCircle = new Vector3[coneResolution];
        Vector3 right = transform.right;
        Vector3 forward = transform.forward;
        Vector3 offsetDir = Vector3.ProjectOnPlane((guardPos - farPoint), Vector3.up).normalized;

        for (int i = 0; i < coneResolution; i++)
        {
            float angle = 2f * Mathf.PI * i / coneResolution;
            Vector3 dir = (right * Mathf.Cos(angle) + forward * Mathf.Sin(angle)).normalized;

            float angleFromForward = Mathf.Acos(Vector3.Dot(dir, forward));
            float scale = angleFromForward <= halfAngleRad ? 1f : Mathf.Clamp01(Mathf.Cos((angleFromForward - halfAngleRad) / (Mathf.PI - halfAngleRad) * Mathf.PI * 0.5f));
            float deformedRadius = farRadius * scale;

            Vector3 basePoint = farPoint + dir * deformedRadius;

            // Offset interne
            float dot = Vector3.Dot((basePoint - farPoint).normalized, offsetDir);
            if (dot > 0)
            {
                basePoint += offsetDir * (offsetAmount * dot);
                basePoint = new Vector3(basePoint.x, farPoint.y, basePoint.z);
            }

            farCircle[i] = basePoint;
        }

        // 4. Subdivision verticale
        int rings = heightSegments;
        baseVertices = new Vector3[rings * coneResolution];
        uvs = new Vector2[baseVertices.Length];

        for (int ring = 0; ring < rings; ring++)
        {
            float t = (float)ring / (rings - 1);
            for (int j = 0; j < coneResolution; j++)
            {
                Vector3 interpPos = Vector3.Lerp(farCircle[j], guardPos, t);
                int index = ring * coneResolution + j;
                baseVertices[index] = transform.InverseTransformPoint(interpPos);
                uvs[index] = new Vector2((float)j / (coneResolution - 1), t);
            }
        }

        // 5. Triangles
        triangles = new int[(rings - 1) * coneResolution * 6];
        int triIndex = 0;
        for (int ring = 0; ring < rings - 1; ring++)
        {
            for (int j = 0; j < coneResolution; j++)
            {
                int current = ring * coneResolution + j;
                int nextRing = current + coneResolution;
                int jNext = (j + 1) % coneResolution;
                int currentNext = ring * coneResolution + jNext;
                int nextNext = currentNext + coneResolution;

                triangles[triIndex++] = current;
                triangles[triIndex++] = nextRing;
                triangles[triIndex++] = nextNext;

                triangles[triIndex++] = current;
                triangles[triIndex++] = nextNext;
                triangles[triIndex++] = currentNext;
            }
        }

        // 6. Assign au mesh
        coneMesh.Clear();
        coneMesh.vertices = baseVertices;
        coneMesh.triangles = triangles;
        coneMesh.uv = uvs;
        coneMesh.RecalculateBounds();
        coneMesh.RecalculateNormals();

        // Initialise le buffer runtime
        workingVertices = new Vector3[baseVertices.Length];
    }

    // -------------------
    // UPDATE RUNTIME
    // -------------------
    private void UpdateConeVertices()
    {
        if (baseVertices == null || baseVertices.Length == 0) return;

        baseVertices.CopyTo(workingVertices, 0);

        int rings = heightSegments;
        float maxDist = scFieldView.FRadius;
        Vector3 guardPos = transform.position + Vector3.up * guardVerticalOffset;

        // On modifie uniquement l’anneau “farCircle” (ring = 0)
        for (int j = 0; j < coneResolution; j++)
        {
            int index = j; // ring 0
            Vector3 worldPoint = transform.TransformPoint(baseVertices[index]);

            Ray rayToPoint = new Ray(guardPos, (worldPoint - guardPos).normalized);
            if (Physics.Raycast(rayToPoint, out RaycastHit hit, maxDist, obstructionMask))
            {
                worldPoint = hit.point;
            }

            workingVertices[index] = transform.InverseTransformPoint(worldPoint);

            // Mise à jour UV proportionnelle à la distance réelle
            float distRatio = Vector3.Distance(guardPos, worldPoint) / maxDist;
            uvs[index].y = distRatio;
        }

        // Réapplique uniquement les vertices
        coneMesh.vertices = workingVertices;
        coneMesh.uv = uvs;


    }

}