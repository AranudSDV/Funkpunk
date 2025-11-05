using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

[ExecuteAlways]
public class SC_GridManager : MonoBehaviour
{
    [Header("Grid")]
    public int gridSizeX = 100;
    public int gridSizeY = 100;
    public int Subdiv = 4;
    public float VisibilityRadius = 5f;
    public float VisibilityEdgeStart = 0.5f;
    private int resX, resY;
    private float WorldSubW = 1f;

    [Header("Player")]
    public GameObject player;
    public float PlayerCellEdgeSmooth = 0.2f; // 0..1 : portion avant que le fade commence
    public float PlayerIllumBleed = 1.0f;     // distance en world units au-delà de la moitié de la cellule

    [Header("Collision")]
    public LayerMask blockedLayer;
    public float ColliderBleed = 0.1f;        // world units
    public float ColliderEdgeSmooth = 0.2f;   // 0..1 : portion avant que le fade commence

    [Header("GPU")]
    public ComputeShader GridMaker;
    public RenderTexture collisionRT; // assignées dans l'inspector
    public RenderTexture maskRT;

    // kernel indices cache (optionnel)
    private int kBake = -1;
    private int kGrid = -1;

    void OnEnable()
    {
        InitGrid();
        EnsureRTConsistency();
        BakeCollisionGPU();
        UpdateMaskGPU();
    }

    void Update()
    {
        UpdateMaskGPU();
    }

    void InitGrid()
    {
        gridSizeX = Mathf.RoundToInt(transform.localScale.x);
        gridSizeY = Mathf.RoundToInt(transform.localScale.y);
        Subdiv = Mathf.Max(1, Subdiv);

        resX = gridSizeX * Subdiv;
        resY = gridSizeY * Subdiv;

        WorldSubW = (float)gridSizeX / resX;
    }

    void EnsureRTConsistency()
    {
        if (maskRT != null && (maskRT.width != resX || maskRT.height != resY))
        {
            maskRT.Release();
            maskRT.width = resX;
            maskRT.height = resY;
            maskRT.enableRandomWrite = true;
            maskRT.Create();
        }

        if (collisionRT != null && (collisionRT.width != resX || collisionRT.height != resY))
        {
            collisionRT.Release();
            collisionRT.width = resX;
            collisionRT.height = resY;
            collisionRT.enableRandomWrite = true;
            collisionRT.Create();
        }
    }

    [ContextMenu("Bake Collision GPU")]
    public void BakeCollisionGPU()
    {
        if (GridMaker == null || collisionRT == null) return;

        Collider[] cols = Physics.OverlapBox(
            transform.position + new Vector3(gridSizeX / 2f, 1f, gridSizeY / 2f),
            new Vector3(gridSizeX / 2f, 1f, gridSizeY / 2f),
            Quaternion.identity,
            blockedLayer
        );

        int count = Mathf.Max(0, cols.Length);
        Vector4[] data = new Vector4[count];

        for (int i = 0; i < count; i++)
        {
            Bounds b = cols[i].bounds;
            // pack: center.x, center.z, halfExt.x, halfExt.z
            data[i] = new Vector4(b.center.x, b.center.z, b.extents.x, b.extents.z);
        }

        ComputeBuffer buf = null;
        if (count > 0)
        {
            buf = new ComputeBuffer(count, sizeof(float) * 4);
            buf.SetData(data, 0, 0, count);
        }

        // safe kernel lookup
        try { kBake = GridMaker.FindKernel("BakeCollision"); }
        catch { if (buf != null) buf.Release(); return; }

        if (buf != null) GridMaker.SetBuffer(kBake, "Colliders", buf);

        GridMaker.SetInt("ColliderCount", count);
        GridMaker.SetFloat("ColliderBleed", ColliderBleed);
        GridMaker.SetFloat("ColliderEdgeSmooth", ColliderEdgeSmooth);
        GridMaker.SetFloat("GridPosX", transform.position.x);
        GridMaker.SetFloat("GridPosZ", transform.position.z);
        GridMaker.SetFloat("WorldSubW", WorldSubW);
        GridMaker.SetTexture(kBake, "CollisionRT", collisionRT);

        int tx = Mathf.CeilToInt((float)resX / 8f);
        int ty = Mathf.CeilToInt((float)resY / 8f);
        GridMaker.Dispatch(kBake, tx, ty, 1);

        if (buf != null) buf.Release();
    }

