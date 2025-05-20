using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class ing_Tag : MonoBehaviour
{
    public Material taggedMaterial;
    public Material untaggedMaterial;
    public Renderer _renderer;
    public GameObject goArrow;
    public SC_FieldOfView[] scFoes;
    public SC_FieldOfView scBoss = null;
    public bool bBossTag = false;
    public int iCompletition = 0;
    public ParticleSystem vfx_completition;
    public bool bBossDoorTag = false;
    public BoxCollider boxColliderBoss = null;
    public GameObject goBossDoor = null;
    public TextMeshPro textOnWallBossDoor = null;
    public CinemachineVirtualCamera camBossDoor = null;
}
