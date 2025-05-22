//using UnityEngine;
//using System.Collections.Generic;

//[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
//public class SC_VisionConeCasting : MonoBehaviour
//{
//    public bool bOnlyMeshable = false;
//    public int iBossTagsPhase2 = 0;
//    [Header("Matériau & Paramètres du Field of View")]
//    [SerializeField] private Material mVisionCone;
//    [SerializeField] private SC_FieldOfView scFieldView; // Contient FAngle (en degrés) et FRadius (distance max)
//    [SerializeField] private Material mDetectedCone;
//    [SerializeField] private Material mHeardCone;
//    private float fTimerBlinck = 0f;
//    private bool bBlincking = false;

//    [Header("Parameters")]
//    [SerializeField] private int coneResolution = 30;       // Nombre de segments pour le cercle
//    [SerializeField] private LayerMask groundMask;          // Masque pour identifier le sol
//    [SerializeField] private LayerMask obstructionMask;     // Masque pour détecter les obstacles (murs, etc.)
//    [SerializeField] private float guardVerticalOffset = 0f;  // Hauteur du garde (base)
//    [SerializeField] private float farPointExtraOffset = 0f;  // Offset additionnel sur le point éloigné (optionnel)

//    [Header("Offset pour la partie interne")]
//    [SerializeField] private float offsetAmount = 0f;         // Force d'offset appliquée aux vertices dans la moitié \"face au garde\"

//    [Header("Subdivision")]
//    [SerializeField] private int heightSegments = 3;          // Nombre d'anneaux entre le garde et le farPoint

//    [Header("Lissage des bords")]
//    [SerializeField] private float smoothThreshold = 0.5f;    // Seuil de différence de hauteur pour lisser les bords

//    private Mesh coneMesh;
//    private MeshFilter meshFilter;
//    public MeshRenderer ConeRenderer;

//    private void Awake()
//    {
//        meshFilter = GetComponent<MeshFilter>();
//        ConeRenderer = GetComponent<MeshRenderer>();
//        coneMesh = new Mesh();
//        meshFilter.mesh = coneMesh;
//        if (mVisionCone != null)
//            ConeRenderer.material = mVisionCone;
//    }

//    private void Update()
//    {
//        BuildCone();
//        if (!bOnlyMeshable)
//        {
//            CheckStatus();
//        }
//    }
//    private void CheckStatus()
//    {
//        if (scFieldView.BCanSee)
//        {
//            ConeRenderer.material = mDetectedCone;
//        }
//        else if (scFieldView.bHasHeard)
//        {
//            ConeRenderer.material = mHeardCone;
//        }
//        else
//        {
//            ConeRenderer.material = mVisionCone;
//        }
//    }

//    private void BuildCone()
//    {
//        // 1. Position du garde (base)
//        Vector3 guardPos = transform.position + Vector3.up * guardVerticalOffset;

//        // 2. Calcul du farPoint : projection sur le sol via raycast vertical
//        float maxDist = scFieldView.FRadius;
//        Vector3 tentativeFarPoint = guardPos + transform.forward * maxDist;
//        Ray groundRay = new Ray(tentativeFarPoint + Vector3.up * 10f, Vector3.down);
//        Vector3 farPoint;
//        if (Physics.Raycast(groundRay, out RaycastHit groundHit, 20f, groundMask))
//        {
//            farPoint = groundHit.point;
//        }
//        else
//        {
//            farPoint = tentativeFarPoint;
//            farPoint.y = 0;
//        }
//        farPoint += transform.forward * farPointExtraOffset;

//        // 3. Calcul du rayon du cercle via FAngle
//        float totalDistance = Vector3.Distance(guardPos, farPoint);
//        float halfAngleRad = scFieldView.FAngle * Mathf.Deg2Rad / 2f;
//        float farRadius = totalDistance * Mathf.Tan(halfAngleRad);
//        farRadius = Mathf.Clamp(farRadius, 0f, 100f);

//        // 4. Calcul du cercle de vertices (farCircle) autour du farPoint
//        Vector3[] farCircle = new Vector3[coneResolution];
//        // Utiliser transform.right et transform.forward (sans ProjectOnPlane, pour conserver l'orientation 3D)
//        Vector3 right = transform.right;
//        Vector3 forward = transform.forward;
//        // Direction d'offset (vers le garde)
//        Vector3 offsetDir = Vector3.ProjectOnPlane((guardPos - farPoint), Vector3.up).normalized;
//        for (int i = 0; i < coneResolution; i++)
//        {
//            float angle = 2f * Mathf.PI * i / coneResolution;
//            Vector3 baseOffset = (right * Mathf.Cos(angle) + forward * Mathf.Sin(angle)) * farRadius;
//            // Appliquer l'offset avant collision
//            Vector3 basePoint = farPoint + baseOffset;
//            float dot = Vector3.Dot((basePoint - farPoint).normalized, offsetDir);
//            if (dot > 0)
//            {
//                basePoint += offsetDir * (offsetAmount * dot);
//                basePoint = new Vector3(basePoint.x, farPoint.y, basePoint.z);
//            }
//            // Raycast depuis le garde vers le point offseté pour détecter un obstacle (ex: mur)
//            Ray rayToPoint = new Ray(guardPos, (basePoint - guardPos).normalized);
//            if (Physics.Raycast(rayToPoint, out RaycastHit pointHit, maxDist, obstructionMask))
//            {
//                farCircle[i] = pointHit.point;
//            }
//            else
//            {
//                farCircle[i] = basePoint;
//            }
//        }

