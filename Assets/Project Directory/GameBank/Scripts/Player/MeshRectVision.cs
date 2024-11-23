using System.Collections;
using System.Collections.Generic;
using System.Numerics;
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
    private float fVisionAngle = 30f;

    private void Start()
    {
        RectRenderer = this.gameObject.AddComponent<MeshRenderer>();
        RectRenderer.material = null;
        RectMeshFilter = this.gameObject.AddComponent<MeshFilter>();
        VisionRectMesh = new Mesh();
        fVisionAngle *= Mathf.Deg2Rad;
    }
    public void DrawVisionBait(UnityEngine.Vector3 orientationVect)
    {
        int[] triangles = new int[(iVisionRectResolution - 1) * 3];
        UnityEngine.Vector3[] Vertices = new UnityEngine.Vector3[iVisionRectResolution + 1];
        Vertices[0] = UnityEngine.Vector3.zero;
        float fCurrentAngle = -fVisionAngle / 2;
        float fAngleIcrement = fVisionAngle / (iVisionRectResolution - 1);
        float Sine;
        float Cosine;
        for (int i = 0; i < iVisionRectResolution; i++)
        {
            Sine = Mathf.Sin(fCurrentAngle);
            Cosine = Mathf.Cos(fCurrentAngle);
            UnityEngine.Vector3 vectNext = orientationVect;
            if (orientationVect == transform.forward)
            {
                vectNext = transform.right;
            }
            else if (orientationVect == transform.right)
            {
                vectNext = UnityEngine.Vector3.back;
            }
            else if (orientationVect == UnityEngine.Vector3.back)
            {
                vectNext = UnityEngine.Vector3.left;
            }
            else if (orientationVect == UnityEngine.Vector3.left)
            {
                vectNext = transform.forward;
            }
            UnityEngine.Vector3 RaycastDirection = (orientationVect * Cosine) + (vectNext * Sine);
            UnityEngine.Vector3 VertForward = (orientationVect * Cosine) + (vectNext * Sine);
            float distanceRadius = 2f;
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
            if (Physics.Raycast(transform.position, RaycastDirection, out RaycastHit hit, distanceRadius, LMObstructionMask))
            {
                Vertices[i + 1] = VertForward * hit.distance;
            }
            else
            {
                Vertices[i + 1] = VertForward * distanceRadius;
            }
            fCurrentAngle += fAngleIcrement;
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
            RectRenderer.material = mVisionRect[3];
        }
    }

    private void DrawRectangle(UnityEngine.Vector3 orientationVect)
    {
        // Define the rectangle's size
        float width = 1f; // Adjust as needed
        float height = 1f; // Adjust as needed
        float y = -1f;
        float x = 3f;
        if (scPlayer.BBad)
        {
            x = 3f;
        }
        else if (scPlayer.BGood)
        {
            x = 4f;
        }
        else if (scPlayer.BPerfect)
        {
            x = 5f;
        }
        else
        {
            x = 2f;
        }

        // Define the vertices of the rectangle (centered at the origin)
        UnityEngine.Vector3[] vertices = new UnityEngine.Vector3[4]
        {
            new UnityEngine.Vector3(-width / 2, y, -height / 2), // Bottom-left
            new UnityEngine.Vector3(width / 2, y, -height / 2),  // Bottom-right
            new UnityEngine.Vector3(-width / 2,y, height / 2),  // Top-left
            new UnityEngine.Vector3(width / 2, y, height / 2)    // Top-right
        };

        if(orientationVect == UnityEngine.Vector3.back || orientationVect == transform.forward)
        {
            if (orientationVect == transform.forward)
            {
                x *= 1f;
            }
            else if (orientationVect == UnityEngine.Vector3.back)
            {
                x *= -1f;
            }
            vertices[0] = new UnityEngine.Vector3(-width / 2, y, x);
            vertices[1] = new UnityEngine.Vector3(width / 2, y, x);
            vertices[2] = new UnityEngine.Vector3(-width / 2, y, x + height);
            vertices[3] = new UnityEngine.Vector3(width / 2, y, x + height);
        }
        else if(orientationVect == transform.right || orientationVect == UnityEngine.Vector3.left)
        {
            if (orientationVect == transform.right)
            {
                x *= 1f;
            }
            else if (orientationVect == UnityEngine.Vector3.left)
            {
                x *= -1f;
            }
            vertices[0] = new UnityEngine.Vector3(x, y, -height / 2);
            vertices[1] = new UnityEngine.Vector3(x+ width, y, -height / 2);
            vertices[2] = new UnityEngine.Vector3(x, y, height / 2);
            vertices[3] = new UnityEngine.Vector3(x + width, y, height / 2);
        }

        // Define the two triangles that form the rectangle
        int[] triangles = new int[6]
        {
            0, 2, 1, // First triangle (Bottom-left, Top-left, Bottom-right)
            1, 2, 3  // Second triangle (Bottom-right, Top-left, Top-right)
        };

        // Update the mesh
        VisionRectMesh.Clear();
        VisionRectMesh.vertices = vertices;
        VisionRectMesh.triangles = triangles;

        // Optionally add UVs for texture mapping
        UnityEngine.Vector2[] uvs = new UnityEngine.Vector2[4]
        {
            new UnityEngine.Vector2(0, 0), // Bottom-left
            new UnityEngine.Vector2(1, 0), // Bottom-right
            new UnityEngine.Vector2(0, 1), // Top-left
            new UnityEngine.Vector2(1, 1)  // Top-right
        };
        VisionRectMesh.uv = uvs;

        // Assign the updated mesh to the MeshFilter
        RectMeshFilter.mesh = VisionRectMesh;
    }

    // Call DrawRectangle instead of DrawVisionCone in Update
    private void Update()
    {
        if (scPlayer.bIsBaiting)
        {
            DrawRectangle(scPlayer.lastMoveDirection);

            if (scPlayer.BBad)
            {
                RectRenderer.material = mVisionRect[0];
            }
            else if(scPlayer.BGood)
            {
                RectRenderer.material = mVisionRect[1];
            }
            else if (scPlayer.BPerfect)
            {
                RectRenderer.material = mVisionRect[2];
            }
            else
            {
                RectRenderer.material = mVisionRect[3];
            }
        }
    }
}
