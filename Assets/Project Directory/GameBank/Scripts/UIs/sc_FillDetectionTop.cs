using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class sc_FillDetectionTop : MonoBehaviour
{
    [SerializeField] private UnityEngine.UI.Image filledImage;
    [SerializeField] private GameObject goForFill;
    [SerializeField] private RectTransform follower;
    [SerializeField] private UnityEngine.UI.Image imFillFor;

    private void Update()
    {
        if (filledImage == null || follower == null) return;
        if(goForFill.activeInHierarchy)
        {
            // Get the fill amount (0 to 1)
            float fillAmount = filledImage.fillAmount;

            // Get the height of the filled image
            float imageHeight = ((RectTransform)filledImage.transform).rect.height;

            // Calculate new Y position (assuming the anchor is at the bottom)
            float newY = imageHeight * fillAmount;
            if(fillAmount< 0.05f)
            {
                imFillFor.color = new Color32(255,255,255,0);
            }
            else
            {
                imFillFor.color = new Color32(255, 255, 255, 255);
                // Apply the new position
                follower.anchoredPosition = new Vector2(follower.anchoredPosition.x, newY);
            }
        }
    }

}
