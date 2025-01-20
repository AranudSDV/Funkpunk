using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UIElements;

public class sc_VisionCone : MonoBehaviour
{
    [SerializeField] private Material mVisionCone;
    [SerializeField] private Material mDetectedCone;
    [SerializeField] private Material mHeardCone;
    [SerializeField] private SC_FieldOfView scFieldView;
    private float fVisionAngle;
    [SerializeField]private GameObject GoCone;
    private MeshRenderer _ConeRenderer;

    private void Start()
    {
        //Cone
        _ConeRenderer = GoCone.transform.GetChild(0).gameObject.GetComponent<MeshRenderer>();
        _ConeRenderer.material = mVisionCone;
    }

    private void Update()
    {
        ChangeVisionCone();
        if (scFieldView.BCanSee)
        {
            _ConeRenderer.material = mDetectedCone;
        }
        else if(scFieldView.bHasHeard)
        {
            _ConeRenderer.material = mHeardCone;
        }
        else
        {
            _ConeRenderer.material = mVisionCone;
        }
    }
    private void ChangeVisionCone()
    {
        fVisionAngle = scFieldView.FAngle;
        fVisionAngle *= Mathf.Deg2Rad;
        float scale = Mathf.Ceil(2* Mathf.PI*scFieldView.FRadius * scFieldView.FAngle/360);
        GoCone.transform.localScale = new Vector3(scale,2, scFieldView.FRadius);
    }
}
