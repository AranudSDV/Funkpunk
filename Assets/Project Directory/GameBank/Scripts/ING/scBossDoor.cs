using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class scBossDoor : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera BossCamera;
    [SerializeField] private CinemachineVirtualCamera DoorCamera;
    [SerializeField] private GameObject goDoor;
    [SerializeField] private ing_Tag[] allTaggsBeforeBoss;
    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.transform.GetComponent<SC_Player>().BossDoorToFoe(goDoor, BossCamera, DoorCamera, this.transform.GetComponent<BoxCollider>());
            for (int i = 0; i < allTaggsBeforeBoss.Length; i++)
            {
                allTaggsBeforeBoss[i].decalProj.material.SetFloat("_ErosionValue", 1f);
            }
        }
    }
}
