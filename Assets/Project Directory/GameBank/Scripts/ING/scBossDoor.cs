using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class scBossDoor : MonoBehaviour
{
    [SerializeField] private CinemachineVirtualCamera BossCamera;
    [SerializeField] private CinemachineVirtualCamera DoorCamera;
    [SerializeField] private GameObject goDoor;
    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.transform.GetComponent<SC_Player>().BossDoorToFoe(goDoor, BossCamera, DoorCamera, this.transform.GetComponent<BoxCollider>());
        }
    }
}
