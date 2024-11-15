using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ing_Bait : MonoBehaviour
{
    SC_Player player;
    // Start is called before the first frame update
    void Start()
    {
        GameObject GOPlayer = GameObject.FindGameObjectWithTag("Player");
        player = GOPlayer.GetComponent<SC_Player>();
    }

    private void OnCollisionEnter(Collision collision)
    {
        player.Baiting();
        Destroy(this.gameObject);
    }
}
