using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.VisualScripting;
using UnityEngine;

public class SC_FieldOfView : MonoBehaviour
{
    public int i_typeFoe = 1;

    //LE DEPLACEMENT
    [Header("Déplacement")]
    [SerializeField] private Vector3[] posDirections;
    [SerializeField] private int iFirstPos = 0;
    [SerializeField] private int iCurrentDirection = 0;

    //LE CONE DE VISION
    [Header("Cone de vision")]
    [Range(0, 8)]
    public float FRadius;
    [Range(0,70)]
    public float FAngle;
    [SerializeField] private float proximityRadius = 1f;

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
    private bool BIsNear = false;

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
    IEnumerator NumDetectedVFX(bool bNewDetected, float height)
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
    IEnumerator NumSuspiciousVFX(bool bNewDetected, float height)
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
        }
        else if (bSeenOnce)
        {
            BCanSee = true;
            bSeenOnce = false;
            BIsNear = false;
            StartCoroutine(NumDetectedVFX(true, Go_vfx_detected.transform.localPosition.y));
            Go_vfx_Suspicious.transform.localPosition = new Vector3(pos_vfx_supicious.x, 50f, pos_vfx_supicious.z);
            PS_Suspicious.Stop();
        }
        else if (BIsNear)
        {
            bHasHeard = false;
            StartCoroutine(NumSuspiciousVFX(true, Go_vfx_Suspicious.transform.localPosition.y));
            transform.LookAt(GOPlayerRef.transform);
        }
        else  if (bHasHeard == true)
        {
            StartCoroutine(NumSuspiciousVFX(true, Go_vfx_Suspicious.transform.localPosition.y));
        }
        else
        {
            StartCoroutine(NumSuspiciousVFX(false, Go_vfx_Suspicious.transform.localPosition.y));
        }
        if (!BCanSee && !bHasHeard && !BIsNear)
        {
            if (i_typeFoe == 1)
            {
                transform.eulerAngles = vectLastRot;
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
        else if (i_typeFoe == 2)//Si l'ennemi suit un chemin, est movible
        {
            Vector3 newPos = this.transform.position + new Vector3(posDirections[iCurrentDirection].x - this.transform.position.x, 0, posDirections[iCurrentDirection].z - this.transform.position.z).normalized;
            this.transform.DOJump(new Vector3(Mathf.Round(newPos.x), newPos.y, Mathf.Round(newPos.z)), 1f, 0, ftime).SetEase(Ease.OutBack).SetAutoKill(true);
            //this.transform.DOMove(new Vector3(Mathf.Round(newPos.x), newPos.y, Mathf.Round(newPos.z)), ftime, false).SetAutoKill(true);
            Vector3 preLastPos = posDirections[iCurrentDirection] - new Vector3(posDirections[iCurrentDirection].x - this.transform.position.x, 0, posDirections[iCurrentDirection].z - this.transform.position.z).normalized;
            if (this.transform.position.x == Mathf.Round(posDirections[iCurrentDirection].x) && this.transform.position.z == Mathf.Round(posDirections[iCurrentDirection].z)) //pile à la position de changement.
            {
                if (!isReversing && iCurrentDirection + 1 != posDirections.Length && posDirections.Length != 2) //Si ça ne reverse pas et que la prochaine direction existe
                {
                    iCurrentDirection += 1;
                }
                else if (!isReversing && iCurrentDirection + 1 == posDirections.Length && posDirections.Length != 2) //Si ça ne reverse pas et que la prochaine direction n'existe pas ou aller-retour
                {
                    if (iCurrentDirection != 0)
                    {
                        iCurrentDirection -= 1;
                    }
                    isReversing = true;
                }
                else if (!isReversing && iCurrentDirection + 1 == posDirections.Length && posDirections.Length == 2) //Si ça ne reverse pas et que la prochaine direction n'existe pas ou aller-retour
                {
                    if (iCurrentDirection == 1)
                    {
                        iCurrentDirection = 0;
                    }
                    isReversing = true;
                }
                else if (isReversing && iCurrentDirection - 1 != -1 && posDirections.Length != 2)//Si ça se reverse et que la prochaine direction existe
                {
                   iCurrentDirection -= 1;
                }
                else if (isReversing && (iCurrentDirection - 1 == -1 && posDirections.Length != 2))//Si ça se reverse et que la prochaine direction n'existe pas ou aller-retour
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
}
