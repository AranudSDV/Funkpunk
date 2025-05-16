using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.ProBuilder.Shapes;

public class SC_FieldOfView : MonoBehaviour
{
    public int i_typeFoe = 1;
    [SerializeField] private SC_Player scPlayer = null;

    //LE DEPLACEMENT
    [Header("Deplacement")]
    [SerializeField] private Vector3[] posDirections;
    [SerializeField] private int iFirstPos = 0;
    [SerializeField] private int iCurrentDirection = 0;

    //LE CONE DE VISION
    [Header("Cone de vision")]
    [Range(0, 25)]
    public float FRadius;
    [Range(0,70)]
    public float FAngle;
    [SerializeField] private float proximityRadius = 1f;
    [SerializeField] private float InitialYCone = -0.05549997f;
    [SerializeField] private GameObject GoCone;

    //ROTATION
    [Header("Rotation")]
    [SerializeField] private float minRotation = -90f;
    [SerializeField] private float maxRotation = 45f;
    [SerializeField] private float rotationStep = 45f;

    //GARDE
    private float currentRotation;
    [SerializeField] private bool isReversing = false;
    private Vector3 vectLastRot;

    //FEEDBACK SUR ENNEMIE
    [Header("Feedbacks")]
    public GameObject GOPlayerRef;
    [SerializeField] private GameObject Go_vfx_detected;
    [SerializeField] private Vector3 pos_vfx_detected;
    [SerializeField] private ParticleSystem PS_detected;
    [SerializeField] private GameObject Go_vfx_disable;
    [SerializeField] private Vector3 pos_vfx_disable;
    [SerializeField] private GameObject Go_vfx_coneVision;
    [SerializeField] private Vector3 pos_vfx_coneVision;
    [SerializeField] private GameObject Go_vfx_Suspicious;
    [SerializeField] private Vector3 pos_vfx_supicious;
    [SerializeField] private ParticleSystem PS_Suspicious;
    [SerializeField] private GameObject Go_vfx_Backward;
    [SerializeField] private Vector3 pos_vfx_backward;
    [SerializeField] private VisioneConeFeedbackBack backfeedback;

    //DETECTION
    [Header("Detection")]
    public LayerMask LMtargetMask;
    public LayerMask LMObstructionMask;
    public int i_EnnemyBeat = 0;
    public GameObject goBaitHearing;

    //ETATS
    [Header("Etats")]
    public bool BCanSee;
    public bool bSeenOnce;
    public bool bHasHeard = false;
    public bool bIsDisabled = false;
    public bool BIsNear = false;

    [Header("Boss")]
    public bool isBoss = false;
    [SerializeField] private ing_Tag[] bossTags;
    [SerializeField] private ing_Bait[] bossBaits = new ing_Bait[4];
    [SerializeField] private Vector3[] posBait;
    [SerializeField][Tooltip("xz, x-z, -x-z, -xz")] private int[] iNbPosBaitPerZoneAdditive = new int[4];
    private ing_Tag chosenTag = null;
    public bool bIsRemovingTag = false;
    private bool bRoutineAgain = true;
    public int iRemovingRoutine = 9;
    [SerializeField] private int iRemovingThird = 3;
    public int iTimeBeforeRemovingThird = 3;
    private List<ing_Tag> listTaggsDone = new List<ing_Tag>();
    public int iNbTaggsDone = 0;

