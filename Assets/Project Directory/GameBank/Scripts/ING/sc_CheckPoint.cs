using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.VFX;
using static UnityEngine.Rendering.DebugUI;

public class sc_CheckPoint : MonoBehaviour
{
    [SerializeField] private SC_Player scPlayer;
    public ing_Tag[] tags;
    private bool hasGoneThrough = false;
    [SerializeField]private int iCheckPoint = 0;
    public VisualEffect vfx_sewerSmoke;
    private void OnTriggerEnter(Collider collision)
    {
        if (!hasGoneThrough && collision.gameObject.CompareTag("Player"))
        {
            scPlayer.CheckPoint(false, iCheckPoint);
            vfx_sewerSmoke.SetBool("isChecked", true);
            Debug.Log("enter");
        }
    }
}
