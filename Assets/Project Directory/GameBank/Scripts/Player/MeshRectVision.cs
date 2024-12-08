using System.Collections;
using System.Collections.Generic;
using System.Numerics;
using UnityEngine;

public class MeshRectVision : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    /*[SerializeField] private Material[] mVisionRect;
    private Mesh VisionRectMesh;
    private MeshFilter RectMeshFilter;
    private MeshRenderer RectRenderer;
    [SerializeField] private LayerMask LMObstructionMask;
    private bool[] bools = new bool[3];

    private void Start()
    {
        RectRenderer = this.gameObject.AddComponent<MeshRenderer>();
        RectRenderer.material = null;
        RectMeshFilter = this.gameObject.AddComponent<MeshFilter>();
        VisionRectMesh = new Mesh();
        bools[0] = false;
        bools[1] = false;
        bools[2] = false;
    }

    private void DrawRectangle(UnityEngine.Vector3 orientationVect)
    {
        // Define the rectangle's size
        float width = 1f; // Adjust as needed
        float height = 1f; // Adjust as needed
        float y = -1f;
        float x = 3f;
        if (scPlayer.BBad && bools[0])
        {
            x = 3f;
        }
        else if (scPlayer.BGood && bools[1])
        {
            x = 4f;
        }
        else if (scPlayer.BPerfect && bools[2])
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
            if (Physics.Raycast(transform.position, scPlayer.lastMoveDirection,3f, LMObstructionMask))
            {
                bools[0] = false;
                bools[1] = false;
                bools[2] = false;
            }
            else if (Physics.Raycast(transform.position, scPlayer.lastMoveDirection, 4f, LMObstructionMask))
            {
                bools[0] = true;
                bools[1] = false;
                bools[2] = false;
            }
            else if (Physics.Raycast(transform.position, scPlayer.lastMoveDirection, 5f, LMObstructionMask))
            {
                bools[0] = true;
                bools[1] = true;
                bools[2] = false;
            }
            else
            {
                bools[0] = true;
                bools[1] = true;
                bools[2] = true;
            }
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
        else
        {
            VisionRectMesh.Clear();
            RectMeshFilter.mesh = null;
        }
    }*/
}