//        // 4bis. Lissage du farCircle pour combler les trous entre vertices collidés et non collidés
//        for (int i = 0; i < coneResolution; i++)
//        {
//            int next = (i + 1) % coneResolution;
//            float diffY = Mathf.Abs(farCircle[i].y - farCircle[next].y);
//            if (diffY > smoothThreshold)
//            {
//                float avgY = (farCircle[i].y + farCircle[next].y) / 2f;
//                if (farCircle[i].y < farCircle[next].y)
//                    farCircle[i].y = avgY;
//                else
//                    farCircle[next].y = avgY;
//            }
//        }

//        // 5. Subdivision verticale entre le farCircle (anneau 0) et le garde (anneau final)
//        int rings = heightSegments;
//        Vector3[] vertices = new Vector3[rings * coneResolution];
//        Vector2[] uvs = new Vector2[vertices.Length];
//        for (int ring = 0; ring < rings; ring++)
//        {
//            float t = (float)ring / (rings - 1);
//            for (int j = 0; j < coneResolution; j++)
//            {
//                Vector3 interpPos = Vector3.Lerp(farCircle[j], guardPos, t);
//                int index = ring * coneResolution + j;
//                vertices[index] = transform.InverseTransformPoint(interpPos);
//                uvs[index] = new Vector2((float)j / (coneResolution - 1), t);
//            }
//        }

//        // 6. Construction des triangles (ordre classique)
//        int[] triangles = new int[(rings - 1) * coneResolution * 6];
//        int triIndex = 0;
//        for (int ring = 0; ring < rings - 1; ring++)
//        {
//            for (int j = 0; j < coneResolution; j++)
//            {
//                int current = ring * coneResolution + j;
//                int nextRing = current + coneResolution;
//                int jNext = (j + 1) % coneResolution;
//                int currentNext = ring * coneResolution + jNext;
//                int nextNext = currentNext + coneResolution;

//                triangles[triIndex++] = current;
//                triangles[triIndex++] = nextRing;
//                triangles[triIndex++] = nextNext;

//                triangles[triIndex++] = current;
//                triangles[triIndex++] = nextNext;
//                triangles[triIndex++] = currentNext;
//            }
//        }

