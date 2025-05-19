using UnityEngine;
using System.Collections.Generic;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class SC_VisionConeCasting : MonoBehaviour
{
    public int iBossTagsPhase2 = 0;
    [Header("Matériau & Paramètres du Field of View")]
    [SerializeField] private Material mVisionCone;
    [SerializeField] private SC_FieldOfView scFieldView; // Contient FAngle (en degrés) et FRadius (distance max)
    [SerializeField] private Material mDetectedCone;
    [SerializeField] private Material mHeardCone;
    private float fTimerBlinck = 0f;
    private bool bBlincking = false;

    [Header("Parameters")]
    [SerializeField] private int coneResolution = 30;       // Nombre de segments pour le cercle
    [SerializeField] private LayerMask groundMask;          // Masque pour identifier le sol
    [SerializeField] private LayerMask obstructionMask;     // Masque pour détecter les obstacles (murs, etc.)
    [SerializeField] private float guardVerticalOffset = 0f;  // Hauteur du garde (base)
    [SerializeField] private float farPointExtraOffset = 0f;  // Offset additionnel sur le point éloigné (optionnel)

    [Header("Offset pour la partie interne")]
    [SerializeField] private float offsetAmount = 0f;         // Force d'offset appliquée aux vertices dans la moitié \"face au garde\"

    [Header("Subdivision")]
    [SerializeField] private int heightSegments = 3;          // Nombre d'anneaux entre le garde et le farPoint

    [Header("Lissage des bords")]
    [SerializeField] private float smoothThreshold = 0.5f;    // Seuil de différence de hauteur pour lisser les bords

    private Mesh coneMesh;
    private MeshFilter meshFilter;
    public MeshRenderer ConeRenderer;

    private void Awake()
    {
        meshFilter = GetComponent<MeshFilter>();
        ConeRenderer = GetComponent<MeshRenderer>();
        coneMesh = new Mesh();
        meshFilter.mesh = coneMesh;
        if (mVisionCone != null)
            ConeRenderer.material = mVisionCone;
    }

    private void Update()
    {
        BuildCone(); 
        CheckStatus();
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

    private void BuildCone()
    {
        // 1. Position du garde (base)
        Vector3 guardPos = transform.position + Vector3.up * guardVerticalOffset;

        // 2. Calcul du farPoint : projection sur le sol via raycast vertical
        float maxDist = scFieldView.FRadius;
        Vector3 tentativeFarPoint = guardPos + transform.forward * maxDist;
        Ray groundRay = new Ray(tentativeFarPoint + Vector3.up * 10f, Vector3.down);
        Vector3 farPoint;
        if (Physics.Raycast(groundRay, out RaycastHit groundHit, 20f, groundMask))
        {
            farPoint = groundHit.point;
        }
        else
        {
            farPoint = tentativeFarPoint;
            farPoint.y = 0;
        }
        farPoint += transform.forward * farPointExtraOffset;

        // 3. Calcul du rayon du cercle via FAngle
        float totalDistance = Vector3.Distance(guardPos, farPoint);
        float halfAngleRad = scFieldView.FAngle * Mathf.Deg2Rad / 2f;
        float farRadius = totalDistance * Mathf.Tan(halfAngleRad);
        farRadius = Mathf.Clamp(farRadius, 0f, 100f);

        // 4. Calcul du cercle de vertices (farCircle) autour du farPoint
        Vector3[] farCircle = new Vector3[coneResolution];
        // Utiliser transform.right et transform.forward (sans ProjectOnPlane, pour conserver l'orientation 3D)
        Vector3 right = transform.right;
        Vector3 forward = transform.forward;
        // Direction d'offset (vers le garde)
        Vector3 offsetDir = Vector3.ProjectOnPlane((guardPos - farPoint), Vector3.up).normalized;
        for (int i = 0; i < coneResolution; i++)
        {
            float angle = 2f * Mathf.PI * i / coneResolution;
            Vector3 baseOffset = (right * Mathf.Cos(angle) + forward * Mathf.Sin(angle)) * farRadius;
            // Appliquer l'offset avant collision
            Vector3 basePoint = farPoint + baseOffset;
            float dot = Vector3.Dot((basePoint - farPoint).normalized, offsetDir);
            if (dot > 0)
            {
                basePoint += offsetDir * (offsetAmount * dot);
                basePoint = new Vector3(basePoint.x, farPoint.y, basePoint.z);
            }
            // Raycast depuis le garde vers le point offseté pour détecter un obstacle (ex: mur)
            Ray rayToPoint = new Ray(guardPos, (basePoint - guardPos).normalized);
            if (Physics.Raycast(rayToPoint, out RaycastHit pointHit, maxDist, obstructionMask))
            {
                farCircle[i] = pointHit.point;
            }
            else
            {
                farCircle[i] = basePoint;
            }
        }

        // 4bis. Lissage du farCircle pour combler les trous entre vertices collidés et non collidés
        for (int i = 0; i < coneResolution; i++)
        {
            int next = (i + 1) % coneResolution;
            float diffY = Mathf.Abs(farCircle[i].y - farCircle[next].y);
            if (diffY > smoothThreshold)
            {
                float avgY = (farCircle[i].y + farCircle[next].y) / 2f;
                if (farCircle[i].y < farCircle[next].y)
                    farCircle[i].y = avgY;
                else
                    farCircle[next].y = avgY;
            }
        }

        // 5. Subdivision verticale entre le farCircle (anneau 0) et le garde (anneau final)
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

        // 6. Construction des triangles (ordre classique)
        int[] triangles = new int[(rings - 1) * coneResolution * 6];
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

        coneMesh.Clear();
        coneMesh.vertices = vertices;
        coneMesh.triangles = triangles;
        coneMesh.uv = uvs;
        coneMesh.RecalculateBounds();
        coneMesh.RecalculateNormals();
    }
}