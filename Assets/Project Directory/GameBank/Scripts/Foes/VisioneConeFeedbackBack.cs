using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class VisioneConeFeedbackBack : MonoBehaviour
{
    [SerializeField] private Material mVisionCone;
    [SerializeField] private SC_FieldOfView scFieldView;
    private float fVisionAngle;
    [SerializeField] private int iVisionConeResolution = 120;
    private Mesh VisionConeMesh;
    private MeshFilter ConeMeshFilter;
    public MeshRenderer ConeRenderer;
    public bool initialized = false; 

    private void Start()
    {
        ConeRenderer = transform.AddComponent<MeshRenderer>();
        ConeRenderer.material = mVisionCone;
        ConeMeshFilter = transform.AddComponent<MeshFilter>();
        VisionConeMesh = new Mesh();
        fVisionAngle = scFieldView.FAngle;
        fVisionAngle *= Mathf.Deg2Rad;
        ConeRenderer.enabled = false;
        initialized = true;
    }

    private void Update()
    {
        DrawVisionCone();
    }

    private void DrawVisionCone()
    {
        int[] triangles = new int[(iVisionConeResolution - 1) * 3];
        Vector3[] Vertices = new Vector3[iVisionConeResolution + 1];
        Vertices[0] = Vector3.zero;
        float fCurrentAngle = -fVisionAngle / 2;
        float fAngleIcrement = fVisionAngle / (iVisionConeResolution - 1);
        float Sine;
        float Cosine;
        for (int i = 0; i < iVisionConeResolution; i++)
        {
            Sine = Mathf.Sin(fCurrentAngle);
            Cosine = Mathf.Cos(fCurrentAngle);
            Vector3 RaycastDirection = (transform.forward * Cosine) + (transform.right * Sine);
            Vector3 VertForward = (Vector3.forward * Cosine) + (Vector3.right * Sine);
            if (Physics.Raycast(transform.position, RaycastDirection, out RaycastHit hit, scFieldView.FRadius, scFieldView.LMObstructionMask))
            {
                Vertices[i + 1] = VertForward * hit.distance;
            }
            else
            {
                Vertices[i + 1] = VertForward * scFieldView.FRadius;
            }
            fCurrentAngle += fAngleIcrement;
        }
        for (int i = 0, j = 0; i < triangles.Length; i += 3, j++)
        {
            triangles[i] = 0;
            triangles[i + 1] = j + 1;
            triangles[i + 2] = j + 2;
        }
        VisionConeMesh.Clear();
        VisionConeMesh.vertices = Vertices;
        VisionConeMesh.triangles = triangles;
        ConeMeshFilter.mesh = VisionConeMesh;
    }
}