    private int Hasard(int a, int b) //Choisi un random.
    {
        System.Random rdm = new System.Random();
        int hasard = rdm.Next(a, b + 1); //Aller jusqu'a le b inclu.
        return hasard;
    }
    private void Start()
    {
        if (GOPlayerRef == null)
        {
            GOPlayerRef = GameObject.FindGameObjectWithTag("Player");
        }
        StartCoroutine(FOVRoutine());
        if (i_typeFoe == 1) //si l'ennemi est statique
        {
            currentRotation = minRotation;
            transform.eulerAngles = new Vector3(0, currentRotation, 0);
        }
        else
        {
            this.transform.position = posDirections[iFirstPos];
            if (iFirstPos + 1 == posDirections.Length)
            {
                transform.LookAt(new Vector3(posDirections[iFirstPos-1].x, this.transform.position.y, posDirections[iFirstPos-1].z));
                isReversing = true;
                iCurrentDirection = iFirstPos - 1;
            }
            else
            {
                transform.LookAt(new Vector3(posDirections[iFirstPos + 1].x, this.transform.position.y, posDirections[iFirstPos + 1].z));
                isReversing = false;
                iCurrentDirection = iFirstPos + 1;
            }
            Go_vfx_Backward.transform.localPosition = new Vector3(pos_vfx_backward.x, 50f, pos_vfx_backward.z);
            if(backfeedback.initialized)
            {
                backfeedback.ConeRenderer.enabled = false;
            }
        }
    }
    private void Update()
    {
        if (GoCone.transform.localPosition.y != InitialYCone)
        {
            GoCone.transform.localPosition = new Vector3(GoCone.transform.localPosition.x, InitialYCone, GoCone.transform.localPosition.z);
        }
    }
    private IEnumerator FOVRoutine()
    {
        WaitForSeconds wait = new WaitForSeconds(0.2f);
        
        while(true)
        {
            yield return wait;
            FieldOfViewCheck();
        }
    }
    private void FieldOfViewCheck()
    {
        if(bIsDisabled) return;

        Collider[] rangeChecks = Physics.OverlapSphere(transform.position, FRadius, LMtargetMask);
        Collider[] proximityChecks = Physics.OverlapSphere(transform.position, proximityRadius, LMtargetMask);

        if (rangeChecks.Length != 0)
        {
            Transform target = rangeChecks[0].transform;
            Vector3 directionToTarget = (target.position - transform.position).normalized;

            if (Vector3.Angle(transform.forward, directionToTarget) < FAngle / 2)
            {
                float distanceToTarget = Vector3.Distance(transform.position, target.position);
                if (!Physics.Raycast(transform.position, directionToTarget, distanceToTarget, LMObstructionMask))
                {
                    bSeenOnce = true; //vu une fois
                }
                else
                {
                    BCanSee = false; //Ne voit pas
                }
            }
            else
            {
                BCanSee = false; //Ne voit pas
            }
        }
        else
        {
            BCanSee = false; //Ne voit pas
        }
        if(proximityChecks.Length != 0)
        {
            BIsNear = true;
        }
        else
        {
            BIsNear = false;
        }
        DetectionChecks();
    }
    private IEnumerator NumDetectedVFX(bool bNewDetected, float height)
    {
        if (bNewDetected && height>30)
        {
            Go_vfx_detected.transform.localPosition = pos_vfx_detected; 
            PS_detected.Play();
            yield return new WaitForSeconds(0.5f);
            PS_detected.Pause();
        }
        else if(!bNewDetected && height < 30)
        {
            Go_vfx_detected.transform.localPosition = new Vector3 (pos_vfx_detected.x, 50f, pos_vfx_detected.z);
            PS_detected.Play();
            yield return new WaitForSeconds(0.5f);
            PS_detected.Stop();
        }
    }
    private IEnumerator NumSuspiciousVFX(bool bNewDetected, float height)
    {
        if (bNewDetected && height>30)
        {
            Go_vfx_Suspicious.transform.localPosition = pos_vfx_supicious;
            PS_Suspicious.Play();
            yield return new WaitForSeconds(0.5f);
            PS_Suspicious.Pause();
        }
        else if (!bNewDetected && height<30)
        {
            Go_vfx_Suspicious.transform.localPosition = new Vector3(pos_vfx_supicious.x, 50f, pos_vfx_supicious.z);
            PS_Suspicious.Play();
            yield return new WaitForSeconds(0.5f);
            PS_Suspicious.Stop();
        }
    }
    public void PlayerDetected(GameObject GOPlayer, float time)
    {
        transform.LookAt(GOPlayer.transform);
        if(i_typeFoe == 2) // Si l'ennemi est movible : bouge vers le joueur
        {
            int index = NearestPosToPlayer(GOPlayer);
            if(index>iCurrentDirection)
            {
                if(isReversing)
                {
                    isReversing = false;
                }
            }
            else if(index < iCurrentDirection)
            {
                if (!isReversing)
                {
                    isReversing = true;
                }
            }
            EnemieRotation(time);
        }
    }
    public void BaitHeard(GameObject GOBait)
    {
        transform.LookAt(GOBait.transform);
        goBaitHearing = GOBait;
    }
    public void FoeDisabled(bool _isDisable)
    {
        if (_isDisable)
        {
            Go_vfx_coneVision.transform.localPosition = new Vector3(pos_vfx_coneVision.x, 50f, pos_vfx_coneVision.z);
            Go_vfx_disable.transform.localPosition = pos_vfx_disable;
        }
        else
        {
            Go_vfx_coneVision.transform.localPosition = pos_vfx_coneVision;
            Go_vfx_disable.transform.localPosition = new Vector3(pos_vfx_disable.x, 50f, pos_vfx_disable.z);
        }
    }
    private void DetectionChecks ()
    {
        if (bIsDisabled)
        {
            Go_vfx_Suspicious.transform.localPosition = new Vector3(pos_vfx_supicious.x, 50f, pos_vfx_supicious.z);
            PS_Suspicious.Stop();
            Go_vfx_detected.transform.localPosition = new Vector3(pos_vfx_detected.x, 50f, pos_vfx_detected.z);
            PS_detected.Stop();
            if(isBoss)
            {
                if(bIsRemovingTag)
                {
                    iRemovingRoutine = 10;
                    iTimeBeforeRemovingThird = 10;
                }
                bIsRemovingTag = false;
                bRoutineAgain = false;
            }
        }
        else if (bSeenOnce)
        {
            BCanSee = true;
            bSeenOnce = false;
            BIsNear = false;
            StartCoroutine(NumDetectedVFX(true, Go_vfx_detected.transform.localPosition.y));
            Go_vfx_Suspicious.transform.localPosition = new Vector3(pos_vfx_supicious.x, 50f, pos_vfx_supicious.z);
            PS_Suspicious.Stop();
            if (isBoss)
            {
                if (bIsRemovingTag)
                {
                    iRemovingRoutine = 10;
                    iTimeBeforeRemovingThird = 10;
                }
                bIsRemovingTag = false;
                bRoutineAgain = false;
            }
        }
        else if (BIsNear)
        {
            bHasHeard = false;
            StartCoroutine(NumSuspiciousVFX(true, Go_vfx_Suspicious.transform.localPosition.y));
            transform.LookAt(GOPlayerRef.transform);
            if (isBoss)
            {
                if (bIsRemovingTag)
                {
                    iRemovingRoutine = 10;
                    iTimeBeforeRemovingThird = 10;
                }
                bIsRemovingTag = false;
                bRoutineAgain = false;
            }
        }
        else  if (bHasHeard)
        {
            StartCoroutine(NumSuspiciousVFX(true, Go_vfx_Suspicious.transform.localPosition.y));
            if (isBoss)
            {
                if (bIsRemovingTag)
                {
                    iRemovingRoutine = 10;
                    iTimeBeforeRemovingThird = 10;
                }
                bIsRemovingTag = false;
                bRoutineAgain = false;
            }
        }
        else
        {
            StartCoroutine(NumSuspiciousVFX(false, Go_vfx_Suspicious.transform.localPosition.y));
        }
        if (!BCanSee && !bHasHeard && !BIsNear)
        {
            if (i_typeFoe == 1)
            {
                if (!isBoss)
                {
                    transform.eulerAngles = vectLastRot;
                }
                else if (isBoss && !bIsRemovingTag && !bRoutineAgain)
                {
                    transform.eulerAngles = vectLastRot;
                    iRemovingRoutine = 9;
                    iTimeBeforeRemovingThird = iRemovingThird;
                    bRoutineAgain = true;
                }
            }
            else
            {
                transform.LookAt(new Vector3(posDirections[iCurrentDirection].x, this.transform.position.y, posDirections[iCurrentDirection].z));
            }
            StartCoroutine(NumDetectedVFX(false, Go_vfx_detected.transform.localPosition.y));
        }
    }
    private int NearestPosToPlayer(GameObject player)
    {
        int i = -1;
        int resultat = 0;
        Vector3 offset = posDirections[0] - player.transform.position;
        float sqrLen = offset.sqrMagnitude;
        foreach (var pos in posDirections)
        {
            Vector3 _offset = pos - player.transform.position;
            float _sqrLen = _offset.sqrMagnitude;

            // square the distance we compare with
            if (sqrLen < _sqrLen)
            {
                sqrLen =  _sqrLen;
                offset = _offset;
                resultat = i;
            }
            i++;
        }
        return resultat;
    }
    public void EnemieRotation(float ftime)
    {
        if (i_typeFoe == 1) //Si l'ennemi est statique, ne bouge que sa rotation
        {
            if(!scPlayer.bIsImune)
            {
                if (!isReversing && currentRotation >= maxRotation)
                {
                    isReversing = true;
                }
                else if (isReversing && currentRotation <= minRotation)
                {
                    isReversing = false;
                }

                if (isReversing)
                {
                    currentRotation -= rotationStep;
                }
                else
                {
                    currentRotation += rotationStep;
                }
                currentRotation = Mathf.Clamp(currentRotation, minRotation, maxRotation);
                transform.eulerAngles = new Vector3(0, currentRotation, 0);
                vectLastRot = transform.eulerAngles;
            }
        }
        else if (i_typeFoe == 2)//Si l'ennemi suit un chemin, est movible
        {
            if(!scPlayer.bIsImune)
            {
                Vector3 newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection].x - this.transform.position.x, 0, posDirections[iCurrentDirection].z - this.transform.position.z).normalized;
                this.transform.DOJump(new Vector3(Mathf.Round(newPos.x), newPos.y, Mathf.Round(newPos.z)), 1f, 0, ftime).SetEase(Ease.OutBack).SetAutoKill(true);
            }
            else
            {
                this.transform.DOJump(new Vector3(Mathf.Round(this.transform.position.x), this.transform.position.y, Mathf.Round(this.transform.position.z)), 1f, 0, ftime).SetEase(Ease.OutBack).SetAutoKill(true);
            }
            Vector3 preLastPos = posDirections[iCurrentDirection] - new Vector3(posDirections[iCurrentDirection].x - this.transform.position.x, 0, posDirections[iCurrentDirection].z - this.transform.position.z).normalized;
            if (this.transform.position.x == Mathf.Round(posDirections[iCurrentDirection].x) && this.transform.position.z == Mathf.Round(posDirections[iCurrentDirection].z)) //pile � la position de changement.
            {
                if (!isReversing && iCurrentDirection + 1 != posDirections.Length && posDirections.Length != 2) //Si �a ne reverse pas et que la prochaine direction existe
                {
                    iCurrentDirection += 1;
                }
                else if (!isReversing && iCurrentDirection + 1 == posDirections.Length && posDirections.Length != 2) //Si �a ne reverse pas et que la prochaine direction n'existe pas ou aller-retour
                {
                    if (iCurrentDirection != 0)
                    {
                        iCurrentDirection -= 1;
                    }
                    isReversing = true;
                }
                else if (!isReversing && iCurrentDirection + 1 == posDirections.Length && posDirections.Length == 2) //Si �a ne reverse pas et que la prochaine direction n'existe pas ou aller-retour
                {
                    if (iCurrentDirection == 1)
                    {
                        iCurrentDirection = 0;
                    }
                    isReversing = true;
                }
                else if (isReversing && iCurrentDirection - 1 != -1 && posDirections.Length != 2)//Si �a se reverse et que la prochaine direction existe
                {
                   iCurrentDirection -= 1;
                }
                else if (isReversing && (iCurrentDirection - 1 == -1 && posDirections.Length != 2))//Si �a se reverse et que la prochaine direction n'existe pas ou aller-retour
                {
                    iCurrentDirection += 1;
                    isReversing = false;
                }
                else
                {
                    iCurrentDirection = 1;
                    isReversing = false;
                }
                Go_vfx_Backward.transform.localPosition = new Vector3(pos_vfx_backward.x, 50f, pos_vfx_backward.z);
                if (backfeedback.initialized)
                {
                    backfeedback.ConeRenderer.enabled = false;
                }
                if (BCanSee == false)
                {
                    transform.LookAt(new Vector3(posDirections[iCurrentDirection].x, this.transform.position.y, posDirections[iCurrentDirection].z));
                }
            }
            else if (this.transform.position  == new Vector3(Mathf.Round(preLastPos.x), preLastPos.y, Mathf.Round(preLastPos.z))) //un mouvement away from the last position
            {
                if (iCurrentDirection + 1 == posDirections.Length && !isReversing)
                {
                    Go_vfx_Backward.transform.LookAt(new Vector3(posDirections[iCurrentDirection-1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection-1].z));
                }
                else if(iCurrentDirection + 1 != posDirections.Length && !isReversing)
                {
                    Go_vfx_Backward.transform.LookAt(new Vector3(posDirections[iCurrentDirection + 1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection + 1].z));
                }
                else if(iCurrentDirection - 1 == -1 && isReversing)
                {
                    Go_vfx_Backward.transform.LookAt(new Vector3(posDirections[iCurrentDirection + 1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection + 1].z));
                }
                else
                {
                    Go_vfx_Backward.transform.LookAt(new Vector3(posDirections[iCurrentDirection - 1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection - 1].z));
                }
                Go_vfx_Backward.transform.localPosition = pos_vfx_backward;
                if (backfeedback.initialized)
                {
                    backfeedback.ConeRenderer.enabled = true;
                }
            }
        }
    }
    public void ResetAllVFX()
    {
        StartCoroutine(NumDetectedVFX(false, 0f));
        StartCoroutine(NumSuspiciousVFX(false, 0f));
        FoeDisabled(false);
    }
    private void BaitShuffle()
    {
        for (int i = 0; i < 4; i++)
        {
            if(i-1==-1)
            {
                bossBaits[i].transform.position = posBait[Hasard(0, iNbPosBaitPerZoneAdditive[i]-1)];
            }
            else
            {
                bossBaits[i].transform.position = posBait[Hasard(iNbPosBaitPerZoneAdditive[i - 1], iNbPosBaitPerZoneAdditive[i]-1)];
            }
        }
    }
    public void TagChecking()
    {
        listTaggsDone.Clear();
        foreach (ing_Tag tag in bossTags)
        {
            if(tag.transform.gameObject.tag == "Wall")
            {
                listTaggsDone.Add(tag);
            }
        }
        if (listTaggsDone.Count>1)
        {
            chosenTag = listTaggsDone[Hasard(0, listTaggsDone.Count-1)];
        }
        else if(listTaggsDone.Count == 1)
        {
            chosenTag = listTaggsDone[0];
        }
        else
        {
            chosenTag = null;
        }
        if(chosenTag!= null)
        {
            BaitShuffle();
            bIsRemovingTag = true;
            iTimeBeforeRemovingThird = iRemovingThird;
        }
        else
        {
            iRemovingRoutine = 9;
            iTimeBeforeRemovingThird = iRemovingThird;
        }
    }
    public void RemovingTag()
    {
        transform.LookAt(chosenTag.transform);
        if (iTimeBeforeRemovingThird == 0)
        {
            iTimeBeforeRemovingThird = iRemovingThird;
            if (chosenTag.textOnWall.text == "1/3")
            {
                chosenTag.textOnWall.text = "0/3";
                iRemovingRoutine = 9;
                bIsRemovingTag = false;
                iNbTaggsDone -= 1;
                BossTagAngle();
            }
            else if (chosenTag.textOnWall.text == "2/3")
            {
                chosenTag.textOnWall.text = "1/3";
            }
            else
            {
                chosenTag.transform.gameObject.tag = "Tagging";
                chosenTag._renderer.material = chosenTag.untaggedMaterial;
                chosenTag.textOnWall.text = "2/3";
            }
        }
    }
    public void BossTagAngle()
    {
        FAngle = 60 - (iNbTaggsDone * 5);
        if(iNbTaggsDone == bossTags.Length)
        {
            scPlayer.EndDialogue();
        }
    }

}
