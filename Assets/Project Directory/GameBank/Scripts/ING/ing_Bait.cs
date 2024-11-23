using System.Collections;
using System.Collections.Generic;
using Unity.Properties;
using UnityEngine;

public class ing_Bait : MonoBehaviour
{
    //Mettre le private void OnCollisionEnter directement dans le player
    //Mettre un tag sur cet objet "Bait" ou qqc du style
    public float fTimeLifeBait = 3f;
    private SC_Player scPlayer;
    public bool b_BeenThrown = false;
    private SC_FieldOfView[] allEnemies = null;
    [SerializeField] private Material mThrown;
    [SerializeField] private MeshRenderer mshRdn;
    private bool bCollision = false;

    private void Start()
    {
        allEnemies = FindObjectsOfType<SC_FieldOfView>();
        if (b_BeenThrown)
        {
            foreach (SC_FieldOfView ennemy in allEnemies)
            {
                ennemy.bHasHeard = true;
            }
            mshRdn.material = mThrown;
        }
    }

    private void Update()
    {
        if (b_BeenThrown)
        {
            foreach (SC_FieldOfView ennemy in allEnemies)
            {
                if (ennemy.i_EnnemyBeat > 5)
                {
                    ennemy.bHasHeard = false;
                    ennemy.i_EnnemyBeat = 0;
                    Destroy(this.gameObject);
                }
            }
        }
        if (bCollision && b_BeenThrown == false && scPlayer.newThrow == true)
        {
            Destroy(this.gameObject);
        }
    }

    //Mettre un bool ici "Ennemi has Heard Something", qui si activé
    //Change le tag de cet objet (pour ne pas que le joueur puisse le reprendre)
    //Démarre le temps de vie en tempo de cet objet
    //Oblige l'ennemi a regardé par ici, jusqu'à ce que le temps de vie en tempo de cet obet soit à sa fin
    // Dans l'update de l'ennemi => Check bait == null ou pas
    //Donc dans l'ennemi => if bait != null [Freeze l'ennemi dans la direction d'envoi de ce bait]
    //if bait == null , retour à la routine normale
    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player") && b_BeenThrown == false)
        {
            scPlayer = collision.GetComponent<SC_Player>();
            scPlayer.bIsBaiting = true;
            bCollision = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.CompareTag("Player") && b_BeenThrown == false)
        {
            bCollision = false;
        }
    }
}
