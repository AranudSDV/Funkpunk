using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshRectVision : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    [SerializeField] private Material[] mVisionRect;
    [SerializeField] private int iVisionRectResolution = 120; //how the vision cone is made up => with triangles, the +, the neatiest it will look
    private Mesh VisionRectMesh;
    private MeshFilter RectMeshFilter;
    private MeshRenderer RectRenderer;
    [SerializeField] private LayerMask LMObstructionMask;

    private void Start()
    {
        RectRenderer = this.gameObject.AddComponent<MeshRenderer>();
        RectRenderer.material = null;
        RectMeshFilter = this.gameObject.AddComponent<MeshFilter>();
        VisionRectMesh = new Mesh();
    }
    public void DrawVisionBait(Vector3 orientationVect)
    {
        int[] triangles = new int[(iVisionRectResolution - 1) * 3];
        Vector3[] Vertices = new Vector3[iVisionRectResolution + 1];
        Vertices[0] = Vector3.zero;
        float fCurrentAngle = 30f;
        fCurrentAngle *= Mathf.Deg2Rad;
        float Sine;
        float Cosine;
        for (int i = 0; i < iVisionRectResolution; i++)
        {
            Sine = Mathf.Sin(fCurrentAngle);
            Cosine = Mathf.Cos(fCurrentAngle);
            Vector3 RaycastDirection = (transform.forward * Cosine) + (transform.right * Sine);
            Vector3 VertForward = (Vector3.forward * Cosine) + (Vector3.right * Sine);
            float distanceRadius = 2f;
            Vector3 distanceFromPlayer = transform.position + orientationVect * 3;
            if (scPlayer.BBad)
            {
                distanceRadius = 4f;
            }
            else if (scPlayer.BGood)
            {
                distanceRadius = 5f;
            }
            else if (scPlayer.BPerfect)
            {
                distanceRadius = 6f;
            }
            if (Physics.Raycast(distanceFromPlayer, RaycastDirection, out RaycastHit hit, distanceRadius, LMObstructionMask))
            {
                Vertices[i + 1] = VertForward * hit.distance;
            }
            else
            {
                Vertices[i + 1] = VertForward * distanceRadius;
            }
        }
        for (int i = 0, j = 0; i < triangles.Length; i += 3, j++)
        {
            triangles[i] = 0;
            triangles[i + 1] = j + 1;
            triangles[i + 2] = j + 2;
        }
        VisionRectMesh.Clear();
        VisionRectMesh.vertices = Vertices;
        VisionRectMesh.triangles = triangles;
        RectMeshFilter.mesh = VisionRectMesh;
        if (scPlayer.BBad)
        {
            RectRenderer.material = mVisionRect[0];
        }
        else if (scPlayer.BGood)
        {
            RectRenderer.material = mVisionRect[1];
        }
        else if (scPlayer.BPerfect)
        {
            RectRenderer.material = mVisionRect[2];
        }
        else
        {
            RectRenderer.material = null;
        }
        Debug.Log("RectTriangles");
    }
}
