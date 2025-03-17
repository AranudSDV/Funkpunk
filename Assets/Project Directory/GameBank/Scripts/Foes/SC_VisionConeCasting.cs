using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class SC_VisionConeCustom : MonoBehaviour
{
    [Header("Matériau & Paramètres du Field of View")]
    [SerializeField] private Material mVisionCone;
    [SerializeField] private SC_FieldOfView scFieldView;

    [Header("Parameters")]
    [SerializeField] private int coneResolution = 30;
    [SerializeField] private LayerMask groundMask;
    [SerializeField] private LayerMask obstructionMask;
    [SerializeField] private float guardVerticalOffset = 0f;
    [SerializeField] private float farPointExtraOffset = 0f;
    [SerializeField] private float offsetAmount = 0f; 
    [SerializeField] private int heightSegments = 3;

    private Mesh coneMesh;
    private MeshFilter meshFilter;
    private MeshRenderer meshRenderer;

    private void Awake()
    {
        meshFilter = GetComponent<MeshFilter>();
        meshRenderer = GetComponent<MeshRenderer>();
        coneMesh = new Mesh();
        meshFilter.mesh = coneMesh;
        if (mVisionCone != null)
            meshRenderer.material = mVisionCone;
    }

    private void Update()
    {
        BuildCone();
    }

    private void BuildCone()
    {
        Vector3 guardPos = transform.position + Vector3.up * guardVerticalOffset;
        float maxDist = scFieldView.FRadius;
        Vector3 farPoint;
        Ray ray = new Ray(guardPos, transform.forward);

        if (Physics.Raycast(ray, out RaycastHit hit, maxDist, groundMask))
        {
            farPoint = hit.point;
        }
        else
        {
            farPoint = guardPos + transform.forward * maxDist;
            farPoint.y = 0;
        }

        farPoint += transform.forward * farPointExtraOffset;

        float totalDistance = Vector3.Distance(guardPos, farPoint);
        float halfAngleRad = scFieldView.FAngle * Mathf.Deg2Rad / 2f;
        float farRadius = totalDistance * Mathf.Tan(halfAngleRad);

        Vector3[] farCircle = new Vector3[coneResolution];
        Vector3 right = transform.right;
        Vector3 forward = transform.forward;

        for (int i = 0; i < coneResolution; i++)
        {
            float angle = 2f * Mathf.PI * i / coneResolution;
            Vector3 offset = (right * Mathf.Cos(angle) + forward * Mathf.Sin(angle)) * farRadius;
            Vector3 point = farPoint + offset;

            // Vérifier la collision avec les obstructions pour chaque point
            if (Physics.Raycast(guardPos, (point - guardPos).normalized, out RaycastHit pointHit, maxDist, obstructionMask))
            {
                farCircle[i] = pointHit.point;
            }
            else
            {
                farCircle[i] = point;
            }
        }

        // 6. Appliquer un offset horizontal (au sol) sur les vertices du farCircle situés dans la moitié \"face au garde\"
        Vector3 offsetDir = Vector3.ProjectOnPlane((guardPos - farPoint), Vector3.up).normalized;
        for (int i = 0; i < coneResolution; i++)
        {
            Vector3 dir = farCircle[i] - farPoint;
            float dot = Vector3.Dot(dir.normalized, offsetDir);
            if (dot > 0)
            {
                farCircle[i] += offsetDir * (offsetAmount * dot);
                farCircle[i] = new Vector3(farCircle[i].x, farPoint.y, farCircle[i].z);
            }
        }

        int rings = heightSegments;
        Vector3[] vertices = new Vector3[rings * coneResolution];
        Vector2[] uvs = new Vector2[vertices.Length];

        for (int ring = 0; ring < rings; ring++)
        {
            float t = (float)ring / (rings - 1);
            for (int j = 0; j < coneResolution; j++)
            {
                Vector3 interpPos = Vector3.Lerp(farCircle[j], guardPos, t);
                int index = ring * coneResolution + j;
                vertices[index] = transform.InverseTransformPoint(interpPos);

                uvs[index] = new Vector2((float)j / (coneResolution - 1), t);
            }
        }

        int quads = (rings - 1) * coneResolution;
        int[] triangles = new int[quads * 6];
        int triIndex = 0;
        for (int ring = 0; ring < rings - 1; ring++)
        {
            for (int j = 0; j < coneResolution; j++)
            {
                int current = ring * coneResolution + j;
                int next = current + coneResolution;
                int jNext = (j + 1) % coneResolution;
                int currentNext = ring * coneResolution + jNext;
                int nextNext = currentNext + coneResolution;

                // Détection des points de collision
                bool currentObstructed = obstructionMask != 0 && Physics.CheckSphere(vertices[current], 0.1f, obstructionMask);
                bool currentNextObstructed = obstructionMask != 0 && Physics.CheckSphere(vertices[currentNext], 0.1f, obstructionMask);

                // Premier triangle
                triangles[triIndex++] = current;
                triangles[triIndex++] = next;
                triangles[triIndex++] = nextNext;

                // Deuxième triangle (changement de l'ordre des indices)
                triangles[triIndex++] = current;
                triangles[triIndex++] = nextNext;
                triangles[triIndex++] = currentNext;

                // Si l’un des points est touché par un obstacle et l’autre non, ajoute un triangle pour combler l’écart
                if (currentObstructed != currentNextObstructed)
                {
                    triangles[triIndex++] = current;
                    triangles[triIndex++] = next;
                    triangles[triIndex++] = currentNext;
                }
            }
        }

        coneMesh.Clear();
        coneMesh.vertices = vertices;
        coneMesh.triangles = triangles;
        coneMesh.uv = uvs;
        coneMesh.RecalculateBounds();
        coneMesh.RecalculateNormals();
    }
}