using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class sc_CheckPoint : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    public ing_Tag[] tags;
    private bool hasGoneThrough = false;
    [SerializeField]private int iCheckPoint = 0;
    private void OnTriggerEnter(Collider collision)
    {
        if (!hasGoneThrough && collision.gameObject.CompareTag("Player"))
        {
            scPlayer.CheckPoint(false, iCheckPoint);
        }
    }
}
