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
    [SerializeField] private GameObject go_SoundWave;
    [SerializeField]private VisualEffect PS_SoundWaveStun;
    [SerializeField] private Vector3 vectBase_SoundWaveStun;

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
        go_SoundWave.transform.localPosition = vectBase_SoundWaveStun;
        PS_SoundWaveStun.Play();
        yield return new WaitForSeconds(1.5f);
        PS_SoundWaveStun.Stop();
        go_SoundWave.transform.localPosition = new Vector3(vectBase_SoundWaveStun.x, vectBase_SoundWaveStun.y-50f, vectBase_SoundWaveStun.z);
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
