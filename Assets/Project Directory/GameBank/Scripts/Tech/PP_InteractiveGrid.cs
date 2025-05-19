using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PP_InteractiveGrid : MonoBehaviour
{
    [Header("Grid & Plane Settings")]
    public int gridSizeX = 100;            // parent cells in X
    public int gridSizeY = 100;            // parent cells in Y
    public Vector3 gridOrigin = Vector3.zero;
    public int planeWidth = 100;           // world-units width
    public int planeHeight = 100;          // world-units height
    [Range(1, 4)]
    public int Subdiv = 1;                 // subdivisions per cell

    [Header("Player Illumination")]
    public GameObject player;
    public float illuminationRadius = 2f;

    [Header("Player Visibility")]
    public float VisibilityRadius = 5f;

    [Header("Collision Settings")]
    public LayerMask blockedLayer;
    [Range(0f, 1f)]
    public float coverageThreshold = 0.3f; // % overlap to mark

    [Header("Render Texture")]
    public RenderTexture renderTexture;

    private Texture2D maskTexture;
    private int resX, resY;
    private float worldSubW, worldSubH, subArea;

    void Start()
    {
        // compute subdivided resolution
        gridOrigin = transform.position;
        planeWidth = Mathf.RoundToInt(transform.localScale.x);
        planeHeight = Mathf.RoundToInt(transform.localScale.y);
        resX = gridSizeX * Subdiv;
        resY = gridSizeY * Subdiv;

        // sub-cell world size
        worldSubW = (float)planeWidth / resX;
        worldSubH = (float)planeHeight / resY;
        subArea = worldSubW * worldSubH;

        // create maskTexture
        maskTexture = new Texture2D(resX, resY, TextureFormat.RGBA32, false)
        {
            filterMode = FilterMode.Point,
            wrapMode = TextureWrapMode.Clamp
        };

        // bake static collision once
        UpdateCollisionMask();

        // initial dynamic update & blit
        ResetChannels();
        UpdatePlayerIllumination();
        UpdatePlayerVisibility();
        maskTexture.Apply();
        UpdateRenderTexture();
    }

    void Update()
    {
        ResetChannels();
        UpdatePlayerIllumination();
        UpdatePlayerVisibility();
        maskTexture.Apply();
        UpdateRenderTexture();
    }

    void ResetChannels()
    {
        for (int x = 0; x < resX; x++)
            for (int y = 0; y < resY; y++)
            {
                Color c = maskTexture.GetPixel(x, y);
                c.r = 0f;
                c.b = 0f;
                maskTexture.SetPixel(x, y, c);
            }
    }

    void UpdateCollisionMask()
    {
        // clear G
        for (int x = 0; x < resX; x++)
            for (int y = 0; y < resY; y++)
            {
                Color c = maskTexture.GetPixel(x, y);
                c.g = 0f;
                maskTexture.SetPixel(x, y, c);
            }

        // world AABB to gather colliders
        Vector3 center = gridOrigin + new Vector3(planeWidth / 2f, 0, planeHeight / 2f);
        Vector3 halfExtents = new Vector3(planeWidth / 2f, 1f, planeHeight / 2f);
        Collider[] cols = Physics.OverlapBox(center, halfExtents, Quaternion.identity, blockedLayer);

        foreach (var col in cols)
        {
            Bounds b = col.bounds;

            int minX = Mathf.Clamp(Mathf.FloorToInt((b.min.x - gridOrigin.x) / worldSubW), 0, resX - 1);
            int maxX = Mathf.Clamp(Mathf.FloorToInt((b.max.x - gridOrigin.x) / worldSubW), 0, resX - 1);
            int minY = Mathf.Clamp(Mathf.FloorToInt((b.min.z - gridOrigin.z) / worldSubH), 0, resY - 1);
            int maxY = Mathf.Clamp(Mathf.FloorToInt((b.max.z - gridOrigin.z) / worldSubH), 0, resY - 1);

            for (int sx = minX; sx <= maxX; sx++)
                for (int sy = minY; sy <= maxY; sy++)
                {
                    float x0 = gridOrigin.x + sx * worldSubW;
                    float x1 = x0 + worldSubW;
                    float z0 = gridOrigin.z + sy * worldSubH;
                    float z1 = z0 + worldSubH;

                    float ix0 = Mathf.Max(x0, b.min.x);
                    float ix1 = Mathf.Min(x1, b.max.x);
                    float iz0 = Mathf.Max(z0, b.min.z);
                    float iz1 = Mathf.Min(z1, b.max.z);
                    float ow = Mathf.Max(0f, ix1 - ix0);
                    float oh = Mathf.Max(0f, iz1 - iz0);
                    float overlap = ow * oh;

                    if (overlap / subArea >= coverageThreshold)
                    {
                        Color c = maskTexture.GetPixel(sx, sy);
                        c.g = 1f;
                        maskTexture.SetPixel(sx, sy, c);
                    }
                }
        }

        maskTexture.Apply();
    }

    void UpdatePlayerIllumination()
    {
        Vector3 pos = player.transform.position;
        int cx = Mathf.FloorToInt((pos.x - gridOrigin.x) / worldSubW);
        int cy = Mathf.FloorToInt((pos.z - gridOrigin.z) / worldSubH);
        int range = Mathf.CeilToInt(illuminationRadius / Mathf.Max(worldSubW, worldSubH));

        for (int x = cx - range; x <= cx + range; x++)
            for (int y = cy - range; y <= cy + range; y++)
                if (x >= 0 && x < resX && y >= 0 && y < resY)
                {
                    Vector3 wc = new Vector3(
                        gridOrigin.x + (x + 0.5f) * worldSubW,
                        pos.y,
                        gridOrigin.z + (y + 0.5f) * worldSubH
                    );
                    if (Vector3.Distance(new Vector3(pos.x, 0, pos.z), new Vector3(wc.x, 0, wc.z)) <= illuminationRadius)
                    {
                        Color c = maskTexture.GetPixel(x, y);
                        c.r = 1f;
                        maskTexture.SetPixel(x, y, c);
                    }
                }
    }

    void UpdatePlayerVisibility()
    {
        Vector3 pos = player.transform.position;
        int cx = Mathf.FloorToInt((pos.x - gridOrigin.x) / worldSubW);
        int cy = Mathf.FloorToInt((pos.z - gridOrigin.z) / worldSubH);
        int range = Mathf.CeilToInt(VisibilityRadius / Mathf.Max(worldSubW, worldSubH));

        for (int x = cx - range; x <= cx + range; x++)
            for (int y = cy - range; y <= cy + range; y++)
                if (x >= 0 && x < resX && y >= 0 && y < resY)
                {
                    Vector3 wc = new Vector3(
                        gridOrigin.x + (x + 0.5f) * worldSubW,
                        pos.y,
                        gridOrigin.z + (y + 0.5f) * worldSubH
                    );
                    if (Vector3.Distance(new Vector3(pos.x, 0, pos.z), new Vector3(wc.x, 0, wc.z)) <= VisibilityRadius)
                    {
                        Color c = maskTexture.GetPixel(x, y);
                        c.b = 1f;
                        maskTexture.SetPixel(x, y, c);
                    }
                }
    }

    void UpdateRenderTexture()
    {
        Graphics.Blit(maskTexture, renderTexture);
    }
}