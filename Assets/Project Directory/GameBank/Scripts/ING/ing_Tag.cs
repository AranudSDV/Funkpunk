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
    [SerializeField] private VisualEffect[] PS_SoundShot;
    [SerializeField]private VisualEffect PS_SoundWaveStun;

    private void Start()
    {
        foreach (VisualEffect veSound in PS_SoundShot)
        {
            veSound.Stop();
        }
        PS_SoundWaveStun.Stop();
        decalProj.material.SetFloat("_ErosionValue", 1f);
    }
    private void OnDestroy()
    {
        decalProj.material.SetFloat("_ErosionValue", 1f);
    }
    public IEnumerator PlayVFXSoundWave()
    {
        PS_SoundWaveStun.Play();
        yield return new WaitForSeconds(1.5f);
        PS_SoundWaveStun.Stop();
    }
    public IEnumerator PlaySoundShot()
    {
        foreach(VisualEffect veSound in PS_SoundShot)
        {
            veSound.Play();
            yield return new WaitForSeconds(0.2f);
        }
    }
}
