using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using Unity.Properties;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.VFX;

public class ing_Bait : MonoBehaviour
{
    public SC_Player scPlayer;
    public BPM_Manager bpmManager;
    public bait_juicy sc_juice;
    public bool bOnFoe = false;

    //THROWN 
    private float elapsedseconds = 0;
    public Vector3 newPos = new Vector3(0, 0, 0);
    public Vector3 midPos = new Vector3(0, 0, 0);
    public float beginY;
    public Vector3 beginVect = new Vector3(0, 0, 0);
    public bool bIsBeingThrown = false;
    private bool bGoingUp = false;
    private bool bGoingDown = false;

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
    [SerializeField] private Vector3 fPosBase_smash;
    private ParticleSystem PS_smash;
    [SerializeField] private GameObject Go_vfx_Impact;
    [SerializeField] private Vector3 fPosBase_impact;
    private ParticleSystem PS_Impact;
    [SerializeField] private GameObject Go_vfx_ImpactSound;
    [SerializeField] private Vector3 fPosBase_impactSound;
    private VisualEffect PS_impactSound;
    [SerializeField] private GameObject Go_vfxTrail;
    [SerializeField] private Vector3 fPosBase_trail;
    private ParticleSystem PS_trail;
    [SerializeField] private GameObject Go_vfxIdle;
    [SerializeField] private Vector3 fPosBase_idlel;

