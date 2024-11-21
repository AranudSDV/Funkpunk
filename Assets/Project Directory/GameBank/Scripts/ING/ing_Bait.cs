using System.Collections;
using System.Collections.Generic;
using Unity.Properties;
using UnityEngine;

public class ing_Bait : MonoBehaviour
{
    //Mettre le private void OnCollisionEnter directement dans le player
    //Mettre un tag sur cet objet "Bait" ou qqc du style
    public bool bEnnemiHasHeard = false;
    public float fTimeLifeBait = 3f;
    private SC_Player scPlayer;

    //Mettre un bool ici "Ennemi has Heard Something", qui si activé
    //Change le tag de cet objet (pour ne pas que le joueur puisse le reprendre)
    //Démarre le temps de vie en tempo de cet objet
    //Oblige l'ennemi a regardé par ici, jusqu'à ce que le temps de vie en tempo de cet obet soit à sa fin
    // Dans l'update de l'ennemi => Check bait == null ou pas
    //Donc dans l'ennemi => if bait != null [Freeze l'ennemi dans la direction d'envoi de ce bait]
    //if bait == null , retour à la routine normale
    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            scPlayer = collision.GetComponent<SC_Player>();
            scPlayer.bIsBaiting = true;
            this.gameObject.tag = "Untagged";
            Destroy(this.gameObject);
            //collision.gameObject.GetComponent<ing_Bait>().Baiting();
        }
    }
}
