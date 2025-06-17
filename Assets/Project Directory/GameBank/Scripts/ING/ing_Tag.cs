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
    [SerializeField] private VisualEffect vfx_completition;
    [SerializeField] private GameObject go_completition;
    [SerializeField] private Vector3 vect_completition;
    public bool bBossDoorTag = false;
    public BoxCollider boxColliderBoss = null;
    public GameObject goBossDoor = null;
    public TextMeshPro textOnWallBossDoor = null;
    public CinemachineVirtualCamera camBossDoor = null;
    public DecalProjector decalProj;
    public VisualEffect[] PS_Sound;
    [SerializeField] private VisualEffect[] PS_SoundShot;
    [SerializeField] private GameObject[] Go_SoundShot;
    [SerializeField] private Vector3[] vect_base_soundShot;
    [SerializeField]private VisualEffect PS_SoundWaveStun;
    [SerializeField] private GameObject Go_SoundWaveStun;
    [SerializeField] private Vector3 vect_base_soundWaveStun;

    private void Start()
    {
        foreach (VisualEffect veSound in PS_SoundShot)
        {
            veSound.Stop();
        }
        decalProj.material.SetFloat("_ErosionValue", 1f);
    }
    private void OnDestroy()
    {
        decalProj.material.SetFloat("_ErosionValue", 1f);
    }
    public IEnumerator PlayVFXSoundWave()
    {
        Go_SoundWaveStun.transform.localPosition = vect_base_soundWaveStun;
        PS_SoundWaveStun.Play();
        yield return new WaitForSeconds(1.5f);
        PS_SoundWaveStun.Stop();
        Go_SoundWaveStun.transform.localPosition = new Vector3(vect_base_soundWaveStun.x, vect_base_soundWaveStun.y - 50f, vect_base_soundWaveStun.z);
    }
    public IEnumerator PlaySoundShot()
    {
        for(int i = 0; i < PS_SoundShot.Length; i++)
        {
            Go_SoundShot[i].transform.localPosition = vect_base_soundShot[i];
            PS_SoundShot[i].Play();
            yield return new WaitForSeconds(0.2f);
        }
    }

    public IEnumerator PlayVFXCompletition()
    {
        go_completition.transform.localPosition = vect_completition;
        vfx_completition.Play();
        yield return new WaitForSeconds(1.5f);
        vfx_completition.Stop();
        go_completition.transform.localPosition = new Vector3(vect_completition.x, vect_completition.y - 50f, vect_completition.z);
    }
}