    //ONE TIME ONLY
    public bool b_BeenThrown = false;
    private bool bThrownButAble = false;
    private bool bOnce = false;
    private bool bInit = false;
    private IEnumerator StartNow()
    {
        yield return new WaitUntil(() => BPM_Manager.instance != null);
        bpmManager = BPM_Manager.instance;
        PS_trail = Go_vfxTrail.transform.gameObject.GetComponent<ParticleSystem>();
        PS_smash = Go_vfx_Smash.transform.gameObject.GetComponent<ParticleSystem>();
        PS_Impact = Go_vfx_Impact.transform.gameObject.GetComponent<ParticleSystem>();
        PS_impactSound = Go_vfx_ImpactSound.transform.gameObject.GetComponent<VisualEffect>();
        bOnce = false;
        beginVect = this.transform.position;
        beginY = this.transform.position.y;
        PS_Impact.Stop();
        PS_impactSound.Stop();
        PS_smash.Stop();
        PS_trail.Stop();
    }
    private void Update()
    {
        if (!bInit)
        {
            StartCoroutine(sc_juice.StartNow());
            StartCoroutine(StartNow());
            bInit = true;
        }
        if(!b_BeenThrown && !bIsBeingThrown)
        {
            Go_vfxIdle.transform.localPosition = fPosBase_idlel;
        }
        if(b_BeenThrown)
        {
            Go_vfxIdle.transform.localPosition = new Vector3(fPosBase_idlel.x, fPosBase_idlel.y, fPosBase_idlel.z);
            foreach (SC_FieldOfView ennemy in allEnemies)
            {
                if (ennemy.i_EnnemyBeat > 3)
                {
                    b_BeenThrown = false;
                    mshRdn.material = mNotThrown;
                    bThrownButAble = true;
                }
                if (ennemy.goBaitHearing != this.transform.gameObject || ennemy.i_EnnemyBeat == 0)
                {
                    mshRdn.material = mNotThrown;
                }
                else if (ennemy.goBaitHearing == this.transform.gameObject && ennemy.i_EnnemyBeat > 0)
                {
                    mshRdn.material = mThrown;
                }
                if (ennemy.i_EnnemyBeat == -5)
                {
                    b_BeenThrown = false;
                }
            }
        }
        else if(bThrownButAble)
        {
            foreach (SC_FieldOfView ennemy in allEnemies)
            {
                if(ennemy.i_EnnemyBeat > ennemy.i_EnnemyHeard)
                {
                    ennemy.bHasHeard = false;
                    ennemy.i_EnnemyBeat = 0;
                    bThrownButAble = false;
                }
             }
        }
        if (allEnemies.Length == 0)
        {
            b_BeenThrown = false;
            bThrownButAble = false;
            mshRdn.material = mNotThrown;
        }
        if (bIsBeingThrown)
        {
            Go_vfxIdle.transform.localPosition = new Vector3(fPosBase_idlel.x, fPosBase_idlel.y - 50f, fPosBase_idlel.z);
            if (!bOnce)
            {
                bGoingUp = true;
                StartCoroutine(NumSmashVFX(bpmManager.FSPB));
                //this.transform.DOJump(newPos, 5f, 0, bpmManager.FSPB).SetEase(Ease.OutBack); //Ease.OutQuad, Ease.OutElastic, Ease.OutBack
                //this.transform.DOMove(midPos, bpmManager.FSPB / 2, false).SetAutoKill(true);
                //this.transform.GetChild(0).gameObject.transform.DOMove(midPos, bpmManager.FSPB / 2, false).SetAutoKill(true);
                //this.transform.GetChild(0).gameObject.transform.DOJump(newPos, 5f, 0, bpmManager.FSPB).SetEase(Ease.OutBack);
                bOnce = true;
            }
            if (bGoingUp)
            {
                elapsedseconds += Time.deltaTime;
                float interpolationRatio = elapsedseconds / (bpmManager.FSPB / 2);
                transform.position = Vector3.Lerp(this.transform.position, midPos, interpolationRatio);
                Go_vfxTrail.transform.position = Vector3.Lerp(this.transform.position, midPos, interpolationRatio);
                this.transform.GetChild(0).gameObject.transform.position = Vector3.Lerp(this.transform.position, midPos, interpolationRatio);
                if (interpolationRatio >= 1f)
                {
                    bGoingDown = true;
                    bGoingUp = false;
                    elapsedseconds = 0f;
                }
            }
            if (bGoingDown)
            {
                elapsedseconds += Time.deltaTime;
                float interpolationRatio = elapsedseconds / (bpmManager.FSPB / 2);
                transform.position = Vector3.Lerp(this.transform.position, newPos, interpolationRatio);
                Go_vfxTrail.transform.position = Vector3.Lerp(this.transform.position, newPos, interpolationRatio);
                this.transform.GetChild(0).gameObject.transform.position = Vector3.Lerp(this.transform.position, newPos, interpolationRatio);
                if (interpolationRatio >= 0.95f)
                {
                    b_BeenThrown = true;
                    ThrownAway();
                    bGoingDown = false;
                    elapsedseconds = 0f;
                    transform.position = new Vector3(Mathf.Round(newPos.x), beginY, Mathf.Round(newPos.z));
                    this.transform.GetChild(0).gameObject.transform.localPosition = Vector3.zero;
                }
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
    private void ThrownAway()
    {
        bIsBeingThrown = false;
        StartCoroutine(NumImpactVFX(bpmManager.FSPB));
        GameObject[] allGoEnnemies = DetectObjects();
        allEnemies = new SC_FieldOfView[allGoEnnemies.Length];
        if (allEnemies.Length == 0)
        {
            b_BeenThrown = false;
            mshRdn.material = mNotThrown;
        }
        else
        {
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
    private void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            scPlayer.ShootBait(this.GetComponent<ing_Bait>());
            if(!scPlayer.hasAlreadyBaited && SceneManager.GetActiveScene().name == "SceneLvl2")
            {
                scPlayer.tutoGen.StartTutoBait();
                scPlayer.hasAlreadyBaited = true;
            }
        }
    }
    private IEnumerator NumSmashVFX(float time)
    {
        Go_vfx_Smash.transform.LookAt(scPlayer.gameObject.transform, Vector3.down);
        Go_vfx_Smash.transform.localPosition = fPosBase_smash;
        Go_vfx_Smash.transform.position += scPlayer.lastMoveDirection;
        Go_vfxTrail.transform.localPosition = fPosBase_trail;
        PS_trail.Play();
        PS_smash.Play();
        yield return new WaitForSeconds(time*5/6);
        PS_trail.Stop();
        PS_smash.Stop();
        yield return new WaitForSeconds(time * 1 / 6);
        Go_vfx_Smash.transform.localPosition = new Vector3(fPosBase_smash.x, fPosBase_smash.y-50f, fPosBase_smash.z);
        bOnce = false;
    }
    private IEnumerator NumImpactVFX(float time)
    {
        Go_vfx_Impact.transform.localPosition = fPosBase_impact;
        Go_vfx_ImpactSound.transform.localPosition = fPosBase_impactSound;
        Go_vfxTrail.transform.localPosition = new Vector3(fPosBase_trail.x, fPosBase_trail.y, fPosBase_trail.z);
        PS_Impact.Play();
        PS_impactSound.Play();
        yield return new WaitForSeconds(time * 2/5);
        PS_Impact.Stop();
        PS_impactSound.Stop();
        Go_vfx_ImpactSound.transform.localPosition = new Vector3(fPosBase_impact.x, fPosBase_impact.y - 50f, fPosBase_impact.z);
        Go_vfx_Impact.transform.localPosition = new Vector3(fPosBase_impactSound.x, fPosBase_impactSound.y-50f, fPosBase_impactSound.z);
        if(bOnFoe)
        {
            sc_juice.EndNow();
            this.transform.position = new Vector3(0, -50f, 0);
        }
    }
}
