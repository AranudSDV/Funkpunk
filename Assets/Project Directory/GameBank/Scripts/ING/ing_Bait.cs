using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ing_Bait : MonoBehaviour
{
    //Mettre le private void OnCollisionEnter directement dans le player
    //Mettre un tag sur cet objet "Bait" ou qqc du style
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            collision.gameObject.GetComponent<SC_Player>().Baiting();
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
}