    public void UpdateMaskGPU()
    {
        if (GridMaker == null || maskRT == null || collisionRT == null || player == null) return;

        // compute front cell here (rounded direction -> diagonal supported)
        Vector3 p = player.transform.position;
        Vector3 f = player.transform.forward;

        // project forward onto XZ plane and normalize
        Vector2 forward2 = new Vector2(f.x, f.z);
        if (forward2.sqrMagnitude < 1e-6f)
            forward2 = new Vector2(0f, 1f); // fallback

        forward2.Normalize();

        // round to nearest integer direction (supports diagonals)
        int fx = Mathf.RoundToInt(forward2.x);
        int fz = Mathf.RoundToInt(forward2.y);
        // if zero (very small), fallback to dominant axis sign
        if (fx == 0 && fz == 0)
        {
            fx = (Mathf.Abs(forward2.x) > Mathf.Abs(forward2.y)) ? (forward2.x > 0 ? 1 : -1) : 0;
            fz = (Mathf.Abs(forward2.y) > Mathf.Abs(forward2.x)) ? (forward2.y > 0 ? 1 : -1) : 0;
            if (fx == 0 && fz == 0) fz = 1;
        }

        // compute player cell in grid coordinates (pixel space -> cell index)
        Vector2 gridOrigin = new Vector2(transform.position.x, transform.position.z);
        Vector2 playerPos2D = new Vector2(p.x, p.z);
        Vector2 playerLocal = (playerPos2D - gridOrigin) / WorldSubW;
        Vector2 playerPixel = playerLocal; // pixel space
        Vector2 playerCellF = playerPixel / Subdiv;
        int playerCellX = Mathf.FloorToInt(playerCellF.x);
        int playerCellY = Mathf.FloorToInt(playerCellF.y);

        int frontCellX = playerCellX + fx;
        int frontCellY = playerCellY + fz;

        // safe kernel lookup
        try { kGrid = GridMaker.FindKernel("GridCompute"); }
        catch { return; }

        GridMaker.SetTexture(kGrid, "Result", maskRT);
        GridMaker.SetTexture(kGrid, "CollisionMask", collisionRT);

        // send player as world X,Z in PlayerPos.xy
        GridMaker.SetVector("PlayerPos", new Vector4(p.x, 0f, p.z, 0f));
        GridMaker.SetVector("PlayerForward", new Vector4(f.x, 0f, f.z, 0f));

        // also pass front cell coords (ints)
        GridMaker.SetInt("FrontCellX", frontCellX);
        GridMaker.SetInt("FrontCellY", frontCellY);

        GridMaker.SetFloat("GridPosX", transform.position.x);
        GridMaker.SetFloat("GridPosZ", transform.position.z);
        GridMaker.SetFloat("WorldSubW", WorldSubW);
        GridMaker.SetInt("Subdiv", Subdiv);
        GridMaker.SetFloat("VisibilityRadius", VisibilityRadius);
        GridMaker.SetFloat("VisibilityEdgeStart", VisibilityEdgeStart);
        GridMaker.SetFloat("PlayerCellEdgeSmooth", PlayerCellEdgeSmooth);
        GridMaker.SetFloat("PlayerIllumBleed", PlayerIllumBleed);

        int tx = Mathf.CeilToInt((float)resX / 8f);
        int ty = Mathf.CeilToInt((float)resY / 8f);
        GridMaker.Dispatch(kGrid, tx, ty, 1);
    }
}

#if UNITY_EDITOR
[CustomEditor(typeof(SC_GridManager))]
public class SC_GridManagerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
        SC_GridManager gm = (SC_GridManager)target;

        GUILayout.Space(6);
        if (GUILayout.Button("Bake Collision GPU"))
            gm.BakeCollisionGPU();

        if (GUILayout.Button("Force Update Mask GPU"))
            gm.UpdateMaskGPU();
    }
}
#endif
