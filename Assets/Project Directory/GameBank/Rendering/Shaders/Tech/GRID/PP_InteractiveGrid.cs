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
    public int planeHeight = 100;  // Dimension en Z du plane (en unités monde)

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

        // Calculer la dimension du plane
        planeWidth = (int)(transform.localScale.x);
        planeHeight = (int)(transform.localScale.z);  // On utilise z pour la profondeur/hauteur du plane

        
        gridSizeX = planeWidth;
        gridSizeY = planeHeight;

        // Création et initialisation de la Texture2D selon la résolution de la grille.
        maskTexture = new Texture2D(gridSizeX, gridSizeY, TextureFormat.RGBA32, false);
        maskTexture.filterMode = FilterMode.Point; // Pour éviter l'interpolation et garder l'aspect "pixelisé"
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

    // Affiche la texture dans une fenêtre GUI de débogage.
    void OnGUI()
    {
        GUI.DrawTexture(new Rect(10, 10, 256, 256), maskTexture);
    }

    void Update()
    {
        // Mise à jour continue de l'illumination du joueur et du rendu.
        UpdatePlayerIllumination();
        maskTexture.Apply();
        UpdateRenderTexture();
    }

    void UpdatePlayerIllumination()
    {
        // 1. Réinitialiser le canal R (illumination) pour toute la grille.
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

        // 3. Calcul de la taille d'une cellule en unités monde.
        float cellWidth = (float)planeWidth / gridSizeX;
        float cellHeight = (float)planeHeight / gridSizeY;
        int checkRange = Mathf.CeilToInt(illuminationRadius / Mathf.Max(cellWidth, cellHeight));

        // 4. Pour chaque cellule dans le voisinage du joueur, vérifier la distance et activer le canal R si dans le rayon.
        for (int x = cellX - checkRange; x <= cellX + checkRange; x++)
        {
            for (int y = cellY - checkRange; y <= cellY + checkRange; y++)
            {
                if (x >= 0 && x < gridSizeX && y >= 0 && y < gridSizeY)
                {
                    // Calcul du centre de la cellule en espace monde.
                    Vector3 cellCenter = new Vector3(
                        gridOrigin.x + (x + 0.5f) * cellWidth,
                        playerPos.y,
                        gridOrigin.z + (y + 0.5f) * cellHeight
                    );

                    float dist = Vector3.Distance(new Vector3(playerPos.x, 0, playerPos.z),
                                                  new Vector3(cellCenter.x, 0, cellCenter.z));
                    if (dist <= illuminationRadius)
                    {
                        Color c = maskTexture.GetPixel(x, y);
                        c.r = 1; // Active l'illumination dans le canal rouge.
                        maskTexture.SetPixel(x, y, c);
                    }
                }
            }
        }
        maskTexture.Apply();
    }

    // Mise à jour unique pour marquer les obstacles dans le canal G.
    void UpdateCollisionMask()
    {
        // Définir une zone d'analyse correspondant à tout le plane.
        Vector3 center = gridOrigin + new Vector3(planeWidth * 0.5f, 0, planeHeight * 0.5f);
        Vector3 halfExtents = new Vector3(planeWidth * 0.5f, 1f, planeHeight * 0.5f);
        Collider[] colliders = Physics.OverlapBox(center, halfExtents, Quaternion.identity, blockedLayer);

        foreach (Collider col in colliders)
        {
            Bounds b = col.bounds;
            // Conversion des bornes de l'obstacle en indices de grille.
            int startX = Mathf.FloorToInt((b.min.x - gridOrigin.x) / planeWidth * gridSizeX);
            int endX = Mathf.FloorToInt((b.max.x - gridOrigin.x) / planeWidth * gridSizeX);
            int startY = Mathf.FloorToInt((b.min.z - gridOrigin.z) / planeHeight * gridSizeY);
            int endY = Mathf.FloorToInt((b.max.z - gridOrigin.z) / planeHeight * gridSizeY);

            startX = Mathf.Clamp(startX, 0, gridSizeX - 1);
            endX = Mathf.Clamp(endX, 0, gridSizeX - 1);
            startY = Mathf.Clamp(startY, 0, gridSizeY - 1);
            endY = Mathf.Clamp(endY, 0, gridSizeY - 1);

            // Marquer ces cellules dans le canal G.
            for (int x = startX; x <= endX; x++)
            {
                for (int y = startY; y <= endY; y++)
                {
                    Color c = maskTexture.GetPixel(x, y);
                    c.g = 1;
                    maskTexture.SetPixel(x, y, c);
                }
            }
        }
        maskTexture.Apply();
    }

    // Transfert du contenu de la Texture2D vers la RenderTexture assignée dans le shader.
    void UpdateRenderTexture()
    {
        Graphics.Blit(maskTexture, renderTexture);
    }
}