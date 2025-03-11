using System.Collections;
using System.Collections.Generic;
using UnityEngine;



[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class SC_VisionConeCasting : MonoBehaviour
{
    [SerializeField] private Material mVisionCone;
    [SerializeField] private SC_FieldOfView scFieldView;  // Contient FAngle (en degrés) et FRadius (distance max)
    [SerializeField] private int coneResolution = 30;       // Nombre de segments pour la base du cône
    [SerializeField] private LayerMask groundMask;          // Masque pour identifier le sol

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
        Debug.Log("visioncone null");
            meshRenderer.material = mVisionCone;

    }

    private void Update()
    {
        BuildCone();
    }

    private void BuildCone()
    {
        // 1. Définir l'apex du cône (par exemple la position actuelle de l'objet)
        Vector3 apex = transform.position;
        
        // 2. Déterminer le centre de la base en lançant un rayon depuis l'apex dans la direction du regard
        // Ici, on utilise transform.forward pour la direction du cône.
        float maxDistance = scFieldView.FRadius;
        Ray ray = new Ray(apex, transform.forward);
        Vector3 baseCenter;
        if (Physics.Raycast(ray, out RaycastHit hit, maxDistance, groundMask))
        {
            baseCenter = hit.point;
        }
        else
        {
            // Si aucun hit, on projette simplement le cône jusqu'au maxDistance, et on force le sol (y = 0)
            baseCenter = apex + transform.forward * maxDistance;
            baseCenter.y = 0f;
        }
        
        // 3. Calculer la hauteur du cône et en déduire le rayon de la base à partir de l'angle de vision
        float height = Vector3.Distance(apex, baseCenter);
        float halfAngleRad = scFieldView.FAngle * Mathf.Deg2Rad / 2f;
        float baseRadius = height * Mathf.Tan(halfAngleRad);
        
        // 4. Générer les vertices
        // Le vertex 0 correspond à l'apex.
        // Les vertices suivants forment la base (cercle)
        Vector3[] vertices = new Vector3[coneResolution + 1];
        // On convertit en espace local pour que le mesh soit cohérent avec l'objet
        vertices[0] = transform.InverseTransformPoint(apex);
        
        // Pour la base, on suppose un sol horizontal, donc on utilise Vector3.up pour définir la plaque.
        // On définit un repère local sur le sol : on peut prendre transform.right et transform.forward
        // Projetés sur le sol pour être sûrs d'avoir un cercle horizontal.
        Vector3 right = Vector3.ProjectOnPlane(transform.right, Vector3.up).normalized;
        Vector3 forward = Vector3.ProjectOnPlane(transform.forward, Vector3.up).normalized;
        
        for (int i = 0; i < coneResolution; i++)
        {
            float angle = 2 * Mathf.PI * i / coneResolution;
            // Calculer l'offset sur le cercle
            Vector3 offset = right * Mathf.Cos(angle) + forward * Mathf.Sin(angle);
            offset *= baseRadius;
            // La position du vertex sur le sol est baseCenter + offset
            Vector3 vertexWorld = baseCenter + offset;
            vertices[i + 1] = transform.InverseTransformPoint(vertexWorld);
        }
        
        // 5. Construire les triangles
        // Chaque triangle relie l'apex (vertex 0) et deux vertices consécutifs du cercle
        int[] triangles = new int[coneResolution * 3];
        for (int i = 0; i < coneResolution; i++)
        {
            triangles[i * 3] = 0; // L'apex
            // Pour le cercle, on fait le wrap-around en fin de boucle
            triangles[i * 3 + 2] = i + 1;
            triangles[i * 3 + 1] = (i + 1) % coneResolution + 1;
        }
        
        // 6. Appliquer le mesh
        coneMesh.Clear();
        coneMesh.vertices = vertices;
        coneMesh.triangles = triangles;
        coneMesh.RecalculateBounds();
    }
}
