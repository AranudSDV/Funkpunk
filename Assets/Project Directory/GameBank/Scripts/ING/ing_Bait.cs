using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using Unity.Properties;
using Unity.VisualScripting;
using UnityEngine;

public class ing_Bait : MonoBehaviour
{
    public SC_Player scPlayer;
    public BPM_Manager bpmManager;

    //THROWN 
    private float elapsedseconds = 0;
    public Vector3 newPos = new Vector3(0,0,0);
    public bool bIsBeingThrown = false;

    //MESH
    [SerializeField] private Material mThrown;
    [SerializeField] private Material mNotThrown;
    [SerializeField] private MeshRenderer mshRdn;

    //DETECTED
    [SerializeField] private SC_FieldOfView[] allEnemies;
    public float detectionRadius = 7f;
    [SerializeField] private string targetTag;

    //FEEDBACK
    [SerializeField] private GameObject Go_vfx_Smash;
    [SerializeField] private GameObject Go_vfx_Impact;
    private ParticleSystem PS_smash;
    private ParticleSystem PS_Impact;

    //ONE TIME ONLY
    private bool b_BeenThrown = false;
    private bool bOnce = false;
    private bool bIsHeard = false;

    private void Awake()
    {
        PS_smash = Go_vfx_Smash.transform.gameObject.GetComponent<ParticleSystem>();
        PS_Impact = Go_vfx_Impact.transform.gameObject.GetComponent<ParticleSystem>();
        bOnce = false;
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

    private void ThrownAway()
    {
        bIsBeingThrown = false;
        StartCoroutine(NumImpactVFX());
        GameObject[] allGoEnnemies = DetectObjects();
        allEnemies = new SC_FieldOfView[allGoEnnemies.Length];
        if (allEnemies.Length == 0)
        {
            b_BeenThrown = false;
            mshRdn.material = mNotThrown;
            bIsHeard = false;
        }
        else
        {
            bIsHeard = true;
            mshRdn.material = mThrown;
            for (int i = 0; i < allGoEnnemies.Length; i++)
            {
                allEnemies[i] = allGoEnnemies[i].GetComponent<SC_FieldOfView>();
            }
            foreach (SC_FieldOfView ennemy in allEnemies)
            {
                if (!ennemy.bIsDisabled)
                {
                    ennemy.bHasHeard = true;
                    ennemy.i_EnnemyBeat = 0;
                }
            }
        }
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
                    bIsHeard = false;
                    mshRdn.material = mNotThrown;
                }
                if(ennemy.goBaitHearing != this.transform.gameObject || ennemy.i_EnnemyBeat == 0)
                {
                    mshRdn.material = mNotThrown;
                }
                else if(ennemy.goBaitHearing == this.transform.gameObject && ennemy.i_EnnemyBeat > 0)
                {
                    mshRdn.material = mThrown;
                }
                if(ennemy.i_EnnemyBeat == -5)
                {
                    b_BeenThrown = false;
                }
            }
        }
        if (allEnemies.Length == 0)
        {
            b_BeenThrown = false;
        }
        if (bIsBeingThrown == true)
        {
            if (!bOnce)
            {
                StartCoroutine(NumSmashVFX());
            }
            elapsedseconds += Time.deltaTime;
            float interpolationRatio = elapsedseconds / bpmManager.FSPB;
            transform.position = Vector3.Lerp(this.transform.position, newPos, interpolationRatio);
            if(interpolationRatio >=1 )
            {
                b_BeenThrown = true;
                ThrownAway();
                elapsedseconds = 0f;
            }
        }
    }
    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player") && b_BeenThrown == false)
        {
            scPlayer.ShootBait(this.GetComponent<ing_Bait>());
            if(scPlayer.hasAlreadyBaited == false)
            {
                sc_tuto tutoriel = GameObject.FindWithTag("Tuto").gameObject.GetComponent<sc_tuto>();
                tutoriel.StartTutoBait();
                scPlayer.hasAlreadyBaited = true;
            }
        }
    }
    IEnumerator NumSmashVFX()
    {
        bOnce = true;
        Go_vfx_Smash.transform.LookAt(scPlayer.gameObject.transform, Vector3.down);
        Go_vfx_Smash.transform.position += scPlayer.lastMoveDirection;
        Go_vfx_Smash.SetActive(true);
        PS_smash.Play();
        yield return new WaitForSeconds(0.5f);
        PS_smash.Stop();
        Go_vfx_Smash.SetActive(false);
        yield return new WaitForSeconds(0.5f);
        bOnce = false;
    }
    IEnumerator NumImpactVFX()
    {
        Go_vfx_Impact.SetActive(true);
        PS_Impact.Play();
        yield return new WaitForSeconds(0.5f);
        PS_Impact.Stop();
        Go_vfx_Impact.SetActive(false);
    }
}
