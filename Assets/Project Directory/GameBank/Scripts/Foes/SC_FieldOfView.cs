using Cinemachine;
using DG.Tweening;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.Splines.Examples;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.ProBuilder.Shapes;

public class SC_FieldOfView : MonoBehaviour
{
    [SerializeField] private FoeType typeFoe;

    public enum FoeType
    {
        superStatic,
        superDynamic
    }

    [SerializeField] private SC_Player scPlayer = null;
    [SerializeField] private SC_VisionConeCasting sc_Cone;
    [SerializeField] private SC_VisionConeCasting[] sc_BossCone = new SC_VisionConeCasting[2];

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
    [SerializeField] private GameObject GoMesh;
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
    [SerializeField] private GameObject Go_vfx_stunOnce;
    [SerializeField] private Vector3 pos_vfx_stunOnce;
    [SerializeField] private ParticleSystem PS_StunOnce;
    [SerializeField] private GameObject Go_vfx_Backward;
    [SerializeField] private Vector3 pos_vfx_backward;
    [SerializeField] private VisioneConeFeedbackBack backfeedback;

    //DETECTION
    [Header("Detection")]
    public LayerMask LMtargetMask;
    public LayerMask LMObstructionMask;
    public int i_EnnemyBeat = 0;
    public GameObject goBaitHearing;
    public int i_EnnemyHeard = 15;
    
    //ETATS
    [Header("Etats")]
    public bool BCanSee;
    public bool bSeenOnce;
    public bool bHasHeard = false;
    public bool bIsDisabled = false;
    public bool BIsNear = false;
    private bool bOnceDisabled = false;