//        coneMesh.Clear();
//        coneMesh.vertices = vertices;
//        coneMesh.triangles = triangles;
//        coneMesh.uv = uvs;
//        coneMesh.RecalculateBounds();
//        coneMesh.RecalculateNormals();
//    }
//}
using UnityEngine;
using System.Collections.Generic;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class SC_VisionConeCasting : MonoBehaviour
{
    public bool bOnlyMeshable = false;
    public int iBossTagsPhase2 = 0;

    [Header("Matériau & Field of View")]
    [SerializeField] private Material mVisionCone;
    [SerializeField] private SC_FieldOfView scFieldView;
    [SerializeField] private Material mDetectedCone;
    [SerializeField] private Material mHeardCone;

    [Header("Params")]
    [SerializeField] private int coneResolution = 30;
    [SerializeField] private LayerMask groundMask;
    [SerializeField] private LayerMask obstructionMask;
    [SerializeField] private float guardVerticalOffset = 0f;
    [SerializeField] private float farPointExtraOffset = 0f;
    [SerializeField] private float offsetAmount = 0f;
    [SerializeField] private int heightSegments = 3;
    [SerializeField] private float smoothThreshold = 0.5f;

    private Mesh coneMesh;
    private MeshFilter meshFilter;
    private MeshRenderer coneRenderer;

    private int rings, sideCount;
    private Vector3[] baseOffsets;
    private List<int> sideTris;
    private float farRadius;

    private void Awake()
    {
        meshFilter = GetComponent<MeshFilter>();
        coneRenderer = GetComponent<MeshRenderer>();
        coneMesh = new Mesh();
        coneMesh.MarkDynamic();
        meshFilter.mesh = coneMesh;
        if (mVisionCone && scFieldView.isBoss) coneRenderer.material = mVisionCone;

        rings = heightSegments;
        sideCount = rings * coneResolution;
        float halfRad = scFieldView.FAngle * Mathf.Deg2Rad * 0.5f;
        farRadius = scFieldView.FRadius * Mathf.Tan(halfRad);

        baseOffsets = new Vector3[coneResolution];
        for (int i = 0; i < coneResolution; i++)
        {
            float a = 2 * Mathf.PI * i / coneResolution;
            baseOffsets[i] = new Vector3(Mathf.Cos(a), 0, Mathf.Sin(a));
        }

        sideTris = new List<int>((rings - 1) * coneResolution * 6);
        for (int r = 0; r < rings - 1; r++)
            for (int j = 0; j < coneResolution; j++)
            {
                int c = r * coneResolution + j;
                int n = c + coneResolution;
                int j2 = (j + 1) % coneResolution;
                int c2 = r * coneResolution + j2;
                int n2 = c2 + coneResolution;
                sideTris.AddRange(new[] { c, n, n2, c, n2, c2 });
            }

        coneMesh.vertices = new Vector3[sideCount + coneResolution + 1];
        coneMesh.triangles = sideTris.ToArray();
        coneMesh.uv = new Vector2[sideCount + coneResolution + 1];
        coneMesh.RecalculateNormals();
        coneMesh.RecalculateBounds();
    }

    private void Update()
    {
        BuildCone();
        if (!bOnlyMeshable) UpdateMaterial();
    }

    private void UpdateMaterial()
    {
        if (scFieldView.BCanSee) coneRenderer.material = mDetectedCone;
        else if (scFieldView.bHasHeard) coneRenderer.material = mHeardCone;
        else coneRenderer.material = mVisionCone;
    }

    private void BuildCone()
    {
        Vector3 guardPos = transform.position + Vector3.up * guardVerticalOffset;

        // 1. farPoint
        Vector3 tent = guardPos + transform.forward * scFieldView.FRadius;
        Vector3 farPoint;
        Ray down = new Ray(tent + Vector3.up * 10f, Vector3.down);
        if (Physics.Raycast(down, out var gh, 20f, groundMask))
            farPoint = gh.point;
        else { farPoint = tent; farPoint.y = guardPos.y; }
        farPoint += transform.forward * farPointExtraOffset;

        // 2. farCircle
        var farCircle = new Vector3[coneResolution];
        for (int i = 0; i < coneResolution; i++)
        {
            Vector3 wb = farPoint + baseOffsets[i] * farRadius;
            Vector3 dirOff = Vector3.ProjectOnPlane((guardPos - farPoint), Vector3.up).normalized;
            float dot = Vector3.Dot((wb - farPoint).normalized, dirOff);
            if (dot > 0) wb += dirOff * offsetAmount * dot;

            Vector3 rd = (wb - guardPos).normalized;
            if (Physics.Raycast(guardPos, rd, out var hit, scFieldView.FRadius, obstructionMask))
                farCircle[i] = hit.point;
            else farCircle[i] = wb;
        }

        // 3. smooth
        for (int i = 0; i < coneResolution; i++)
        {
            int n = (i + 1) % coneResolution;
            float dy = Mathf.Abs(farCircle[i].y - farCircle[n].y);
            if (dy > smoothThreshold)
            {
                float av = (farCircle[i].y + farCircle[n].y) * 0.5f;
                if (farCircle[i].y < farCircle[n].y) farCircle[i].y = av;
                else farCircle[n].y = av;
            }
        }

        // 4. combined verts+UVs
        int total = sideCount + coneResolution + 1;
        var verts = new Vector3[total];
        var uvA = new Vector2[total];
        int idx2 = 0;

        // side
        for (int r = 0; r < rings; r++)
        {
            float t = r / (float)(rings - 1);
            for (int j = 0; j < coneResolution; j++)
            {
                Vector3 wP = Vector3.Lerp(farCircle[j], guardPos, t);
                verts[idx2] = transform.InverseTransformPoint(wP);
                float u = j / (float)(coneResolution - 1);
                float d = Vector3.Distance(new Vector3(wP.x, 0, wP.z), new Vector3(guardPos.x, 0, guardPos.z));
                float v = d / scFieldView.FRadius;
                uvA[idx2++] = new Vector2(u, v);
            }
        }

        // cap (mirror Y)
        int start = idx2;
        for (int i = 0; i < coneResolution; i++)
        {
            Vector3 pos = new Vector3(farCircle[i].x, farPoint.y, farCircle[i].z);
            verts[idx2] = transform.InverseTransformPoint(pos);
            float u = i / (float)(coneResolution - 1);
            float d = Vector3.Distance(new Vector3(pos.x, 0, pos.z), new Vector3(guardPos.x, 0, guardPos.z));
            uvA[idx2++] = new Vector2(u, d / scFieldView.FRadius);
        }

        // center
        verts[idx2] = transform.InverseTransformPoint(guardPos);
        uvA[idx2] = new Vector2(0.5f, 0f);

        // 5. assemble tris
        var tlist = new List<int>(sideTris);
        for (int j = 0; j < coneResolution; j++)
        {
            int n = (j + 1) % coneResolution;
            tlist.Add(j); tlist.Add(start + j); tlist.Add(start + n);
            tlist.Add(j); tlist.Add(start + n); tlist.Add(n);
        }
        for (int j = 0; j < coneResolution; j++)
        {
            int n = (j + 1) % coneResolution;
            tlist.Add(total - 1); tlist.Add(start + n); tlist.Add(start + j);
        }

        // 6. Upload
        coneMesh.Clear();
        coneMesh.vertices = verts;
        coneMesh.uv = uvA;
        coneMesh.triangles = tlist.ToArray();
        coneMesh.RecalculateNormals();
        coneMesh.RecalculateBounds();
    }
}