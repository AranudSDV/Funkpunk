using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PP_InteractiveGrid : MonoBehaviour
{

[Header("Grid & Plane Settings")]
    public int gridSize = 100;             // Résolution de la grille (nombre de cases sur un côté)
    public Vector3 gridOrigin = Vector3.zero; // Origine (coin inférieur gauche) du plane
    public float planeWidth = 100f;        // Largeur du plane en unités monde
    public float planeHeight = 100f;       // Hauteur du plane en unités monde

    [Header("Player Illumination")]
    public Transform player;               // Référence au joueur
    public float illuminationRadius = 1f;  // Rayon d'illumination en mètres

    [Header("Collision Settings")]
    public LayerMask blockedLayer;         // Layer des obstacles à considérer

    [Header("Render Texture")]
    public RenderTexture renderTexture;    // RenderTexture assignée dans le shader

    private Texture2D maskTexture;         // Texture de masque qui stocke les infos dans les canaux (R: illumination, G: obstacles)

    void Start()
    {
        // Création et initialisation de la Texture2D (par défaut, aucun effet, donc R = 0, G = 0)
        maskTexture = new Texture2D(gridSize, gridSize, TextureFormat.RGBA32, false);
        Color clearColor = new Color(0, 0, 0, 1);
        for (int x = 0; x < gridSize; x++)
        {
            for (int y = 0; y < gridSize; y++)
            {
                maskTexture.SetPixel(x, y, clearColor);
            }
        }

        // Mise à jour unique des zones bloquées (si obstacles statiques)
        UpdateCollisionMask();
        maskTexture.Apply();
        UpdateRenderTexture();
    }

    void UpdatePlayerIllumination()
    {
        

        // 1. Réinitialiser le canal R (illumination) pour toute la grille
        for (int x = 0; x < gridSize; x++)
        {
            for (int y = 0; y < gridSize; y++)
            {
                Color c = maskTexture.GetPixel(x, y);
                c.r = 0; // Réinitialise l'illumination
                maskTexture.SetPixel(x, y, c);
            }
        }

        // 2. Calculer la position du joueur dans la grille
        Vector3 playerPos = player.position;
        float u = (playerPos.x - gridOrigin.x) / planeWidth;
        float v = (playerPos.z - gridOrigin.z) / planeHeight;
        int cellX = Mathf.FloorToInt(u * gridSize);
        int cellY = Mathf.FloorToInt(v * gridSize);

        // Déterminer la taille d'une case en unités monde
        float cellWidth = planeWidth / gridSize;
        float cellHeight = planeHeight / gridSize;
        // Calculer le nombre de cellules à vérifier en fonction du rayon d'illumination
        int checkRange = Mathf.CeilToInt(illuminationRadius / Mathf.Max(cellWidth, cellHeight));

        // 3. Pour chaque cellule proche, vérifier la distance et activer le canal R si dans le rayon
        for (int x = cellX - checkRange; x <= cellX + checkRange; x++)
        {
            for (int y = cellY - checkRange; y <= cellY + checkRange; y++)
            {
                if (x >= 0 && x < gridSize && y >= 0 && y < gridSize)
                {
                    // Calcul du centre de la cellule en coordonnées monde
                    Vector3 cellCenter = new Vector3(gridOrigin.x + (x + 0.5f) * cellWidth,
                                                     playerPos.y,
                                                     gridOrigin.z + (y + 0.5f) * cellHeight);
                    float dist = Vector3.Distance(new Vector3(playerPos.x, 0, playerPos.z), new Vector3(cellCenter.x, 0, cellCenter.z));
                    if (dist <= illuminationRadius)
                    {
                        Color c = maskTexture.GetPixel(x, y);
                        c.r = 1; // Active l'illumination dans le canal rouge
                        maskTexture.SetPixel(x, y, c);
                    }
                }
            }
        }
        
        maskTexture.Apply();
        UpdateRenderTexture();
    }

    // Mise à jour unique pour marquer les obstacles (canal G)
    void UpdateCollisionMask()
    {
        // On définit la zone de la grille à scanner en utilisant un OverlapBox couvrant tout le plane
        Vector3 center = gridOrigin + new Vector3(planeWidth * 0.5f, 0, planeHeight * 0.5f);
        Vector3 halfExtents = new Vector3(planeWidth * 0.5f, 1f, planeHeight * 0.5f);
        Collider[] colliders = Physics.OverlapBox(center, halfExtents, Quaternion.identity, blockedLayer);

        foreach (Collider col in colliders)
        {
            Bounds b = col.bounds;
            // Conversion des bounds du collider en indices de grille
            int startX = Mathf.FloorToInt((b.min.x - gridOrigin.x) / planeWidth * gridSize);
            int endX   = Mathf.FloorToInt((b.max.x - gridOrigin.x) / planeWidth * gridSize);
            int startY = Mathf.FloorToInt((b.min.z - gridOrigin.z) / planeHeight * gridSize);
            int endY   = Mathf.FloorToInt((b.max.z - gridOrigin.z) / planeHeight * gridSize);

            startX = Mathf.Clamp(startX, 0, gridSize - 1);
            endX   = Mathf.Clamp(endX, 0, gridSize - 1);
            startY = Mathf.Clamp(startY, 0, gridSize - 1);
            endY   = Mathf.Clamp(endY, 0, gridSize - 1);

            // Marquer ces cellules dans le canal G pour les colliderz
            for (int x = startX; x <= endX; x++)
            {
                for (int y = startY; y <= endY; y++)
                {
                    Color c = maskTexture.GetPixel(x, y);
                    c.g = 1; // Marquer la zone bloquée
                    maskTexture.SetPixel(x, y, c);
                }
            }
        }
    }

    // Transfert de la Texture2D vers la RenderTexture utilisée dans le Shader Graph
    void UpdateRenderTexture()
    {
        Graphics.Blit(maskTexture, renderTexture);
    }
}
