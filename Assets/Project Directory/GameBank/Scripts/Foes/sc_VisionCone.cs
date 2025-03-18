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
    [SerializeField] private SC_VisionConeCasting scVisionCone;

    private void Start()
    {
        scVisionCone.ConeRenderer.material = mVisionCone;
    }

    private void Update()
    {
        if (scFieldView.BCanSee)
        {
            scVisionCone.ConeRenderer.material = mDetectedCone;
        }
        else if(scFieldView.bHasHeard)
        {
            scVisionCone.ConeRenderer.material = mHeardCone;
        }
        else
        {
            scVisionCone.ConeRenderer.material = mVisionCone;
        }
    }
}
