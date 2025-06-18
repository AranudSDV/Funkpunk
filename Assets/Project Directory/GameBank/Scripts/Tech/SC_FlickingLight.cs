using UnityEngine;

public class LightFlickering : MonoBehaviour
{
    public Light targetLight;
    public float fMinIntensity = 0f;
    public float fMaxIntensity = 1f;
    private float fBeatValue = 0f;

    private BPM_Manager manager;

    private void Start()
    {
        manager = BPM_Manager.instance;
    }

    private void Update()
    {
        Flickering();
    }

    private void Flickering()
    {
        fBeatValue = manager.fProgressBPM;
        if(targetLight!=null)
        {
            targetLight.intensity = Mathf.Lerp(fMaxIntensity, fMinIntensity, fBeatValue);
        }
    }
}