    [Header("Boss")]
    public bool isBoss = false;
    public bool bFinalPhase = false;
    [SerializeField] private ing_Tag[] bossTagsPhase1;
    [SerializeField] private ing_Tag[] bossTagsPhase2 = new ing_Tag[4];
    [SerializeField] private int iAngleRemovePerTag = 10;
    [SerializeField] private ing_Bait[] bossBaits = new ing_Bait[4];
    public int iRest = 0;
    private List<ing_Tag> listTaggsDone = new List<ing_Tag>();
    public int iNbTaggsDonePhase1 = 0;
    public int iNbTaggsDonePhase2 = 0;
    public bool bIsPhaseAnimated = false;
    public CinemachineVirtualCamera camBoss;
    [SerializeField] private float fFinalPhaseAngle = 90f;

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
            // GOPlayerRef = GameObject.FindGameObjectWithTag("Player");
            GOPlayerRef = SC_Player.instance.gameObject;
        }

        StartCoroutine(FOVRoutine());
        switch (typeFoe)
        {
            case FoeType.superStatic:
                currentRotation = minRotation;
                transform.eulerAngles = new Vector3(0, currentRotation, 0);
                break;

            case FoeType.superDynamic:
                this.transform.position = posDirections[iFirstPos];
                if (iFirstPos + 1 == posDirections.Length)
                {
                    transform.LookAt(new Vector3(posDirections[iFirstPos - 1].x, this.transform.position.y, posDirections[iFirstPos - 1].z));
                    isReversing = true;
                    iCurrentDirection = iFirstPos - 1;
                }
                else
                {
                    transform.LookAt(new Vector3(posDirections[iFirstPos + 1].x, this.transform.position.y, posDirections[iFirstPos + 1].z));
                    isReversing = false;
                    iCurrentDirection = iFirstPos + 1;
                }
                Go_vfx_Backward.transform.localPosition = new Vector3(pos_vfx_backward.x, -50f, pos_vfx_backward.z);
                if (backfeedback.initialized)
                {
                    backfeedback.ConeRenderer.enabled = false;
                }
                break;
            default:
                Debug.LogWarning("beep boop");
                break;
        }
    }
    private void Update()
    {
        if (GoCone.transform.localPosition.y != InitialYCone)
        {
            GoCone.transform.localPosition = new Vector3(GoCone.transform.localPosition.x, InitialYCone, GoCone.transform.localPosition.z);
        }
        if(bIsDisabled && !bOnceDisabled)
        {
            bOnceDisabled = true;
            BCanSee = false;
            bHasHeard = false;
            BIsNear = false;
            i_EnnemyBeat = 0;
            foreach(SC_VisionConeCasting cone in sc_BossCone)
            {
                cone.enabled = false;
            }
            sc_Cone.enabled = false;
        }
    }
    //ROUTINE
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

        Collider[] rangeChecks = Physics.OverlapSphere(transform.position, FRadius, LMtargetMask); //OverLapSphere on the whole radius
        Collider[] proximityChecks = Physics.OverlapSphere(transform.position, proximityRadius, LMtargetMask);

        if (rangeChecks.Length != 0) //If something is inside the foe's radius
        {
            Transform target = rangeChecks[0].transform; //the said target
            Vector3 directionToTarget = (target.position - transform.position).normalized; //the direction to the target

            if (Vector3.Angle(transform.forward, directionToTarget) < FAngle / 2) //check if the angle between the target/this and the forward/this is inside the Angle
            {
                float distanceToTarget = Vector3.Distance(transform.position, target.position); //distance to the target
                if (!Physics.Raycast(transform.position, directionToTarget, distanceToTarget, LMObstructionMask)) //if a raycast can go to the target without obstruction
                {
                    bSeenOnce = true; //vu une fois
                }
                else
                {
                    BCanSee = false; //Ne voit pas
                }
            }
            else if (Vector3.Angle(-transform.forward, directionToTarget) < FAngle / 2) //check if the angle between the target/this and the forward/this is inside the Angle
            {
                if (isBoss && bFinalPhase && iNbTaggsDonePhase2 >= 1)
                {
                    float distanceToTarget = Vector3.Distance(transform.position, target.position); //distance to the target
                    if (!Physics.Raycast(transform.position, directionToTarget, distanceToTarget, LMObstructionMask)) //if a raycast can go to the target without obstruction
                    {
                        bSeenOnce = true; //vu une fois
                    }
                    else //bIsNearerRight
                    {
                        BCanSee = false; //Ne voit pas
                    }
                }
            }
            else if (Vector3.Angle(transform.right, directionToTarget) < FAngle / 2) //check if the angle between the target/this and the forward/this is inside the Angle
            {
                if (isBoss && bFinalPhase && iNbTaggsDonePhase2 >= 2)
                {
                    float distanceToTarget = Vector3.Distance(transform.position, target.position); //distance to the target
                    if (!Physics.Raycast(transform.position, directionToTarget, distanceToTarget, LMObstructionMask)) //if a raycast can go to the target without obstruction
                    {
                        bSeenOnce = true; //vu une fois
                    }
                    else 
                    {
                        BCanSee = false; //Ne voit pas
                    }
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
    //VFX
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
            Go_vfx_detected.transform.localPosition = new Vector3 (pos_vfx_detected.x, -50f, pos_vfx_detected.z);
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
            Go_vfx_Suspicious.transform.localPosition = new Vector3(pos_vfx_supicious.x, -50f, pos_vfx_supicious.z);
            PS_Suspicious.Play();
            yield return new WaitForSeconds(0.5f);
            PS_Suspicious.Stop();
        }
    }
    public IEnumerator FoeStunOnceVFX()
    {
        Go_vfx_stunOnce.transform.position = pos_vfx_stunOnce;
        PS_StunOnce.Play();
        yield return new WaitForSeconds(1f);
        PS_StunOnce.Stop();
        Go_vfx_stunOnce.transform.position = new Vector3(0, -50, 0);
    }
    public void ResetAllVFX()
    {
        StartCoroutine(NumDetectedVFX(false, 0f));
        StartCoroutine(NumSuspiciousVFX(false, 0f));
        FoeDisabled(false);
    }
    //DETECTION
    public void PlayerDetected(GameObject GOPlayer, float time)
    {
        transform.LookAt(GOPlayer.transform);
        if(typeFoe == FoeType.superDynamic) // Si l'ennemi est movible : bouge vers le joueur
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
            Go_vfx_coneVision.transform.localPosition = new Vector3(pos_vfx_coneVision.x, -50f, pos_vfx_coneVision.z);
            Go_vfx_disable.transform.localPosition = pos_vfx_disable;
            sc_BossCone[0].transform.GetComponent<MeshRenderer>().enabled = false;
            sc_BossCone[1].transform.GetComponent<MeshRenderer>().enabled = false;
        }
        else
        {
            Go_vfx_coneVision.transform.localPosition = pos_vfx_coneVision;
            Go_vfx_disable.transform.localPosition = new Vector3(pos_vfx_disable.x, -50f, pos_vfx_disable.z);
            sc_BossCone[0].transform.GetComponent<MeshRenderer>().enabled = true;
            sc_BossCone[1].transform.GetComponent<MeshRenderer>().enabled = true;
        }
    }
    private void DetectionChecks ()
    {
        if (bIsDisabled)
        {
            BCanSee = false; //Ne voit pas
            Go_vfx_Suspicious.transform.localPosition = new Vector3(pos_vfx_supicious.x, -50f, pos_vfx_supicious.z);
            PS_Suspicious.Stop();
            Go_vfx_detected.transform.localPosition = new Vector3(pos_vfx_detected.x, -50f, pos_vfx_detected.z);
            PS_detected.Stop();
        }
        else if (bSeenOnce && !bIsPhaseAnimated)
        {
            BCanSee = true;
            bSeenOnce = false;
            BIsNear = false;
            StartCoroutine(NumDetectedVFX(true, Go_vfx_detected.transform.localPosition.y));
            Go_vfx_Suspicious.transform.localPosition = new Vector3(pos_vfx_supicious.x, -50f, pos_vfx_supicious.z);
            PS_Suspicious.Stop();
        }
        else if (BIsNear)
        {
            bHasHeard = false;
            StartCoroutine(NumSuspiciousVFX(true, Go_vfx_Suspicious.transform.localPosition.y));
            transform.LookAt(GOPlayerRef.transform);
        }
        else  if (bHasHeard && !bIsPhaseAnimated)
        {
            StartCoroutine(NumSuspiciousVFX(true, Go_vfx_Suspicious.transform.localPosition.y));
        }
        else
        {
            StartCoroutine(NumSuspiciousVFX(false, Go_vfx_Suspicious.transform.localPosition.y));
        }
        if (!BCanSee && !bHasHeard && !BIsNear)
        {
            if (typeFoe == FoeType.superStatic)
            {
                transform.eulerAngles = vectLastRot;
            }
            else
            {
                transform.LookAt(new Vector3(posDirections[iCurrentDirection].x, this.transform.position.y, posDirections[iCurrentDirection].z));
            }
            StartCoroutine(NumDetectedVFX(false, Go_vfx_detected.transform.localPosition.y));
        }
        if(bIsPhaseAnimated)
        {
            BCanSee = false;
            bSeenOnce = false;
            BIsNear = false;
            bHasHeard = false;
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
        switch (typeFoe)
        {
            case FoeType.superStatic:
                if (!scPlayer.bIsImune && !bIsPhaseAnimated)
                {
                    if (!isReversing && currentRotation >= maxRotation)
                    {
                        if (isBoss)
                        {
                            currentRotation = minRotation;
                        }
                        else
                        {
                            isReversing = true;
                        }
                    }
                    else if (isReversing && currentRotation <= minRotation)
                    {
                        if (isBoss)
                        {
                            currentRotation = maxRotation;
                        }
                        else
                        {
                            isReversing = false;
                        }
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
                break;

            case FoeType.superDynamic:
                if (!scPlayer.bIsImune)
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
                    sc_BossCone[1].transform.GetComponent<MeshRenderer>().enabled = false;
                    sc_BossCone[1].enabled = false;
                    sc_BossCone[1].gameObject.transform.localPosition += new Vector3(0, -50f, 0);
                    //Go_vfx_Backward.transform.localPosition = new Vector3(pos_vfx_backward.x, -50f, pos_vfx_backward.z);
                    if (backfeedback.initialized)
                    {
                        backfeedback.ConeRenderer.enabled = false;
                    }
                    if (BCanSee == false)
                    {
                        transform.LookAt(new Vector3(posDirections[iCurrentDirection].x, this.transform.position.y, posDirections[iCurrentDirection].z));
                    }
                }
                else if (this.transform.position == new Vector3(Mathf.Round(preLastPos.x), preLastPos.y, Mathf.Round(preLastPos.z))) //un mouvement away from the last position
                {
                    if (iCurrentDirection + 1 == posDirections.Length && !isReversing) //si la prochaine position n'existe pas
                    {
                        sc_BossCone[1].transform.LookAt(new Vector3(posDirections[iCurrentDirection - 1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection - 1].z));
                        sc_BossCone[1].transform.localPosition = pos_vfx_backward;
                        sc_BossCone[1].transform.GetComponent<MeshRenderer>().enabled = true;
                        sc_BossCone[1].enabled = true;
                        //Go_vfx_Backward.transform.LookAt(new Vector3(posDirections[iCurrentDirection-1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection-1].z));
                    }
                    else if (iCurrentDirection - 1 == -1 && isReversing) //si la prochaine position n'existe pas
                    {
                        sc_BossCone[1].transform.LookAt(new Vector3(posDirections[iCurrentDirection + 1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection + 1].z));
                        sc_BossCone[1].transform.localPosition = pos_vfx_backward;
                        sc_BossCone[1].transform.GetComponent<MeshRenderer>().enabled = true;
                        sc_BossCone[1].enabled = true;
                    }
                    /*else if(iCurrentDirection + 1 != posDirections.Length && !isReversing)//si la prochaine position existe
                    {
                        sc_BossCone[1].transform.LookAt(new Vector3(posDirections[iCurrentDirection +1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection + 1].z));
                        //Go_vfx_Backward.transform.LookAt(new Vector3(posDirections[iCurrentDirection + 1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection + 1].z));
                    }
                    else //si la prochaine position existe
                    {
                        sc_BossCone[1].transform.LookAt(new Vector3(posDirections[iCurrentDirection - 1].x, Go_vfx_Backward.transform.position.y, posDirections[iCurrentDirection - 1].z));
                    }*/
                    /*if (backfeedback.initialized)
                    {
                        backfeedback.ConeRenderer.enabled = true;
                    }*/
                }
                break;

            default:
                break;

        }
    }
    //BOSS
    private void BaitShuffle()
    {
        for (int y = 0; y < bossBaits.Length; y++)
        {
            bossBaits[y].bOnFoe = false;
            bossBaits[y].transform.position += new Vector3(0f,50f,0f);
            bossBaits[y].sc_juice.Restart();
            bossBaits[y].beginY = bossBaits[y].transform.position.y;
        }
    }
    public void BossTagAnglePhase1()
    {
        if(iNbTaggsDonePhase1 == bossTagsPhase1.Length)
        {
            bFinalPhase = true;
            FAngle = fFinalPhaseAngle;
            AnimatePhase2();
        }
    }
    public void BossTagAnglePhase2()
    {
        if(iNbTaggsDonePhase2 == 1)
        {
            sc_BossCone[0].transform.GetComponent<MeshRenderer>().enabled = true;
            sc_BossCone[0].enabled = true;
        }
        if(iNbTaggsDonePhase2 == 2)
        {
            sc_BossCone[1].transform.GetComponent<MeshRenderer>().enabled = true;
            sc_BossCone[1].enabled = true;
        }
        else if(iNbTaggsDonePhase2 == 4)
        {
            scPlayer.menuManager.bGameIsPaused = true;
            scPlayer.bIsImune = true;
            bIsDisabled = true;
            AnimatePhase3();
        }
        sc_Cone.iBossTagsPhase2 = iNbTaggsDonePhase2;
    }
    private void AnimatePhase2()
    {
        bIsPhaseAnimated = true;
        //camBoss.Priority = 20;
        scPlayer.menuManager.bGameIsPaused = true;
        scPlayer.bIsImune = true;
        bIsDisabled = true;
        for(int i =0; i< bossTagsPhase1.Length; i++)
        {
            bossTagsPhase1[i].transform.parent.transform.position += new Vector3(0, -50f, 0);
        }
        Vector3 startPos = GoMesh.transform.position;
        Quaternion startRot = GoMesh.transform.rotation;
        DG.Tweening.Sequence seq = DOTween.Sequence();

        sc_BossCone[2].transform.GetComponent<MeshRenderer>().enabled = false;
        // Target positions and rotations
        Vector3 floatUpPos = startPos + new Vector3(0, 3f, 0);
        Quaternion floatRot = Quaternion.Euler(startRot.eulerAngles + new Vector3(20, 40, 10));

        // Float up and rotate slightly
        seq.Append(GoMesh.transform.DOMove(floatUpPos, 2f).SetEase(Ease.OutSine));
        seq.Join(GoMesh.transform.DORotateQuaternion(floatRot, 2f).SetEase(Ease.OutSine));

        // Stagger (X/Z + small Y noise) while staying in air
        seq.Append(GoMesh.transform.DOMove(floatUpPos + new Vector3(0.1f, 0.3f, -0.2f), 1f).SetEase(Ease.InOutSine));
        seq.Append(GoMesh.transform.DOMove(floatUpPos + new Vector3(-0.4f, 0.1f, 0.2f), 1f).SetEase(Ease.InOutSine));

        // Fall back to original position and rotation
        seq.Append(GoMesh.transform.DOMove(startPos, 0.8f).SetEase(Ease.InQuad));
        seq.Join(GoMesh.transform.DORotateQuaternion(startRot, 0.8f).SetEase(Ease.InQuad));
        seq.OnComplete(() =>
        {
            for (int i = 0; i < bossTagsPhase2.Length; i++)
            {
                bossTagsPhase2[i].transform.parent.transform.position += new Vector3(0, 50f, 0);
                bossTagsPhase2[i].decalProj.material.SetFloat("_ErosionValue", 1f);
            }
            bIsPhaseAnimated = false;
            GoMesh.transform.position = startPos;
            GoMesh.transform.rotation = startRot;
            bIsDisabled = false;
            scPlayer.menuManager.bGameIsPaused = false;
            scPlayer.bIsImune = false;
            //camBoss.Priority = 2;
            scPlayer.bpmManager.SetSpeed(1.05f);
            sc_BossCone[2].transform.GetComponent<MeshRenderer>().enabled = true;
        });
    }
    private void AnimatePhase3()
    {
        bIsPhaseAnimated = true;
        //camBoss.Priority = 20;
        scPlayer.menuManager.bGameIsPaused = true;
        scPlayer.bIsImune = true;
        bIsDisabled = true;
        for (int i = 0; i < bossTagsPhase2.Length; i++)
        {
            bossTagsPhase2[i].transform.parent.transform.position += new Vector3(0, -50f, 0);
        }
        sc_BossCone[0].transform.GetComponent<MeshRenderer>().enabled = false;
        sc_BossCone[1].transform.GetComponent<MeshRenderer>().enabled = false;
        sc_BossCone[2].transform.GetComponent<MeshRenderer>().enabled = false;
        Vector3 startPos = GoMesh.transform.position;
        Quaternion startRot = GoMesh.transform.rotation;
        DG.Tweening.Sequence seq = DOTween.Sequence();

        // Target positions and rotations
        Vector3 floatUpPos = startPos + new Vector3(0, 3f, 0);
        Quaternion floatRot = Quaternion.Euler(startRot.eulerAngles + new Vector3(20, 40, 10));

        // Float up and rotate slightly
        seq.Append(GoMesh.transform.DOMove(floatUpPos, 2f).SetEase(Ease.OutSine));
        seq.Join(GoMesh.transform.DORotateQuaternion(floatRot, 2f).SetEase(Ease.OutSine));

        // Stagger (X/Z + small Y noise) while staying in air
        seq.Append(GoMesh.transform.DOMove(floatUpPos + new Vector3(0.1f, 0.3f, -0.2f), 1f).SetEase(Ease.InOutSine));
        seq.Append(GoMesh.transform.DOMove(floatUpPos + new Vector3(-0.4f, 0.1f, 0.2f), 1f).SetEase(Ease.InOutSine));

        // Fall back to original position and rotation
        seq.Append(GoMesh.transform.DOMove(startPos, 0.8f).SetEase(Ease.InQuad));
        seq.Join(GoMesh.transform.DORotateQuaternion(startRot, 0.8f).SetEase(Ease.InQuad));
        seq.OnComplete(() =>
        {
            GoMesh.transform.position = startPos;
            GoMesh.transform.rotation = startRot;
            scPlayer.menuManager.bGameIsPaused = false;
            scPlayer.bIsImune = false;
            //camBoss.Priority = 2;
            sc_Cone.iBossTagsPhase2 = 0;
            BaitShuffle();
        });
    }
}
