using UnityEngine;

public class TiredLight : MonoBehaviour
{
    public Light targetLight;
    public float minDelay = 0.05f;
    public float maxDelay = 0.3f;
    public float minIntensity = 0f;
    public float maxIntensity = 1f;

    private void Start()
    {
        if (targetLight == null)
            targetLight = GetComponent<Light>();

        StartCoroutine(Flicker());
    }

    private System.Collections.IEnumerator Flicker()
    {
        while (true)
        {
            // Random delay between flickers
            float delay = Random.Range(minDelay, maxDelay);
            // Random intensity to simulate tired flickering
            targetLight.intensity = Random.Range(minIntensity, maxIntensity);
            yield return new WaitForSeconds(delay);
        }
    }
}
