using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class MainMenuNameChanging : MonoBehaviour
{
    [SerializeField]private MenuManager menuManager;
    [SerializeField] private TextMeshProUGUI txtAnyKey;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(menuManager.controllerConnected)
        {
            txtAnyKey.text = "Press A";
        }
        else
        {
            txtAnyKey.text = "Press any key";
        }
    }
}
