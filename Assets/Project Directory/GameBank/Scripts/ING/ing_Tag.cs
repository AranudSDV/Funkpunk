using Cinemachine;
using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.VFX;

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
    public DecalProjector decalProj;
    public VisualEffect[] PS_Sound;
    [SerializeField] private GameObject go_SoundWave;
    [SerializeField]private VisualEffect PS_SoundWave;
    [SerializeField] private Vector3 vectBase_SoundWave;

    private void Start()
    {
        decalProj.material.SetFloat("_ErosionValue", 1f);
    }
    private void OnDestroy()
    {
        decalProj.material.SetFloat("_ErosionValue", 1f);
    }

    public IEnumerator PlayVFXSoundWave()
    {
        go_SoundWave.transform.localPosition = vectBase_SoundWave;
        PS_SoundWave.Play();
        yield return new WaitForSeconds(0.5f);
        PS_SoundWave.Stop();
        go_SoundWave.transform.localPosition = new Vector3(vectBase_SoundWave.x, vectBase_SoundWave.y-50f, vectBase_SoundWave.z);
    }
}
