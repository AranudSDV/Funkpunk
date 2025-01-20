using JetBrains.Annotations;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerData : MonoBehaviour
{
    public int iLevelPlayer;
    public int[] iStarsLvl0Player; //0 is true 1 is false
    public int[] iScorePerLvlPlayer;
    public int iLanguageNbPlayer;

    public void SaveGame()
    {
        SaveSystem.SaveGame(this);
    }

    public void LoadGame()
    {
        GameData data = SaveSystem.LoadGame();

        iLevelPlayer = data.iLevel;
        iScorePerLvlPlayer = data.iScorePerLvl;
        iLanguageNbPlayer = data.iLanguageNb;
    }
}
