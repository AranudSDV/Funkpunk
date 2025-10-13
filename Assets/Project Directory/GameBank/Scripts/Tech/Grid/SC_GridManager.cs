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
    public int Subdiv = 1;
    public float VisibilityRadius = 5f;
    public float VisibilityEdgeStart = 0.5f;
    private int resX, resY;
    private float WorldSubW = 1f;

    [Header("Player")]
    public GameObject player;
    public float PlayerCellEdgeSmooth = 0.2f;
    public float PlayerIllumBleed = 1.0f;

    [Header("Collision")]
    public LayerMask blockedLayer;
    public float ColliderBleed = 0.1f;
    public float ColliderEdgeSmooth = 0.2f;

    [Header("GPU")]
    public ComputeShader GridMaker;
    public RenderTexture collisionRT;
    public RenderTexture maskRT;

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

        Vector3 boxCenter = transform.position + new Vector3(gridSizeX / 2f, 1f, gridSizeY / 2f);
        Vector3 boxHalfExt = new Vector3(gridSizeX / 2f, 1f, gridSizeY / 2f);

        Collider[] cols = Physics.OverlapBox(boxCenter, boxHalfExt, Quaternion.identity, blockedLayer);
        int count = Mathf.Max(0, cols.Length);
        Vector4[] data = new Vector4[count];

        for (int i = 0; i < count; i++)
        {
            Bounds b = cols[i].bounds;
            data[i] = new Vector4(b.center.x, b.center.z, b.extents.x, b.extents.z);
        }

        ComputeBuffer buf = null;
        if (count > 0)
        {
            buf = new ComputeBuffer(count, sizeof(float) * 4);
            buf.SetData(data, 0, 0, count);
        }

        int kernel = GridMaker.FindKernel("BakeCollision");

        if (buf != null) GridMaker.SetBuffer(kernel, "Colliders", buf);

        GridMaker.SetInt("ColliderCount", count);
        GridMaker.SetFloat("ColliderBleed", ColliderBleed);
        GridMaker.SetFloat("ColliderEdgeSmooth", ColliderEdgeSmooth);
        GridMaker.SetFloat("GridPosX", transform.position.x);
        GridMaker.SetFloat("GridPosZ", transform.position.z);
        GridMaker.SetFloat("WorldSubW", WorldSubW);
        GridMaker.SetTexture(kernel, "CollisionRT", collisionRT);

        int tx = Mathf.CeilToInt((float)resX / 8f);
        int ty = Mathf.CeilToInt((float)resY / 8f);
        GridMaker.Dispatch(kernel, tx, ty, 1);

        if (buf != null) buf.Release();
    }

    public void UpdateMaskGPU()
    {
        if (GridMaker == null || maskRT == null || collisionRT == null || player == null) return;

        int kernel = GridMaker.FindKernel("GridCompute");

        GridMaker.SetTexture(kernel, "Result", maskRT);
        GridMaker.SetTexture(kernel, "CollisionMask", collisionRT);

        Vector3 p = player.transform.position;
        Vector3 f = player.transform.forward;

        GridMaker.SetVector("PlayerPos", new Vector4(p.x, 0f, p.z, 0f));
        GridMaker.SetVector("PlayerForward", new Vector4(f.x, 0f, f.z, 0f));
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
        GridMaker.Dispatch(kernel, tx, ty, 1);
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
        if(GUILayout.Button("Bake Collision GPU")) gm.BakeCollisionGPU();
        if(GUILayout.Button("Force Update Mask GPU")) gm.UpdateMaskGPU();
    }
}
#endif
