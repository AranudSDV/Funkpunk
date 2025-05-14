using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PP_InteractiveGrid : MonoBehaviour
{
    [Header("Grid & Plane Settings")]
    public int gridSizeX = 100;  // Nombre de cellules en largeur
    public int gridSizeY = 100;  // Nombre de cellules en hauteur
    public Vector3 gridOrigin = Vector3.zero;  // Origine du plane (doit correspondre au coin inférieur gauche)
    public int planeWidth = 100;   // Dimension en X du plane (en unités monde)
    public int planeHeight = 100;  // Dimension en Y du plane (en unités monde)

    [Header("Player Illumination")]
    public GameObject player;            // Référence au joueur
    public float illuminationRadius = 1f; // Rayon d'illumination en mètres

    [Header("Collision Settings")]
    public LayerMask blockedLayer;       // Layer des obstacles à considérer

    [Header("Render Texture")]
    public RenderTexture renderTexture;  // RenderTexture assignée dans le shader

    private Texture2D maskTexture;       // Texture de masque (canal R : illumination, canal G : obstacles)

    void Start()
    {
        // On définit gridOrigin sur la position du GameObject.
        gridOrigin = transform.position;

        // Calculer la dimension du plane.
        // ATTENTION : Si vous utilisez un plane Unity par défaut (10x10), multipliez par 10.
        planeWidth = (int)(transform.localScale.x);  // À ajuster si nécessaire, ex: * 10
        planeHeight = (int)(transform.localScale.y);

        // Ici on suppose que chaque cellule est de 1m, donc la résolution de la grille correspond aux dimensions.
        gridSizeX = planeWidth;
        gridSizeY = planeHeight;

        // Création et initialisation de la Texture2D selon la résolution de la grille.
        maskTexture = new Texture2D(gridSizeX, gridSizeY, TextureFormat.RGBA32, false);
        maskTexture.filterMode = FilterMode.Point; // Pour éviter l'interpolation
        Color clearColor = new Color(0, 0, 0, 1);
        for (int x = 0; x < gridSizeX; x++)
        {
            for (int y = 0; y < gridSizeY; y++)
            {
                maskTexture.SetPixel(x, y, clearColor);
            }
        }

        // Mise à jour unique des zones bloquées (si obstacles statiques)
        UpdateCollisionMask();

        // Mise à jour de l'illumination du joueur
        UpdatePlayerIllumination();

        UpdateRenderTexture();
    }

    // Affiche la texture dans une fenêtre GUI pour le débogage.
    /*void OnGUI()
    {
        GUI.DrawTexture(new Rect(10, 10, 256, 256), maskTexture);
    }*/

    void Update()
    {
        // Mise à jour continue de l'illumination du joueur et du rendu.
        UpdatePlayerIllumination();
        maskTexture.Apply();
        UpdateRenderTexture();
    }

    void UpdatePlayerIllumination()
    {
        // 1. Réinitialiser le canal R pour toute la grille.
        for (int x = 0; x < gridSizeX; x++)
        {
            for (int y = 0; y < gridSizeY; y++)
            {
                Color c = maskTexture.GetPixel(x, y);
                c.r = 0;
                maskTexture.SetPixel(x, y, c);
            }
        }

        // 2. Conversion de la position du joueur en indices de cellule.
        Vector3 playerPos = player.transform.position;
        float u = (playerPos.x - gridOrigin.x) / planeWidth;
        float v = (playerPos.z - gridOrigin.z) / planeHeight;
        int cellX = Mathf.FloorToInt(u * gridSizeX);
        int cellY = Mathf.FloorToInt(v * gridSizeY);

        // 3. Calcul de la taille d'une cellule (en unités monde).
        float cellWidth = (float)planeWidth / gridSizeX;
        float cellHeight = (float)planeHeight / gridSizeY;
        int checkRange = Mathf.CeilToInt(illuminationRadius / Mathf.Max(cellWidth, cellHeight));

        // 4. Pour chaque cellule dans le voisinage du joueur, vérifier la distance.
        for (int x = cellX - checkRange; x <= cellX + checkRange; x++)
        {
            for (int y = cellY - checkRange; y <= cellY + checkRange; y++)
            {
                if (x >= 0 && x < gridSizeX && y >= 0 && y < gridSizeY)
                {
                    // Calcul du centre de la cellule (ajouter 0.5 pour cibler le centre).
                    Vector3 cellCenter = new Vector3(
                        gridOrigin.x + (x + 0.5f) * cellWidth,
                        playerPos.y,
                        gridOrigin.z + (y + 0.5f) * cellHeight
                    );

                    float dist = Vector3.Distance(
                        new Vector3(playerPos.x, 0, playerPos.z),
                        new Vector3(cellCenter.x, 0, cellCenter.z)
                    );
                    if (dist <= illuminationRadius)
                    {
                        Color c = maskTexture.GetPixel(x, y);
                        c.r = 1; // Activer l'illumination dans le canal rouge.
                        maskTexture.SetPixel(x, y, c);
                    }
                }
            }
        }
        maskTexture.Apply();
    }

    void UpdateCollisionMask()
    {
        // Définir la zone d'analyse correspondant à tout le plane.
        Vector3 center = gridOrigin + new Vector3(planeWidth * 0.5f, 0, planeHeight * 0.5f);
        Vector3 halfExtents = new Vector3(planeWidth * 0.5f, 1f, planeHeight * 0.5f);
        Collider[] colliders = Physics.OverlapBox(center, halfExtents, Quaternion.identity, blockedLayer);

        foreach (Collider col in colliders)
        {
            Bounds b = col.bounds;
            // Calculer les indices sous forme de float
            float startXFloat = ((b.min.x - gridOrigin.x) / planeWidth) * gridSizeX;
            float endXFloat = ((b.max.x - gridOrigin.x) / planeWidth) * gridSizeX;
            float startYFloat = ((b.min.z - gridOrigin.z) / planeHeight) * gridSizeY;
            float endYFloat = ((b.max.z - gridOrigin.z) / planeHeight) * gridSizeY;

            int startX = Mathf.FloorToInt(startXFloat);
            int endX = Mathf.CeilToInt(endXFloat) - 1;
            int startY = Mathf.FloorToInt(startYFloat);
            int endY = Mathf.CeilToInt(endYFloat) - 1;

            startX = Mathf.Clamp(startX, 0, gridSizeX - 1);
            endX = Mathf.Clamp(endX, 0, gridSizeX - 1);
            startY = Mathf.Clamp(startY, 0, gridSizeY - 1);
            endY = Mathf.Clamp(endY, 0, gridSizeY - 1);

            for (int x = startX; x <= endX; x++)
            {
                for (int y = startY; y <= endY; y++)
                {
                    Color c = maskTexture.GetPixel(x, y);
                    c.g = 1; // Marquer la zone bloquée dans le canal vert.
                    maskTexture.SetPixel(x, y, c);
                }
            }
        }
        maskTexture.Apply();
    }

    void UpdateRenderTexture()
    {
        Graphics.Blit(maskTexture, renderTexture);
    }
}