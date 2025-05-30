using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using Febucci.UI;
using static UnityEngine.Rendering.DebugUI;

public class textTest : MonoBehaviour
{
    public TextAnimatorPlayer typewriter; // Drag your TextAnimatorPlayer here in the Inspector

    void Start()
    {
        typewriter.onTextShowed.AddListener(OnTextFullyShown);
        ShowDialogue("Hello Maggie! Welcome to the world of animated text.");
    }

    void ShowDialogue(string text)
    {
        typewriter.ShowText(text);
    }
    void OnTextFullyShown()
    {
        Debug.Log("Text fully written!");
        ShowDialogue("Always blasting that insane oversized <bounce>boombox</bounce>!.");
        // You can trigger next dialogue, enable buttons, etc.
    }
}
