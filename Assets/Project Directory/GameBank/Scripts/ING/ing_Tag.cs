using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.UIElements;
using TMPro;

public class ing_Tag : MonoBehaviour
{
    public TextMeshPro textOnWall;
    public Material taggedMaterial;
    public Material untaggedMaterial;
    public Renderer _renderer;
    public GameObject goArrow;
    public SC_FieldOfView[] scFoes;
    public SC_FieldOfView scBoss = null;
    public bool bBossTag = false;
}
