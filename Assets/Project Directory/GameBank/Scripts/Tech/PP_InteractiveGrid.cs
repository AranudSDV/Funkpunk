using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class PP_InteractiveGrid: MonoBehaviour
{
    [Header("Grid Settings")]
    public int gridSizeX = 100;
    public int gridSizeY = 100;
    public int subdivisions = 4;

    [Header("Player Illumination")]
    public Transform player;
    public float illuminationRadius = 1f;

    [Header("Collision Settings")]
    public LayerMask blockedLayer;

    private Texture2D maskTexture;
    private int resX, resY;

    // Data for obstacle groups
    private List<List<Vector2Int>> obstacleGroups;
    private List<Vector2> groupCentroids;
    private List<float> groupMaxDistances;

    void Start()
    {
        resX = gridSizeX * subdivisions;
        resY = gridSizeY * subdivisions;

        // Create and clear the mask texture
        maskTexture = new Texture2D(resX, resY, TextureFormat.RGBA32, false)
        {
            filterMode = FilterMode.Point,
            wrapMode = TextureWrapMode.Clamp
        };
        ClearTexture();

        // Bake static collision and compute groups
        UpdateCollisionMask();
        FindObstacleGroups();
        ApplyGroupGradients();

        maskTexture.Apply();  // Upload all SetPixel calls at once :contentReference[oaicite:0]{index=0}
    }

    void Update()
    {
        // Each frame: reset R & B, apply illumination and gradients
        ResetChannel(0);
        ResetChannel(2);
        UpdatePlayerIllumination();
        ApplyGroupGradients();
        maskTexture.Apply();  // Apply is expensive—batch your SetPixel calls :contentReference[oaicite:1]{index=1}
    }

    void ClearTexture()
    {
        Color clear = new Color(0, 0, 0, 1);
        for (int x = 0; x < resX; x++)
            for (int y = 0; y < resY; y++)
                maskTexture.SetPixel(x, y, clear);
    }

    void ResetChannel(int channel)
    {
        for (int x = 0; x < resX; x++)
            for (int y = 0; y < resY; y++)
            {
                Color c = maskTexture.GetPixel(x, y);
                c[channel] = 0;
                maskTexture.SetPixel(x, y, c);
            }
    }

    void UpdatePlayerIllumination()
    {
        Vector3 pos = player.position;
        int cx = Mathf.FloorToInt((pos.x - transform.position.x) / gridSizeX * resX);
        int cy = Mathf.FloorToInt((pos.z - transform.position.z) / gridSizeY * resY);
        float cellW = (float)gridSizeX / resX;
        float cellH = (float)gridSizeY / resY;
        int range = Mathf.CeilToInt(illuminationRadius / Mathf.Max(cellW, cellH));

        for (int x = cx - range; x <= cx + range; x++)
            for (int y = cy - range; y <= cy + range; y++)
                if (x >= 0 && x < resX && y >= 0 && y < resY)
                {
                    Vector3 world = new Vector3(
                        transform.position.x + (x + 0.5f) * cellW,
                        pos.y,
                        transform.position.z + (y + 0.5f) * cellH
                    );
                    if (Vector3.Distance(new Vector3(pos.x, 0, pos.z), new Vector3(world.x, 0, world.z)) <= illuminationRadius)
                    {
                        Color c = maskTexture.GetPixel(x, y);
                        c.r = 1;
                        maskTexture.SetPixel(x, y, c);
                    }
                }
    }

    void UpdateCollisionMask()
    {
        Vector3 center = transform.position + new Vector3(gridSizeX / 2f, 0, gridSizeY / 2f);
        Vector3 half = new Vector3(gridSizeX / 2f, 1, gridSizeY / 2f);
        Collider[] cols = Physics.OverlapBox(center, half, Quaternion.identity, blockedLayer);

        foreach (var col in cols)
        {
            Bounds b = col.bounds;
            int sx = Mathf.Clamp(Mathf.FloorToInt((b.min.x - transform.position.x) / gridSizeX * resX), 0, resX - 1);
            int ex = Mathf.Clamp(Mathf.CeilToInt((b.max.x - transform.position.x) / gridSizeX * resX) - 1, 0, resX - 1);
            int sy = Mathf.Clamp(Mathf.FloorToInt((b.min.z - transform.position.z) / gridSizeY * resY), 0, resY - 1);
            int ey = Mathf.Clamp(Mathf.CeilToInt((b.max.z - transform.position.z) / gridSizeY * resY) - 1, 0, resY - 1);

            for (int x = sx; x <= ex; x++)
                for (int y = sy; y <= ey; y++)
                {
                    Color c = maskTexture.GetPixel(x, y);
                    c.g = 1;
                    maskTexture.SetPixel(x, y, c);
                }
        }
    }

    void FindObstacleGroups()
    {
        bool[,] visited = new bool[resX, resY];
        obstacleGroups = new List<List<Vector2Int>>();
        groupCentroids = new List<Vector2>();
        groupMaxDistances = new List<float>();

        for (int x = 0; x < resX; x++)
            for (int y = 0; y < resY; y++)
            {
                if (!visited[x, y] && maskTexture.GetPixel(x, y).g > 0.5f)
                {
                    var group = new List<Vector2Int>();
                    var queue = new Queue<Vector2Int>();
                    queue.Enqueue(new Vector2Int(x, y));
                    visited[x, y] = true;

                    while (queue.Count > 0)
                    {
                        var cell = queue.Dequeue();
                        group.Add(cell);
                        var dirs = new[] { Vector2Int.up, Vector2Int.down, Vector2Int.left, Vector2Int.right };
                        foreach (var d in dirs)
                        {
                            int nx = cell.x + d.x, ny = cell.y + d.y;
                            if (nx >= 0 && nx < resX && ny >= 0 && ny < resY
                                && !visited[nx, ny] && maskTexture.GetPixel(nx, ny).g > 0.5f)
                            {
                                visited[nx, ny] = true;
                                queue.Enqueue(new Vector2Int(nx, ny));
                            }
                        }
                    }

                    // Compute centroid & max distance
                    Vector2 sum = Vector2.zero;
                    float maxd = 0;
                    foreach (var c in group) sum += c;
                    var centroid = sum / group.Count;
                    foreach (var c in group) maxd = Mathf.Max(maxd, Vector2.Distance(c, centroid));

                    obstacleGroups.Add(group);
                    groupCentroids.Add(centroid);
                    groupMaxDistances.Add(maxd);
                }
            }
    }

    void ApplyGroupGradients()
    {
        for (int i = 0; i < obstacleGroups.Count; i++)
        {
            var group = obstacleGroups[i];
            var centroid = groupCentroids[i];
            var maxd = Mathf.Max(groupMaxDistances[i], 1f);
            foreach (var c in group)
            {
                float d = Vector2.Distance(c, centroid) / maxd;
                Color col = maskTexture.GetPixel(c.x, c.y);
                col.b = d;
                maskTexture.SetPixel(c.x, c.y, col);
            }
        }
    }
}
