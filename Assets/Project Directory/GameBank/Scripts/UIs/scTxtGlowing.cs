using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;

public class scTxtGlowing : MonoBehaviour
{
    // References
    [SerializeField]private TextMeshProUGUI text;
    private bool bNext =  true;

    private void Awake()
    {
        // Set Glow Power on the new material instance
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 1.0f);
    }

    private void Update()
    {
        if (bNext)
        {
            StartCoroutine(Glowing(1f));
        }
    }

    private IEnumerator Glowing(float waitTime)
    {
        bNext = false;
        yield return new WaitForSeconds(waitTime*0.7f);
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 0.1f);
        yield return new WaitForSeconds(waitTime*0.5f);
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 0.5f);
        yield return new WaitForSeconds(waitTime*0.05f);
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 0.2f);
        yield return new WaitForSeconds(waitTime*0.05f);
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 0.9f);
        yield return new WaitForSeconds(waitTime * 0.1f);
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 0.1f);
        yield return new WaitForSeconds(waitTime * 0.05f);
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 0.4f);
        yield return new WaitForSeconds(waitTime * 0.05f);
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 0.5f);
        yield return new WaitForSeconds(waitTime * 0.025f);
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 0.1f);
        yield return new WaitForSeconds(waitTime * 0.05f);
        text.fontSharedMaterial.SetFloat(ShaderUtilities.ID_GlowPower, 0.4f);
        bNext = true;
        yield break;
    }
}
