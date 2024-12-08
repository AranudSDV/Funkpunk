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
    [SerializeField] private SC_FieldOfView[] allEnemies;
    [SerializeField] private Material mThrown;
    [SerializeField] private Material mNotThrown;
    [SerializeField] private MeshRenderer mshRdn;
    private float detectionRadius = 7f;
    private bool bCollision = false;
    [SerializeField] private string targetTag;

    private void Awake()
    {
        if (allEnemies == null && !b_BeenThrown)
        {
            allEnemies = FindObjectsOfType<SC_FieldOfView>();
        }
        if (b_BeenThrown)
        {
            GameObject[] allGoEnnemies = DetectObjects();
            allEnemies = new SC_FieldOfView[allGoEnnemies.Length];
            if (allEnemies.Length == 0)
            {
                b_BeenThrown = false;
                mshRdn.material = mNotThrown;
            }
            else
            {
                for (int i = 0; i < allGoEnnemies.Length; i++)
                {
                    allEnemies[i] = allGoEnnemies[i].GetComponent<SC_FieldOfView>();
                }
                foreach (SC_FieldOfView ennemy in allEnemies)
                {
                    ennemy.bHasHeard = true;
                    ennemy.i_EnnemyBeat = 0;
                    Debug.Log("Detected object: " + ennemy.name);
                }
                mshRdn.material = mThrown;
            }
        }
    }
    GameObject[] DetectObjects()
    {
        GameObject[] objectsWithTag = GameObject.FindGameObjectsWithTag(targetTag);

        List<GameObject> objectsInRange = new List<GameObject>();

        foreach (GameObject obj in objectsWithTag)
        {
            if (obj != this.gameObject)
            {
                float distance = Vector3.Distance(transform.position, obj.transform.position);
                if (distance <= detectionRadius)
                {
                    objectsInRange.Add(obj);
                }
            }
        }

        return objectsInRange.ToArray();
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, detectionRadius);
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
                    b_BeenThrown = false;
                    mshRdn.material = mNotThrown;
                }
            }
        }
        if (allEnemies.Length == 0)
        {
            b_BeenThrown = false;
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
            scPlayer.ShootBait();
            bCollision = true;
            if(scPlayer.hasAlreadyBaited == false)
            {
                sc_tuto tutoriel = GameObject.FindWithTag("Tuto").gameObject.GetComponent<sc_tuto>();
                tutoriel.StartTutoBait();
                scPlayer.hasAlreadyBaited = true;
            }
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
